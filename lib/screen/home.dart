import 'package:flutter/material.dart';
import 'package:neptunesystem_mobile/data/entity/machine.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:neptunesystem_mobile/services/machine_service.dart';
import 'package:neptunesystem_mobile/services/navigator_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.database});

  final String title;
  final Database database;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Machine> machinelist = [];
  bool isConnecting = true;

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  Future<void> _loadMachines() async {
    print("Ricarico la lista delle macchine...");
    machinelist.clear();

    MachineService machineService = MachineService(database: widget.database);

    final machineMaps = await machineService.getMachines();
    if (!mounted) return;

    setState(() {
      isConnecting = false;
      for (Map<String, Object?> map in machineMaps) {
        Machine machine = Machine.fromMap(map);
        machinelist.add(machine);
      }
    });

    if (machinelist.length == 1) {
      NavigatorService.goToManagementPage(
        machineid: machinelist.first.machineid,
        ipValue: machinelist.first.ip_address,
        isTruckingOn: machinelist.first.isTruckingOn,
      );
    }

    print("machinelist: $machinelist");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image(
            image: AssetImage('assets/128x128.png'),
            height: 60,
            width: 60,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            isConnecting
                ? const Center(child: CircularProgressIndicator())
                : machinelist.isEmpty
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 16),
                      Text(
                        'Nessuna macchina trovata',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tocca il pulsante + per aggiungere una macchina',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                )
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20, // distanza orizzontale tra le card
                      runSpacing: 20, // distanza verticale tra le righe
                      children:
                          machinelist.map((machine) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 150,
                                  height: 200,
                                  child: GestureDetector(
                                    onLongPress: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text(
                                                'Vuoi eliminare questa macchina?',
                                              ),
                                              actions: [
                                                IconButton(
                                                  onPressed: () async {
                                                    MachineService
                                                    machineService =
                                                        MachineService(
                                                          database:
                                                              widget.database,
                                                        );
                                                    await machineService
                                                        .deleteMachine(
                                                          machine.machineid,
                                                        );
                                                        await _loadMachines();
                                                    Navigator.pop(context);
                                                  },

                                                  icon: const Icon(Icons.check),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                    child: FloatingActionButton(
                                      onPressed: () {
                                        NavigatorService.goToManagementPage(
                                          machineid: machine.machineid,
                                          ipValue: machine.ip_address,
                                          isTruckingOn: machine.isTruckingOn,
                                        );
                                      },

                                      backgroundColor: Colors.white,
                                      elevation: 5,
                                      child:
                                          machine.machineid.contains('900')
                                              ? Image.asset(
                                                'assets/MACH900.png',
                                                fit: BoxFit.contain,
                                              )
                                              : machine.machineid.contains(
                                                'MDS',
                                              )
                                              ? Image.asset(
                                                'assets/MDS.png',
                                                fit: BoxFit.contain,
                                              )
                                              : machine.machineid.contains('S2')
                                              ? Image.asset(
                                                'assets/S2.png',
                                                fit: BoxFit.contain,
                                              )
                                              : const SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  machine.machineid,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NavigatorService.goToFormPage(
            machinelist: machinelist,
            database: widget.database,
            onReturn: () {
              if (mounted) _loadMachines();
            },
          );
        },
        tooltip: 'Aggiungi',
        child: const Icon(Icons.add),
      ),
    );
  }
}
