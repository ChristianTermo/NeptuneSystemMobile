import 'dart:async';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neptunesystem_mobile/screen/select_employee.dart';

class SelectDevice extends StatefulWidget {
  final SSHClient? sshClient;
  final String ipValue;
  final String machineid;
  final bool onlyLocal;

  const SelectDevice({
    super.key,
    required this.sshClient,
    required this.ipValue,
    required this.onlyLocal,
    required this.machineid,
  });
  @override
  State<StatefulWidget> createState() => SelectDeviceState();
}

class SelectDeviceState extends State<SelectDevice> {
  List<dynamic> devices = [];
  List<dynamic> filteredDevices = [];
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
      final httpCode;
      final body;

      if (widget.onlyLocal) {
        final response = await http.get(
          Uri.parse('http://${widget.ipValue}:8080/api/getDevices'),
        );
        httpCode = response.statusCode;
        body = response.body;
        print("📡 HTTP Code: $httpCode");
        print("📜 Body: $body");
      } else {
        final session = await widget.sshClient!.execute(
          'curl -s -w "HTTP_CODE:%{http_code}" http://${widget.ipValue}:8080/api/getDevices',
        );

        final result = await session.stdout.map(utf8.decode).join();
        final parts = result.split("HTTP_CODE:");
        body = parts[0].trim();
        final httpCodeString = parts.length > 1 ? parts[1].trim() : "N/A";

        httpCode = int.tryParse(httpCodeString);

        print("📡 HTTP Code: $httpCode");
        print("📜 Body: $body");
      }

      if (body == '[]') {
        setState(() {
          errorMessage = "Lista dispositivi vuota";
          isLoading = false;
        });
      }

      if (httpCode == 200) {
        setState(() {
          devices = json.decode(body);
          filteredDevices = devices;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Macchina non raggiungibile";
          isLoading = false;
        });
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Timeout: la macchina non ha risposto entro un tempo ragionevole',
          ),
        ),
      );
    } on http.ClientException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Macchina non raggiungibile')));
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
        filteredDevices = devices;
      } else {
        filteredDevices =
            devices.where((event) {
              return event['EmployeeAssociated']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
            }).toList();
      }
    });
  }

  Future<void> goToSelectEmployeePage(dynamic device) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SelectEmployee(
              sshClient: widget.sshClient,
              ipValue: widget.ipValue,
              machineid: widget.machineid,
              onlyLocal: widget.onlyLocal,
              selectedDevice: device,
            ),
      ),
    );
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
              onChanged: filterEvents,
              decoration: InputDecoration(
                hintText: "Cerca dispositivo...",
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
                itemCount: filteredDevices.length,
                itemBuilder: (context, index) {
                  final device = filteredDevices[index];
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
                        device["EmployeeAssociated"]!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        device['ExpirationDate'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          goToSelectEmployeePage(device);
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
