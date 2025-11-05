import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neptunesystem_mobile/services/employee_service.dart';
import 'package:neptunesystem_mobile/services/navigator_service.dart';

class SelectEmployee extends StatefulWidget {
  final String ipValue;
  final String machineid;
  final dynamic selectedDevice;
  final int isTruckingOn;

  const SelectEmployee({
    super.key,
    required this.ipValue,
    required this.machineid,
    required this.selectedDevice,
    required this.isTruckingOn,
  });

  @override
  State<StatefulWidget> createState() => SelectEmployeeState();
}

class SelectEmployeeState extends State<SelectEmployee> {
  List<dynamic> employees = [];
  List<dynamic> filteredEmployee = [];
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
        filteredEmployee = employees;
        isLoading = false;
      });

      print("filteredEmployee: $filteredEmployee");
    });
  }

  Future<void> retreat(dynamic employee) async {
    try {
      final httpCode;
      final body;

      final payload = {
        "deviceId": widget.selectedDevice["ObjectId"],
        "employeeId": employee["EmployeeId"],
        "isAssistant": true,
        "deviceDetailId": widget.selectedDevice["DeviceSize"],
      };

      final response = await http.post(
        Uri.parse('${widget.ipValue}/api/receive/devices'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );
      httpCode = response.statusCode;
      body = response.body;

      print("📡 HTTP Codeaaa: $httpCode");
      print("📡 HTTP Codeaaa: ${widget.selectedDevice}");

      if (httpCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Operazione avvenuta con successo!')),
        );
      } else {
        print(body);
        setState(() {
          errorMessage = "Macchina non raggiungibile";
          isLoading = false;
        });
      }
      NavigatorService.goToHomePage();
    } catch (e) {
      setState(() {
        errorMessage = "Errore di connessione: $e";
        isLoading = false;
      });
    }
  }

  void filterEmployee(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredEmployee = employees;
      } else {
        filteredEmployee =
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: TextField(
              controller: searchController,
              onChanged: filterEmployee,
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
              : ListView.builder(
                itemCount: filteredEmployee.length,
                itemBuilder: (context, index) {
                  final employee = filteredEmployee[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[800],
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        employee["EmployeeName"]!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          print("Selezionato: ${employee['EmployeeName']}");
                          retreat(employee);
                        },
                        child: Text("Seleziona"),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
