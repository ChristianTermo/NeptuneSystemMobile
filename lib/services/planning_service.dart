import 'dart:convert';

import 'package:http/http.dart' as http;

class PlanningService {
  Future<List<dynamic>> getPlanning(String ipValue) async {
    final httpCode;
    final body;

    final response = await http.get(Uri.parse('$ipValue/Planning'));
    httpCode = response.statusCode;
    body = response.body;

    print("📡 HTTP Code: $httpCode");
    print("📜 Body: $body");
    List<dynamic> plannings;

    plannings = json.decode(body);
    return plannings;
  }

 /* Future<Map<String, Object>> deletePlanning(
    dynamic planning,
    String ipValue,
  ) async {
    try {
      final httpCode;
      final body;
      Map<String, Object> r;

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
        Uri.parse('$ipValue/Planning'),
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
        return r = {
          "status": httpCode,
          "response": 'Operazione avvenuta con successo!',
        };
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
  }*/
}
