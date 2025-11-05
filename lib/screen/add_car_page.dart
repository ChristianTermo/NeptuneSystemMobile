import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neptunesystem_mobile/screen/scan_code_page.dart';
import 'package:neptunesystem_mobile/services/device_service.dart';

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
  DeviceService deviceService = DeviceService();
  String code = "";

  final TextEditingController deviceIdController = TextEditingController();
  final TextEditingController deviceCodeController = TextEditingController();
  final TextEditingController drumController = TextEditingController();
  final TextEditingController sectorController = TextEditingController();

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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'unique_add_machine_button',
        onPressed: () async {
          bool validate = _formKey.currentState!.validate();
          if (validate) {
            Map<String, Object> response = await deviceService.addNewCar(
              widget.ipValue,
              deviceIdController.text,
              deviceCodeController.text,
              int.parse(drumController.text),
              int.parse(sectorController.text),
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
