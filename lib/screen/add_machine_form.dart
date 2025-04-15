import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:neptunesystem_mobile/data/entity/machine.dart';
import 'package:sqflite/sqflite.dart';
import 'package:neptunesystem_mobile/services/machine_service.dart';

class AddMachineForm extends StatefulWidget {
  final List<Machine> machinelist;
  final SSHClient sshClient;
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'unique_add_machine_button',
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            String ipValue = ipController.text;

            try {
              final session = await widget.sshClient.execute(
                'curl -s -w "HTTP_CODE:%{http_code}" http://$ipValue:8080/api/keepalive',
              );

              final result = await session.stdout.map(utf8.decode).join();
              final parts = result.split("HTTP_CODE:");
              final body = parts[0].trim();
              final httpCode = parts.length > 1 ? parts[1].trim() : "N/A";

              print("📡 HTTP Code: $httpCode");
              print("📜 Body: $body");

              if (httpCode == '200') {
                Machine machine = Machine(
                  machineid: machineIdController.text,
                  ip_address: ipValue,
                );
                MachineService machineService = MachineService(
                  database: widget.database,
                );
                final machinelist = await machineService.findByid(
                  machineIdController.text,
                );

                if (machinelist.isEmpty) {
                  machineService.insertMachine(machine);
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Macchina già esistente')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Macchina non raggiungibile')),
                );
              }
            } catch (e) {
              print("❌ Macchina non raggiungibile: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Macchina non raggiungibile: $e')),
              );
            }
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
