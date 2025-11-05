import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neptunesystem_mobile/screen/select_employee.dart';
import 'package:neptunesystem_mobile/services/device_service.dart';
import 'package:neptunesystem_mobile/services/navigator_service.dart';

class SelectDevice extends StatefulWidget {
  final String ipValue;
  final String machineid;
  final int isTruckingOn;

  const SelectDevice({
    super.key,
    required this.ipValue,
    required this.machineid,
    required this.isTruckingOn,
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
  DeviceService deviceService = DeviceService();

  @override
  void initState() {
    super.initState();
    isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      devices = await deviceService.getDevices(widget.ipValue, devices);

      setState(() {
        filteredDevices = devices;
        isLoading = false;
      });

      print("filteredDevices: $filteredDevices");
    });
  }

  Future<void> getDevices() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final httpCode;
      final body;

      final response = await http.get(
        Uri.parse('${widget.ipValue}/api/getDevices'),
      );
      httpCode = response.statusCode;
      body = response.body;
      print("📡 HTTP Code: $httpCode");
      print("📜 Body: $body");

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
              return event['ObjectId'].toString().toLowerCase().contains(
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
              : devices.isEmpty
              ? Center(
                child: Text(
                  "NESSUN DISPOSITIVO DISPONIBILE",
                  style: TextStyle(color: Colors.red, fontSize: 20),
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
                        "${device["ObjectId"]!} ${device["DeviceSize"] ?? 'N/A'}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        device['ExpirationDate'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          NavigatorService.goToSelectEmployeePage(
                            machineid: widget.machineid,
                            ipValue: widget.ipValue,
                            selectedDevice: device,
                            isTruckingOn: widget.isTruckingOn,
                          );
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
