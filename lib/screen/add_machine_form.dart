import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:neptunesystem_mobile/data/entity/machine.dart';
import 'package:sqflite/sqflite.dart';
import 'package:neptunesystem_mobile/services/machine_service.dart';
import 'package:http/http.dart' as http;

class AddMachineForm extends StatefulWidget {
  final List<Machine> machinelist;
  final Database database;

  const AddMachineForm({
    super.key,
    required this.machinelist,
    required this.database,
  });

  @override
  State<AddMachineForm> createState() => AddMachineFormState();
}

class AddMachineFormState extends State<AddMachineForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController ipController = TextEditingController();

  Future<Map<String, Object?>> keepAlive() async {
    final httpCode;
    final body;
    final ipValue = ipController.text;

    try {
      final response = await http
          .get(Uri.parse('$ipValue/api/keepalive'))
          .timeout(const Duration(seconds: 5));

      httpCode = response.statusCode;
      body = json.decode(response.body);
    } on TimeoutException {
      return {
        'Status': 'Failed',
        'Error':
            'Timeout: la macchina non ha risposto entro un tempo ragionevole',
      };
    } on http.ClientException catch (e) {
      return {'Status': 'Failed', 'Error': 'Errore HTTP: ${e.message}'};
    } catch (e) {
      return {'Status': 'Failed', 'Error': 'Errore generico: $e'};
    }

    print("📡 HTTP Code: $httpCode");

    if (httpCode == 200) {
      final machineService = MachineService(database: widget.database);
      final machinelist = await machineService.findByid(
        body["machineId"],
      );

      if (machinelist.isEmpty) {
        Machine machine = Machine(
          machineid: body["machineId"],
          ip_address: ipValue,
          isTruckingOn: body["truckingOn"] ? 1 : 0,
        );
        await machineService.insertMachine(machine);
        Navigator.pop(context, true);
        return {'Status': 'Success', 'Error': ''};
      } else {
        return {'Status': 'Failed', 'Error': 'Macchina già esistente'};
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'unique_add_machine_button',
        onPressed: () async {
          final response = await keepAlive();
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
