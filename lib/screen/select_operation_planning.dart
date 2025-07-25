import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:neptunesystem_mobile/services/navigator_service.dart';

class SelectOperationPlanning extends StatefulWidget {
  const SelectOperationPlanning({
    super.key,
    required this.machineid,
    required this.ipValue,
  });

  final String ipValue;
  final String machineid;

  @override
  State<SelectOperationPlanning> createState() =>
      SelectOperationPlanningState();
}

class SelectOperationPlanningState extends State<SelectOperationPlanning> {
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
                  'Visualizza prenotazioni',
                  Icons.remove_red_eye,
                  () => NavigatorService.goToReportPlanningPage(
                    ipValue: widget.ipValue,
                    machineid: widget.machineid,
                  ),
                ),
                _buildMachineOption(
                  'Nuova prenotazione',
                  Icons.add,
                  () => NavigatorService.goToPlanningPage(
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
