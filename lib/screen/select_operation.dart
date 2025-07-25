import 'dart:async';
import 'package:neptunesystem_mobile/services/navigator_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SelectOperation extends StatefulWidget {
  const SelectOperation({
    super.key,
    required this.machineid,
    required this.ipValue,
  });

  final String ipValue;
  final String machineid;

  @override
  State<SelectOperation> createState() => SelectOperationState();
}

class SelectOperationState extends State<SelectOperation> {
  Future<void> restartSystem() async {
    try {
      final httpCode;
      final body;

      final response = await http.get(
        Uri.parse('${widget.ipValue}/RestartSystem'),
      );
      httpCode = response.statusCode;
      body = response.body;

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
      print("❌ Macchina non raggiungibile: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Macchina non raggiungibile: $e')));
    }
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
                  Icons.insert_chart_outlined, 
                  () => NavigatorService.goToEventsPage(
                    ipValue: widget.ipValue,
                    machineid: widget.machineid,
                  ),
                ),
                _buildMachineOption(
                  'Prelievi',
                  Icons.assignment_return_outlined, 
                  () => NavigatorService.goToRetreatPage(
                    ipValue: widget.ipValue,
                    machineid: widget.machineid,
                  ),
                ),
                _buildMachineOption(
                  'Riavvio Macchina',
                  Icons.restart_alt, 
                  restartSystem,
                ),
                _buildMachineOption(
                  'Prenotazioni',
                  Icons.settings,
                  () => NavigatorService.goToSelectOperationPlanningPage(
                    ipValue: widget.ipValue,
                    machineid: widget.machineid,
                  ),
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
