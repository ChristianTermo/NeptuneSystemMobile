import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'dart:convert';

import 'package:neptunesystem_mobile/screen/report_page.dart';
import 'package:neptunesystem_mobile/screen/select_device.dart';

class MachineManagement extends StatefulWidget {
  const MachineManagement({
    super.key,
    required this.machineid,
    required this.ipValue,
    required this.sshClient,
  });

  final String ipValue;
  final String machineid;
  final SSHClient sshClient;

  @override
  State<MachineManagement> createState() => MachineManagementState();
}

class MachineManagementState extends State<MachineManagement> {
  Future<void> restartSystem() async {
    try {
      final session = await widget.sshClient.execute(
        'curl -s -w "HTTP_CODE:%{http_code}" http://${widget.ipValue}:8080/RestartSystem',
      );

      final result = await session.stdout.map(utf8.decode).join();
      final parts = result.split("HTTP_CODE:");
      final body = parts[0].trim();
      final httpCode = parts.length > 1 ? parts[1].trim() : "N/A";

      print("📡 HTTP Code: $httpCode");
      print("📜 Body: $body");

      if (httpCode == '200') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Macchina riavviata con successo')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Macchina non raggiungibile')));
      }
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
