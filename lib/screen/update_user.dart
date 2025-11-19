import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:neptunesystem_mobile/screen/scan_code_page.dart';
import 'package:neptunesystem_mobile/services/employee_service.dart';
import 'package:neptunesystem_mobile/services/navigator_service.dart';
import 'package:uuid/uuid.dart';

class UpdateUser extends StatefulWidget {
  const UpdateUser({
    super.key,
    required this.machineid,
    required this.ipValue,
    required this.employee,
  });

  final String ipValue;
  final String machineid;
  final dynamic employee;

  @override
  State<StatefulWidget> createState() => UpdateUserState();
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

class UpdateUserState extends State<UpdateUser> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController employeeNameController = TextEditingController();
  TextEditingController employeeBadgeCode = TextEditingController();
  TextEditingController roleController = TextEditingController();
  EmployeeService employeeService = EmployeeService();

  bool isLoading = false;
  String errorMessage = '';
  Label? selectedRole;

  @override
  void initState() {
    super.initState();
    employeeNameController = TextEditingController(
      text: widget.employee["EmployeeName"]?.toString() ?? "",
    );
    employeeBadgeCode = TextEditingController(
      text: widget.employee["EmployeeCard"]?.toString() ?? "",
    );
    roleController = TextEditingController(
      text: widget.employee["EmployeeRole"]?.toString() ?? "",
    );
    print(widget.employee);
  }

  @override
  void dispose() {
    employeeNameController.dispose();
    employeeBadgeCode.dispose();
    roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aggiorna utente ${widget.employee["EmployeeName"]}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 600, 
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TextFormField(
                          controller: employeeNameController,
                          decoration: const InputDecoration(
                            labelText: "Nome utente",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Compilare il campo Nome utente';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: employeeBadgeCode,
                          decoration: InputDecoration(
                            labelText: "Codice badge utente",
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
                        const SizedBox(height: 20),

                        DropdownMenu<Label>(
                          controller: roleController,
                          label: const Text('Ruolo utente'),
                          trailingIcon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                          ),
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
                              (Label? role) =>
                                  setState(() => selectedRole = role),
                          dropdownMenuEntries: Label.entries,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'unique_add_machine_button',
        onPressed: () async {
          final validate = _formKey.currentState!.validate();
          if (validate) {
            Map<String, Object> response = await employeeService.updateEmployee(
              roleController.text,
              employeeNameController.text,
              employeeBadgeCode.text,
              widget.employee["EmployeeId"],
              widget.ipValue,
            );
            if (response["status"] == 200) {
              NavigatorService.goToManageUserPage(
                machineid: widget.machineid,
                ipValue: widget.ipValue,
              );
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['response'].toString())),
            );
          }
        },
        label: const Text("Aggiorna l'utente"),
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
