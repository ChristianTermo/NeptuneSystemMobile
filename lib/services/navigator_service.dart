import 'package:flutter/material.dart';
import 'package:neptunesystem_mobile/data/entity/machine.dart';
import 'package:neptunesystem_mobile/screen/add_planning_page.dart';
import 'package:neptunesystem_mobile/screen/home.dart';
import 'package:neptunesystem_mobile/screen/report_page.dart';
import 'package:neptunesystem_mobile/screen/add_machine_form.dart';
import 'package:neptunesystem_mobile/screen/report_planning_page.dart';
import 'package:neptunesystem_mobile/screen/select_operation.dart';
import 'package:neptunesystem_mobile/screen/select_device.dart';
import 'package:neptunesystem_mobile/screen/select_employee.dart';
import 'package:neptunesystem_mobile/main.dart';
import 'package:neptunesystem_mobile/screen/select_operation_planning.dart';
import 'package:sqflite/sqflite.dart';

class NavigatorService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> goToEventsPage({
    required String machineid,
    required String ipValue,
  }) async {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder:
            (context) => ReportPage(machineid: machineid, ipValue: ipValue),
      ),
    );
  }

  static Future<void> goToRetreatPage({
    required String machineid,
    required String ipValue,
  }) async {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder:
            (context) => SelectDevice(machineid: machineid, ipValue: ipValue),
      ),
    );
  }

  static Future<void> goToSelectEmployeePage({
    required String machineid,
    required String ipValue,
    required dynamic selectedDevice,
  }) async {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder:
            (context) => SelectEmployee(
              ipValue: ipValue,
              machineid: machineid,
              selectedDevice: selectedDevice,
            ),
      ),
    );
  }

  static Future<void> goToHomePage() async {
    final Database database = await MyApp().initializeDb();

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder:
            (context) =>
                MyHomePage(title: 'Neptune System', database: database),
      ),
    );
  }

  static Future<void> goToManagementPage({
    required String machineid,
    required String ipValue,
  }) async {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder:
            (context) =>
                SelectOperation(machineid: machineid, ipValue: ipValue),
      ),
    );
  }

  static Future<void> goToFormPage({
    required List<Machine> machinelist,
    required dynamic database,
    required VoidCallback onReturn,
  }) async {
    final result = await navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder:
            (context) =>
                AddMachineForm(machinelist: machinelist, database: database),
      ),
    );

    if (result == true) {
      onReturn();
    }
  }

  static Future<void> goToPlanningPage({
    required String machineid,
    required String ipValue,
  }) async {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder:
            (context) => PlanningPage(ipValue: ipValue, machineid: machineid),
      ),
    );
  }

  static Future<void> goToSelectOperationPlanningPage({
    required String machineid,
    required String ipValue,
  }) async {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder:
            (context) =>
                SelectOperationPlanning(ipValue: ipValue, machineid: machineid),
      ),
    );
  }

  static Future<void> goToReportPlanningPage({
    required String machineid,
    required String ipValue,
  }) async {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder:
            (context) =>
                ReportPlanningPage(ipValue: ipValue, machineid: machineid),
      ),
    );
  }
}
