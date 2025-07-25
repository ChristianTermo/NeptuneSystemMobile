import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportPage extends StatefulWidget {
  final String ipValue;
  final String machineid;

  const ReportPage({
    super.key,
    required this.ipValue,
    required this.machineid,
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<dynamic> events = [];
  List<dynamic> filteredEvents = [];
  List<List<dynamic>> rows = [];
  bool isLoading = false;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getEvents();
  }

  Future<void> getEvents() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final httpCode;
      final body;

      final response = await http.get(
        Uri.parse('${widget.ipValue}/api/getEvents'),
      );
      httpCode = response.statusCode;
      body = response.body;

      print("📡 HTTP Code: $httpCode");
      print("📜 Body: $body");

      if (body == '[]') {
        setState(() {
          errorMessage = "Nessun report disponibile";
          isLoading = false;
        });
      }

      if (httpCode == 200) {
        setState(() {
          events = json.decode(body);
          filteredEvents = events;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              "Macchina non raggiungibile"
              ' $httpCode $body';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Errore di connessione: $e";
        isLoading = false;
      });
    }
  }

  String formatDate(String rawDate) {
    try {
      if (rawDate.isEmpty) return 'Data non disponibile';
      DateTime parsedDate = DateTime.parse(rawDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
    } catch (e) {
      print("Errore nel parsing della data: $rawDate");
      return 'Formato data non valido';
    }
  }

  Future<bool> exportToCSV() async {
    List<List<dynamic>> rows = [
      ["EventType", "TimeStamp", "EmployeeId", "Device"],
    ];

    for (var event in events) {
      rows.add([
        event["eventType"],
        event["eventTimeStamp"],
        event["employee"],
        event["objectId"],
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    String? downloadPath;

    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.request().isGranted) {
        downloadPath = "/storage/emulated/0/Download";
      } else {
        print("❌ Permesso negato: MANAGE_EXTERNAL_STORAGE");
        openAppSettings();
        return false;
      }
    } else if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      downloadPath = dir.path;
    } else {
      print("❌ Piattaforma non supportata");
      return false;
    }

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now);
    String fileName = "export_$formattedDate.csv";

    if (downloadPath != null) {
      final file = File('$downloadPath/$fileName');

      await file.writeAsString(csv);

      print("✅ CSV salvato in: ${file.path}");
      return true;
    } else {
      print("❌ Impossibile determinare il percorso di salvataggio");
      return false;
    }
  }

  void filterEvents(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredEvents = events;
      } else {
        filteredEvents =
            events.where((event) {
              return event['eventType'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  event['objectId'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  event['employee'].toString().toLowerCase().contains(
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
                  if (await exportToCSV())
                    {
                      Future.delayed(Duration(milliseconds: 300), () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Download del file eseguito con successo',
                            ),
                          ),
                        );
                      }),
                    }
                  else
                    {
                      Future.delayed(Duration(milliseconds: 300), () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Download del file non riuscito'),
                          ),
                        );
                      }),
                    },
                },
            icon: const Icon(Icons.download),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: TextField(
              controller: searchController,
              onChanged: filterEvents,
              decoration: InputDecoration(
                hintText: "Cerca evento...",
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
              : ListView.builder(
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];

                  String formattedDate = formatDate(
                    event['EventTimeStamp'] ?? '',
                  );
                  String eventType = event['EventType'] ?? 'N/A';
                  String objectId = event['ObjectId'] ?? 'N/A';
                  String employee = event['Employee'] ?? 'N/A';

                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      title: Text("Evento: $eventType"),
                      subtitle: Text("Dispositivo: $objectId"),
                      trailing: Text(
                        "$formattedDate\nUtente: $employee",
                        textAlign: TextAlign.right,
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
