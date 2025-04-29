import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:neptunesystem_mobile/screen/report_page.dart';
import 'package:neptunesystem_mobile/screen/select_device.dart';

class MachineManagement extends StatefulWidget {
  const MachineManagement({
    super.key,
    required this.machineid,
    required this.ipValue,
    required this.sshClient,
    required this.onlyLocal,
  });

  final String ipValue;
  final String machineid;
  final SSHClient? sshClient;
  final bool onlyLocal;

  @override
  State<MachineManagement> createState() => MachineManagementState();
}

class MachineManagementState extends State<MachineManagement> {
  Future<void> restartSystem() async {
    try {
      final httpCode;
      final body;

      if (widget.onlyLocal) {
        final response = await http.get(
          Uri.parse('http://${widget.ipValue}:8080/RestartSystem'),
        );
        httpCode = response.statusCode;
        body = response.body;
      } else {
        if (widget.sshClient != null) {
          final session = await widget.sshClient?.execute(
            'curl -s -w "HTTP_CODE:%{http_code}" http://${widget.ipValue}:8080/RestartSystem',
          );

          final result = await session?.stdout.map(utf8.decode).join();
          final parts = result?.split("HTTP_CODE:");
          body = parts![0].trim();
          final httpCodeString = parts.length > 1 ? parts[1].trim() : "N/A";

          httpCode = int.tryParse(httpCodeString);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Connessione SSH non riuscita')),
          );
          return;
        }
      }

      if (httpCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Macchina riavviata con successo')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Macchina non raggiungibile')));
      }
    } on TimeoutException {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Timeout: la macchina non ha risposto entro un tempo ragionevole')));
    } on http.ClientException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Macchina non raggiungibile')));
    } catch (e) {
      print("❌ Macchina non raggiungibile: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Macchina non raggiungibile: $e')));
    }
  }

  Future<void> goToEventsPage() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ReportPage(
              machineid: widget.machineid,
              ipValue: widget.ipValue,
              onlyLocal: widget.onlyLocal,
              sshClient: widget.sshClient,
            ),
      ),
    );
  }

  Future<void> goToRetreatPage() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SelectDevice(
              machineid: widget.machineid,
              ipValue: widget.ipValue,
              onlyLocal: widget.onlyLocal,
              sshClient: widget.sshClient,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.machineid), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildMachineOption(
                  'Report',
                  Icons.insert_chart_outlined, // Icona per report
                  goToEventsPage,
                ),
                _buildMachineOption(
                  'Prelievi',
                  Icons.assignment_return_outlined, // Icona per prelievi
                  goToRetreatPage,
                ),
                _buildMachineOption(
                  'Riavvio Macchina',
                  Icons.restart_alt, // Icona per il riavvio
                  restartSystem,
                ),
                _buildMachineOption(
                  'Macchina',
                  Icons.settings, // Icona per impostazioni
                  goToEventsPage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineOption(
    String label,
    IconData icon,
    Future<void> Function() function,
  ) {
    return Column(
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: FloatingActionButton(
            onPressed: () async {
              await function();
            },
            backgroundColor: Colors.white,
            elevation: 5,
            child: Icon(icon, size: 40, color: Colors.black),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
