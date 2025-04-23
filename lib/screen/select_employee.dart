import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class SelectEmployee extends StatefulWidget {
  final SSHClient? sshClient;
  final String ipValue;
  final String machineid;
  final dynamic selectedDevice;

  const SelectEmployee({
    super.key,
    required this.sshClient,
    required this.ipValue,
    required this.machineid,
    required this.selectedDevice,
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

  @override
  void initState() {
    super.initState();
    getEmployeeForAssistantRetreat();
  }

  Future<void> getEmployeeForAssistantRetreat() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final session = await widget.sshClient!.execute(
        'curl -s -w "HTTP_CODE:%{http_code}" http://${widget.ipValue}:8080/api/getEmployee',
      );

      final result = await session.stdout.map(utf8.decode).join();
      final parts = result.split("HTTP_CODE:");
      final body = parts[0].trim();
      final httpCode = parts.length > 1 ? parts[1].trim() : "N/A";

      print("📡 HTTP Code: $httpCode");
      print("📜 Body: $body");

      if (httpCode == '200') {
        setState(() {
          employees = json.decode(body);
          filteredEmployee = employees;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Macchina non raggiungibile";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Errore di connessione: $e";
        isLoading = false;
      });
    }
  }

  Future<void> retreat() async {
    try {
      final payload = '''
{
  "deviceId": ${widget.selectedDevice["DeviceId"]},
  "employeeId": "${widget.selectedDevice["EmployeeAssociated"]}",
  "isAssistant": true
}
''';

      final curlCommand = '''
curl -s -X POST -H "Content-Type: application/json" \
-d '$payload' \
-w "HTTP_CODE:%{http_code}" \
http://${widget.ipValue}:8080/api/receive/devices
''';

      final session = await widget.sshClient!.execute(curlCommand);

      final result = await session.stdout.map(utf8.decode).join();
      final parts = result.split("HTTP_CODE:");
      final body = parts[0].trim();
      final httpCode = parts.length > 1 ? parts[1].trim() : "N/A";

      print("📡 HTTP Code: $httpCode");
      print("📜 Body: $body");

      if (httpCode == '200') {
        setState(() {
          employees = json.decode(body);
          filteredEmployee = employees;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Macchina non raggiungibile";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Errore di connessione: $e";
        isLoading = false;
      });
    }
  }

  void filterEvents(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredEmployee = employees;
      } else {
        filteredEmployee =
            employees.where((event) {
              return event['EmployeeId'].toString().toLowerCase().contains(
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
              onChanged: filterEvents, // Filtra gli eventi in tempo reale
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
                child: Text(errorMessage, style: TextStyle(color: Colors.red)),
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
                          retreat();
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
