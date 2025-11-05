import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:neptunesystem_mobile/screen/scan_code_page.dart';
import 'package:neptunesystem_mobile/services/employee_service.dart';
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
  EmployeeService employeeService = EmployeeService();

  bool isLoading = false;
  String errorMessage = '';
  Label? selectedRole;

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
                decoration: InputDecoration(
                  labelText: "codice badge utente",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () async {
                      final code = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => const ScanCodePage(
                                allowDecimal: false,
                                minDigits: 4,
                              ),
                          fullscreenDialog: true,
                        ),
                      );
                      if (code != null) {
                        employeeBadgeCode.text = code;
                        debugPrint('Letto: $code');
                      }
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Compilare il campo codice badge utente';
                  }
                  return null;
                },
              ),
              DropdownMenu<Label>(
                controller: roleController,
                label: const Text('Ruolo utente'),
                trailingIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                enableFilter: true,
                requestFocusOnTap: true,
                width: double.infinity,
                menuHeight: 300,
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSelected:
                    (Label? role) => setState(() => selectedRole = role),
                dropdownMenuEntries: Label.entries,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'unique_add_machine_button',
        onPressed: () async {
          final validate = _formKey.currentState!.validate();
          if (validate) {
            Map<String, Object> response = await employeeService.addNewEmployee(
              roleController.text,
              employeeNameController.text,
              employeeBadgeCode.text,
              widget.ipValue,
            );
            if (response["status"] == 200) {
              Navigator.pop(context);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['response'].toString())),
            );
          }
        },
        label: const Text("Aggiungi l'utente"),
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
