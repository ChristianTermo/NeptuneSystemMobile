import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neptunesystem_mobile/screen/select_employee.dart';
import 'package:neptunesystem_mobile/services/employee_service.dart';
import 'package:neptunesystem_mobile/services/employee_service.dart';
import 'package:neptunesystem_mobile/services/navigator_service.dart';

class ManageUser extends StatefulWidget {
  final String ipValue;
  final String machineid;

  const ManageUser({
    super.key,
    required this.ipValue,
    required this.machineid,
  });
  @override
  State<StatefulWidget> createState() => ManageUserState();
}

class ManageUserState extends State<ManageUser> {
  List<dynamic> employees = [];
  List<dynamic> filteredemployees = [];
  bool isLoading = false;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();
  EmployeeService employeeService = EmployeeService();
  @override
  void initState() {
    super.initState();
    isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      employees = await employeeService.getEmployeeForAssistantRetreat(
        widget.ipValue,
        employees,
      );

      setState(() {
        filteredemployees = employees;
        isLoading = false;
      });

      print("filteredemployees: $filteredemployees");
    });
  }

  void filteremployees(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredemployees = employees;
      } else {
        filteredemployees =
            employees.where((event) {
              return event['EmployeeName'].toString().toLowerCase().contains(
                query.toLowerCase(),
              );
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.machineid),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed:
                () async => {
                  NavigatorService.goToAddNewUserForm(
                    machineid: widget.machineid,
                    ipValue: widget.ipValue,
                  ),
                },
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: TextField(
              controller: searchController,
              onChanged: filteremployees,
              decoration: InputDecoration(
                hintText: "Cerca utente...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 25),
                ),
              )
              : employees.isEmpty
              ? Center(
                child: Text(
                  "NESSUN UTENTE DISPONIBILE",
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
              )
              : ListView.builder(
                itemCount: filteredemployees.length,
                itemBuilder: (context, index) {
                  final employee = filteredemployees[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[800],
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ), // Icona utente
                      ),
                      title: Text(
                        "${employee["EmployeeName"]!}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              NavigatorService.goToUpdateUserForm(
                                machineid: widget.machineid,
                                ipValue: widget.ipValue,
                                employee: employee,
                              );
                            },
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              Map<String, Object> response =
                                  await employeeService.deleteEmployee(
                                    widget.ipValue,
                                    employee["EmployeeId"],
                                  );
                              if (response["status"] == 200) {
                                Navigator.pop(context);
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    response['response'].toString(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
