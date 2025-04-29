import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:neptunesystem_mobile/data/entity/machine.dart';
import 'package:sqflite/sqflite.dart';
import 'package:neptunesystem_mobile/services/machine_service.dart';
import 'package:http/http.dart' as http;

class AddMachineForm extends StatefulWidget {
  final List<Machine> machinelist;
  final SSHClient? sshClient;
  final Database database;

  const AddMachineForm({
    super.key,
    required this.machinelist,
    required this.sshClient,
    required this.database,
  });

  @override
  State<AddMachineForm> createState() => AddMachineFormState();
}

class AddMachineFormState extends State<AddMachineForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController ipController = TextEditingController();
  final TextEditingController machineIdController = TextEditingController();
  final TextEditingController badgeController = TextEditingController();

  bool onlyLocal = false;

Future<Map<String, Object?>> keepAlive(
  String ipValue,
  Machine machine,
) async {
  int? httpCode;

  try {
    if (onlyLocal) {
      final response = await http
          .get(Uri.parse('http://$ipValue:8080/api/keepalive'))
          .timeout(const Duration(seconds: 5));

      httpCode = response.statusCode;
    } else {
      if (widget.sshClient != null) {
        final session = await widget.sshClient!.execute(
          'curl -s -w "HTTP_CODE:%{http_code}" http://$ipValue:8080/api/keepalive',
        );

        final response = await session.stdout.map(utf8.decode).join();
        final parts = response.split("HTTP_CODE:");
        final body = parts[0].trim();
        final httpCodeString = parts.length > 1 ? parts[1].trim() : "N/A";
        httpCode = int.tryParse(httpCodeString);

        print("📜 Body: $body");
      } else {
        return {
          'Status': 'Failed',
          'Error': 'Connessione SSH non riuscita',
        };
      }
    }
  } on TimeoutException {
    return {
      'Status': 'Failed',
      'Error': 'Timeout: la macchina non ha risposto entro un tempo ragionevole',
    };
  } on http.ClientException catch (e) {
    return {
      'Status': 'Failed',
      'Error': 'Errore HTTP: ${e.message}',
    };
  } catch (e) {
    return {
      'Status': 'Failed',
      'Error': 'Errore generico: $e',
    };
  }

  print("📡 HTTP Code: $httpCode");

  if (httpCode == 200) {
    final machineService = MachineService(database: widget.database);
    final machinelist = await machineService.findByid(machineIdController.text);

    if (machinelist.isEmpty) {
      await machineService.insertMachine(machine);
      Navigator.pop(context, true);
      return {
        'Status': 'Success',
        'Error': '',
      };
    } else {
      return {
        'Status': 'Failed',
        'Error': 'Macchina già esistente',
      };
    }
  } else {
    return {
      'Status': 'Failed',
      'Error': 'Macchina non raggiungibile (HTTP $httpCode)',
    };
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi una macchina'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: ipController,
                autofocus: true,
                decoration: InputDecoration(labelText: "Ip del distributore"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Compilare il campo Ip del distributore';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: machineIdController,
                autofocus: true,
                decoration: InputDecoration(labelText: "Machine Id"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Compilare il campo Machine Id';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: badgeController,
                autofocus: true,
                decoration: InputDecoration(labelText: "Codice badge"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Compilare il campo Codice badge';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Local Version (Just for testing)"),
                  Switch(
                    value: onlyLocal,
                    onChanged: (bool value) {
                      setState(() {
                        onlyLocal = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'unique_add_machine_button',
        onPressed: () async {
          String ipValue = ipController.text;
          Machine machine = Machine(
            machineid: machineIdController.text,
            ip_address: ipValue,
            onlyLocal: onlyLocal,
          );
          final response = await keepAlive(ipValue, machine);
          if (response['Status'] == 'Failed') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['Error'].toString())),
            );
          }
        },
        label: const Text("Aggiungi la macchina"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(180),
          side: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}
