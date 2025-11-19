import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neptunesystem_mobile/screen/scan_code_page.dart';
import 'package:neptunesystem_mobile/services/device_service.dart';

class UpdateDevice extends StatefulWidget {
  const UpdateDevice({
    super.key,
    required this.machineid,
    required this.ipValue,
    required this.device,
  });

  final String ipValue;
  final String machineid;
  final dynamic device;

  @override
  State<UpdateDevice> createState() => UpdateDeviceState();
}

class UpdateDeviceState extends State<UpdateDevice> {
  bool isLoading = false;
  String errorMessage = '';
  final _formKey = GlobalKey<FormState>();
  List<dynamic> devices = [];
  List<dynamic> positionBusy = [];
  DeviceService deviceService = DeviceService();
  String code = "";
  bool holder = false;
  String deviceId = "";
  TextEditingController deviceCodeController = TextEditingController();
  TextEditingController drumController = TextEditingController();
  TextEditingController sectorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    deviceId = widget.device["DeviceId"];

    deviceCodeController = TextEditingController(
      text: widget.device["EcpCode"]?.toString() ?? "",
    );
    drumController = TextEditingController(
      text: widget.device["DrumId"]?.toString() ?? "",
    );
    sectorController = TextEditingController(
      text: widget.device["SectorId"]?.toString() ?? "",
    );
    holder = widget.device["Holder"];

    print(widget.device);
  }

  @override
  void dispose() {
    deviceCodeController.dispose();
    drumController.dispose();
    sectorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aggiorna il dispositivo $deviceId'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: deviceCodeController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Codice dispositivo",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () async {
                      code = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => const ScanCodePage(
                                allowDecimal: false,
                                minDigits: 4,
                              ),
                          fullscreenDialog: true,
                        ),
                      );
                      if (code != null) {
                        deviceCodeController.text = code;
                        debugPrint('Letto: $code');
                      }
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Compilare il campo codice veicolo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: drumController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(labelText: "Numero ripiano"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Compilare il campo Numero ripiano';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: sectorController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(labelText: "Numero settore"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Compilare il campo Numero settore';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Presente nel distributore",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Switch(
                    value: holder,
                    activeColor: Colors.deepPurple,
                    onChanged: (bool value) {
                      setState(() {
                        holder = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'unique_add_machine_button',
        onPressed: () async {
          bool validate = _formKey.currentState!.validate();
          if (validate) {
            Map<String, Object> response = await deviceService.updateDevice(
              widget.ipValue,
              widget.device["DeviceId"],
              deviceCodeController.text,
              int.parse(drumController.text),
              int.parse(sectorController.text),
              holder,
            );
            if (response["status"] == 200) {
              Navigator.pop(context);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response["response"].toString())),
            );
            code = "";
          }
        },
        label: const Text("Aggiorna il dispositivo"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(180),
          side: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}
