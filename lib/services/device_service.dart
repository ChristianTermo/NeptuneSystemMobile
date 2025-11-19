import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class DeviceService {
  Future<List<dynamic>> getDevices(
    String ipValue,
    List<dynamic> devices,
  ) async {
    try {
      final httpCode;
      final body;

      final response = await http.get(Uri.parse('$ipValue/api/getDevices'));
      httpCode = response.statusCode;
      body = response.body;
      print("📡 HTTP Code: $httpCode");
      print("📜 Body: $body");

      if (httpCode == 200) {
        devices = json.decode(body);
      } else {}
    } on TimeoutException {
    } on http.ClientException catch (e) {
    } catch (e) {}
    return devices;
  }

  Future<List<dynamic>> getAllDevices(
    String ipValue,
    List<dynamic> devices,
  ) async {
    try {
      final httpCode;
      final body;

      final response = await http.get(Uri.parse('$ipValue/Devices'));
      httpCode = response.statusCode;
      body = response.body;
      print("📡 HTTP Code: $httpCode");
      print("📜 Body: $body");

      if (httpCode == 200) {
        devices = json.decode(body);
      } else {}
    } on TimeoutException {
    } on http.ClientException catch (e) {
    } catch (e) {}
    return devices;
  }

  Future<List<dynamic>> getPositionBusy(String ipValue) async {
    List<dynamic> positionBusy = [];

    try {
      final httpCode;
      final body;
      List<dynamic> devices;

      final response = await http.get(Uri.parse('$ipValue/Devices'));
      httpCode = response.statusCode;
      body = response.body;
      print("📡 HTTP Code: $httpCode");
      print("📜 Body: $body");

      if (httpCode == 200) {
        devices = json.decode(body);
        for (var device in devices) {
          var position =
              device["DrumId"].toString() + device["SectorId"].toString();
          print('position: $position');
          positionBusy.add(position);
        }
      }
    } on TimeoutException {
    } on http.ClientException catch (e) {
    } catch (e) {}
    return positionBusy;
  }

  Future<Map<String, Object>> addNewCar(
    String ipValue,
    String deviceId,
    String ecpCode,
    int drumId,
    int sectorId,
  ) async {
    Map<String, Object> r = {};

    try {
      final httpCode;
      final body;

      final payload = [
        {
          "Location": "DrumId-SectorId",
          "Status": "OK",
          "DeviceId": deviceId,
          "SectorId": sectorId,
          "DeviceDetail": null,
          "DeviceType": null,
          "NominalNumber": 1,
          "DeviceBarCode": "",
          "MachineId": "S2",
          "TemporaryOwner": null,
          "ExpirationDate": "",
          "Holder": true,
          "EcpCode": ecpCode,
          "DrumId": drumId,
        },
      ];

      print("payload + $payload");

      List<dynamic> positionBusy = await getPositionBusy(ipValue);
      print("$drumId $sectorId");
      if (positionBusy.contains("$drumId$sectorId")) {
        return r = {"status": 401, "response": "Casella già occupata!"};
      }

      final response = await http.post(
        Uri.parse('$ipValue/Devices'),
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
          "response": "Operazione avvenuta con successo!",
        };
      } else {
        return r = {"status": httpCode, "response": "errore! $body"};
      }
    } catch (e) {
      return r = {"status": 500, "response": 'Macchina non raggiungibile'};
    }
  }

  Future<Map<String, Object>> updateDevice(
    String ipValue,
    String deviceId,
    String ecpCode,
    int drumId,
    int sectorId,
    bool holder,
  ) async {
    Map<String, Object> r = {};

    try {
      final httpCode;
      final body;

      final payload = {
        "DeviceId": deviceId,
        "SectorId": sectorId,
        "EcpCode": ecpCode,
        "DrumId": drumId,
        "Holder": holder,
      };

      print("payload + $payload");

      List<dynamic> positionBusy = await getPositionBusy(ipValue);
      print("$drumId $sectorId");
      if (positionBusy.contains("$drumId$sectorId")) {
        return r = {"status": 401, "response": "Casella già occupata!"};
      }

      final response = await http.put(
        Uri.parse('$ipValue/Devices'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );
      httpCode = response.statusCode;
      body = response.body;

      print("📡 HTTP Codeaaa: $httpCode");
      print("📡 HTTP Codeaaa: $body");

      if (httpCode == 200) {
        return r = {
          "status": httpCode,
          "response": "Operazione avvenuta con successo!",
        };
      } else {
        return r = {"status": httpCode, "response": "errore! $body"};
      }
    } catch (e) {
      return r = {"status": 500, "response": 'Macchina non raggiungibile'};
    }
  }

  Future<Map<String, Object>> deleteDevice(
    String ipValue,
    String deviceId,
  ) async {
    Map<String, Object> r = {};

    try {
      final httpCode;
      final body;

      final payload = {"DeviceId": deviceId};

      print("payload + $payload");

      /*List<dynamic> positionBusy = await getPositionBusy(ipValue);
      print("$drumId $sectorId");
      if (positionBusy.contains("$drumId$sectorId")) {
        return r = {"status": 401, "response": "Casella già occupata!"};
      }*/

      final response = await http.delete(
        Uri.parse('$ipValue/Devices'),
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
          "response": "Operazione avvenuta con successo!",
        };
      } else {
        return r = {"status": httpCode, "response": "errore! $body"};
      }
    } catch (e) {
      return r = {"status": 500, "response": 'Macchina non raggiungibile'};
    }
  }
}
