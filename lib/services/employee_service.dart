import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class EmployeeService {
  bool isLoading = false;
  String errorMessage = '';

  Future<Map<String, Object>> addNewEmployee(
    String role,
    String employeeName,
    String badge,
    String ipValue,
  ) async {
    Map<String, Object> r;

    try {
      final httpCode;
      final body;

      Uuid uuid = Uuid();

      final payload = [
        {
          "EmployeeId": uuid.v1(),
          "EmployeeRole": role,
          "EmployeeName": employeeName,
          "EmployeeCard": badge,
        },
      ];

      print("planningId $payload");

      print("payload + $payload");

      final response = await http.post(
        Uri.parse('$ipValue/Employee'),
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
        return r = {
          "status": httpCode,
          "response": 'Operazione avvenuta con successo!',
        };
      } else {
        print(body);
        return r = {
          "status": httpCode,
          "response": 'Macchina non raggiungibile',
        };
      }
    } catch (e) {}
    return r = {"status": 500, "response": 'Macchina non raggiungibile'};
  }

  Future<List<dynamic>> getEmployeeForAssistantRetreat(
    String ipValue,
    List<dynamic> employees,
  ) async {
    try {
      final httpCode;
      final body;

      final response = await http
          .get(Uri.parse('$ipValue/api/getEmployee'))
          .timeout(const Duration(seconds: 5));
      httpCode = response.statusCode;
      body = response.body;
      print("📡 HTTP Code: $httpCode");
      print("📜 Body: $body");

      employees = json.decode(body);
    } on TimeoutException {
    } on http.ClientException catch (e) {
    } catch (e) {}
    return employees;
  }

  /*void filterEmployee(String query) {
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
  }*/
}
