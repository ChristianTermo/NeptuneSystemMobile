import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:neptunesystem_mobile/services/navigator_service.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key, required this.machineid, required this.ipValue});

  final String ipValue;
  final String machineid;

  @override
  State<AddCarPage> createState() => AddCarPageState();
}

class AddCarPageState extends State<AddCarPage> {
  bool isLoading = false;
  String errorMessage = '';
  final _formKey = GlobalKey<FormState>();

  final TextEditingController deviceIdController = TextEditingController();
  final TextEditingController deviceCodeController = TextEditingController();

  Future<void> addNewCar() async {
    try {
      final httpCode;
      final body;

      final payload = [
        {
          "Location": "DrumId-SectorId",
          "Status": "OK",
          "DeviceId": deviceIdController.text,
          "SectorId": 12,
          "DeviceDetail": null,
          "DeviceType": null,
          "NominalNumber": 1,
          "DeviceBarCode": "",
          "MachineId": "S2",
          "TemporaryOwner": null,
          "ExpirationDate": "",
          "Holder": true,
          "EcpCode": deviceCodeController.text,
          "DrumId": 1,
        },
      ];

      print("planningId $payload");

      print("payload + $payload");

      final response = await http.post(
        Uri.parse('${widget.ipValue}/Devices'),
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
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorMessage = "Errore di connessione: $e";
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registra un veicolo'),
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
                controller: deviceIdController,
                autofocus: true,
                decoration: InputDecoration(labelText: "id del veicolo"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Compilare il campo id del veicolo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: deviceCodeController,
                autofocus: true,
                decoration: InputDecoration(labelText: "codice veicolo"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Compilare il campo codice veicolo';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'unique_add_machine_button',
        onPressed: () async {
          await addNewCar();
        },
        label: const Text("Aggiungi la macchina"),
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
