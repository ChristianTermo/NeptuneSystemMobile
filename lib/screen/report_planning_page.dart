import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class ReportPlanningPage extends StatefulWidget {
  final String ipValue;
  final String machineid;

  const ReportPlanningPage({
    super.key,
    required this.ipValue,
    required this.machineid,
  });

  @override
  State<StatefulWidget> createState() => _ReportPlanningPageState();
}

class _ReportPlanningPageState extends State<ReportPlanningPage> {
  List<dynamic> plannings = [];
  List<dynamic> filteredPlanning = [];
  List<List<dynamic>> rows = [];
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    getPlanning();
  }

  Future<void> getPlanning() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final httpCode;
      final body;

      final response = await http.get(Uri.parse('${widget.ipValue}/Planning'));
      httpCode = response.statusCode;
      body = response.body;

      print("📡 HTTP Code: $httpCode");
      print("📜 Body: $body");

      if (body == '[]') {
        setState(() {
          errorMessage = "Nessun planning disponibile";
          isLoading = false;
        });
      }

      if (httpCode == 200) {
        setState(() {
          plannings = json.decode(body);
          filteredPlanning = plannings;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              "Macchina non raggiungibile"
              ' $httpCode $body';
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

  Future<void> deletePlanning(dynamic planning) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final httpCode;
      final body;

      final payload = [
        {
          "DeviceId": planning["DeviceId"],
          "EmployeeId": planning["EmployeeId"],
          "PlanningDate": planning["PlanningDate"],
          "StartPlan": planning["StartPlan"],
          "StopPlan": planning["StopPlan"],
          "PlanningID": planning["PlanningId"],
          "EnumDeviceType": planning["EnumDeviceType"],
        },
      ];

      final response = await http.delete(
        Uri.parse('${widget.ipValue}/Planning'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      httpCode = response.statusCode;
      body = response.body;

      print("📡 HTTP Code: $httpCode");
      print("📜 Body: $body");

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
    } catch (e) {
      setState(() {
        errorMessage = "Errore di connessione: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.machineid), centerTitle: true),
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
                itemCount: filteredPlanning.length,
                itemBuilder: (context, index) {
                  final planning = filteredPlanning[index];

                  String deviceId = planning['DeviceId'] ?? 'N/A';
                  String planningDate = planning['PlanningDate'] ?? 'N/A';
                  //String objectId = planning['Emplo'] ?? 'N/A';
                  String employee = planning['EmployeeId'] ?? 'N/A';

                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      title: Text("Auto: $deviceId"),
                      // subtitle: Text("Dispositivo: $objectId"),
                      trailing: Text(
                        "$planningDate\nUtente: $employee",
                        textAlign: TextAlign.right,
                      ),
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text(
                                  'Vuoi eliminare questa prenotazione?',
                                ),
                                actions: [
                                  IconButton(
                                    onPressed: () async {
                                      await deletePlanning(planning);
                                      setState(initState);
                                    },
                                    icon: const Icon(Icons.check),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
