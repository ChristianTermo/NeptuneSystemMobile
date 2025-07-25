import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:neptunesystem_mobile/services/navigator_service.dart';
import 'package:uuid/uuid.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({
    super.key,
    required this.machineid,
    required this.ipValue,
  });

  final String ipValue;
  final String machineid;

  @override
  State<StatefulWidget> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  DateTime? startDateTime;
  DateTime? endDateTime;
  List<dynamic> employees = [];
  List<dynamic> filteredEmployee = [];
  Map<String, dynamic>? selectedEmployee;
  List<dynamic> devices = [];
  List<dynamic> filteredDevices = [];
  Map<String, dynamic>? selectedDevice;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> _selectDateTime({required bool isStart}) async {
    final now = DateTime.now();

    // 1. Seleziona la data
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (date == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Inserire una data valida')));
      return;
    }

    // 2. Seleziona l'orario
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (time == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('inserire un orario valido')));
      return;
    }

    final DateTime combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (combined.isBefore(now)) {
      print(combined);
      print(now);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('la data non può essere antecedente alla data odierna'),
        ),
      );
      return;
    }

    setState(() {
      if (isStart) {
        startDateTime = combined;
      } else {
        endDateTime = combined;

        if (startDateTime != null && endDateTime!.isBefore(startDateTime!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'La data di fine prenotazione non può essere antecedente a quella di inizio.',
              ),
            ),
          );
          endDateTime = null; // resetta l'orario di fine
        }
      }
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

  Future<void> getEmployeeForAssistantRetreat() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final httpCode;
      final body;

      final response = await http
          .get(Uri.parse('${widget.ipValue}/api/getEmployee'))
          .timeout(const Duration(seconds: 5));
      httpCode = response.statusCode;
      body = response.body;
      print("📡 HTTP Code: $httpCode");
      print("📜 Body: $body");

      if (body == '[]') {
        setState(() {
          errorMessage = "Lista utenti vuota";
          isLoading = false;
        });
      }

      if (httpCode == 200) {
        setState(() {
          employees = json.decode(body);
          filteredEmployee = employees;
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

  Future<void> addPlanning(dynamic employee, dynamic device) async {
    try {
      final httpCode;
      final body;
      var uuid = Uuid();

      final payload = {
        "deviceId": device["DeviceId"],
        "employeeId": employee["EmployeeId"],
        "planningDate": _formatDate(startDateTime),
        "StartPlan": _formatTime(startDateTime),
        "StopPlan": _formatTime(endDateTime),
        "PlanningId": uuid.v1(),
      };

      final response = await http.post(
        Uri.parse('${widget.ipValue}/Planning'),
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
      NavigatorService.goToHomePage();
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

  Future<void> _showEmployeePicker() async {
    await getEmployeeForAssistantRetreat();
    if (!mounted) return;
    if (errorMessage != '') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: filteredEmployee.length,
            itemBuilder: (context, index) {
              final employee = filteredEmployee[index];
              return ListTile(
                title: Text(employee['EmployeeName']),
                onTap: () {
                  setState(() {
                    selectedEmployee = employee;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showDevicePicker() async {
    await getDevices();
    if (!mounted) return;
    if (errorMessage != '') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: filteredDevices.length,
            itemBuilder: (context, index) {
              final device = filteredDevices[index];
              return ListTile(
                title: Text(device['ObjectId']),
                onTap: () {
                  setState(() {
                    selectedDevice = device;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Non selezionato';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Non selezionato';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ';
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return 'Non selezionato';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seleziona intervallo')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Data e ora di inizio:',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () => _selectDateTime(isStart: true),
              child: Text(
                _formatDateTime(startDateTime),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 50),
            Text(
              'Data e ora di fine:',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () => _selectDateTime(isStart: false),
              child: Text(
                _formatDateTime(endDateTime),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 50),
            Text(
              'Dispositivo:',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: _showDevicePicker,
              child: Text(
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                selectedDevice != null
                    ? selectedDevice!['ObjectId']
                    : 'Seleziona dispositivo',
              ),
            ),
            SizedBox(height: 50),
            Text(
              'Utente assegnatario:',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: _showEmployeePicker,
              child: Text(
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                selectedEmployee != null
                    ? selectedEmployee!['EmployeeName']
                    : 'Seleziona dipendente',
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'unique_add_machine_button',
        onPressed: () async {
          if (selectedDevice != null &&
              selectedEmployee != null &&
              startDateTime != null &&
              endDateTime != null) {
            await addPlanning(selectedEmployee, selectedDevice);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Valorizzare tutti i campi per inserire una prenotazione",
                ),
              ),
            );
            return;
          }
        },
        label: const Text("Aggiungi la prenotazione"),
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
