import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neptunesystem_mobile/screen/select_employee.dart';
import 'package:neptunesystem_mobile/services/device_service.dart';
import 'package:neptunesystem_mobile/services/navigator_service.dart';

class ManageDevice extends StatefulWidget {
  final String ipValue;
  final String machineid;

  const ManageDevice({
    super.key,
    required this.ipValue,
    required this.machineid,
  });
  @override
  State<StatefulWidget> createState() => ManageDeviceState();
}

class ManageDeviceState extends State<ManageDevice> {
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
      devices = await deviceService.getAllDevices(widget.ipValue, devices);

      setState(() {
        filteredDevices = devices;
        isLoading = false;
      });

      print("filteredDevices: $filteredDevices");
    });
  }

  void filterDevices(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredDevices = devices;
      } else {
        filteredDevices =
            devices.where((event) {
              return event['DeviceId'].toString().toLowerCase().contains(
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
                  NavigatorService.goToAddNewCarForm(
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
              onChanged: filterDevices,
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
                          Icons.car_rental,
                          color: Colors.white,
                        ), // Icona utente
                      ),
                      title: Text(
                        "${device["DeviceId"]!}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              NavigatorService.goToUpdateDeviceForm(
                                machineid: widget.machineid,
                                ipValue: widget.ipValue,
                                device: device,
                              );
                            },
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              Map<String, Object> response = await deviceService
                                  .deleteDevice(
                                    widget.ipValue,
                                    device["DeviceId"],
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
