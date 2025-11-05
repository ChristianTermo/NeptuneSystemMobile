import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:neptunesystem_mobile/screen/scan_code_page.dart';
import 'package:neptunesystem_mobile/services/navigator_service.dart';
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';

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
  List<dynamic> devices = [];
  List<dynamic> positionBusy = [];

  final TextEditingController deviceIdController = TextEditingController();
  final TextEditingController deviceCodeController = TextEditingController();
  final TextEditingController drumController = TextEditingController();
  final TextEditingController sectorController = TextEditingController();

  Future<void> getPositionBusy() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final httpCode;
      final body;

      final response = await http.get(Uri.parse('${widget.ipValue}/Devices'));
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
          for (var device in devices) {
            var position =
                device["DrumId"].toString() + device["SectorId"].toString();
            print('position: $position');
            positionBusy.add(position);
          }
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

  Future<void> addNewCar() async {
    try {
      final httpCode;
      final body;

      final payload = [
        {
          "Location": "DrumId-SectorId",
          "Status": "OK",
          "DeviceId": deviceIdController.text,
          "SectorId": int.parse(sectorController.text),
          "DeviceDetail": null,
          "DeviceType": null,
          "NominalNumber": 1,
          "DeviceBarCode": "",
          "MachineId": "S2",
          "TemporaryOwner": null,
          "ExpirationDate": "",
          "Holder": true,
          "EcpCode": deviceCodeController.text,
          "DrumId": int.parse(drumController.text),
        },
      ];

      print("payload + $payload");
      print(drumController.text + sectorController.text);

      await getPositionBusy();
      if (positionBusy.contains(drumController.text + sectorController.text)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Casella già occupata!')));
        return;
      }

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
                decoration: InputDecoration(labelText: "Id del veicolo"),
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
                decoration: InputDecoration(
                  labelText: "Codice veicolo",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () async {
                      final code = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => const ScanCodePage(
                                allowDecimal:
                                    false, 
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
