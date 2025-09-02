import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({
    super.key,
    required this.machineid,
    required this.ipValue,
  });

  final String ipValue;
  final String machineid;

  @override
  State<StatefulWidget> createState() => AddEmployeePageState();
}

typedef LabelEntry = DropdownMenuEntry<Label>;

enum Label {
  Assistant("Assistant"),
  User("User"),
  Charger("Charger");

  final String label;
  const Label(this.label);

  static final List<LabelEntry> entries = UnmodifiableListView<LabelEntry>(
    values.map<LabelEntry>(
      (Label role) => LabelEntry(value: role, label: role.label),
    ),
  );
}

class AddEmployeePageState extends State<AddEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController employeeNameController = TextEditingController();
  TextEditingController employeeBadgeCode = TextEditingController();
  TextEditingController roleController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  Label? selectedRole;

  Future<void> addNewEmployee() async {
    try {
      final httpCode;
      final body;

      Uuid uuid = Uuid();

      final payload = [
        {
          "EmployeeId": uuid.v1(),
          "EmployeeRole": roleController.text,
          "EmployeeName": employeeNameController.text,
          "EmployeeCard": employeeBadgeCode.text,
        },
      ];

      print("planningId $payload");

      print("payload + $payload");

      final response = await http.post(
        Uri.parse('${widget.ipValue}/Employee'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );
      httpCode = response.statusCode;
      body = response.body;

      print("📡 HTTP Codeaaa: $httpCode");

      if (httpCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Operazione avvenuta con successo!')),
        );
      } else {
        print(body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Macchina non raggiungibile')));
        setState(() {
          errorMessage = "Macchina non raggiungibile";
          isLoading = false;
        });
      }
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorMessage = "Errore di connessione: $e";
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registra un utente'),
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
                controller: employeeNameController,
                autofocus: true,
                decoration: InputDecoration(labelText: "Nome utente"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Compilare il campo Nome utente';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: employeeBadgeCode,
                autofocus: true,
                decoration: InputDecoration(labelText: "codice badge utente"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Compilare il campo codice badge utente';
                  }
                  return null;
                },
              ),
              DropdownMenu<Label>(
                controller: roleController,
                enableFilter: true,
                requestFocusOnTap: true,
                label: const Text('Ruolo utente'),
                inputDecorationTheme: const InputDecorationTheme(
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                ),
                onSelected: (Label? role) {
                  setState(() {
                    selectedRole = role;
                  });
                },
                dropdownMenuEntries: Label.entries,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'unique_add_machine_button',
        onPressed: () async {
          await addNewEmployee();
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
