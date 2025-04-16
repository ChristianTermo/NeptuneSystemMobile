import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:http/http.dart';
import 'package:neptunesystem_mobile/data/entity/machine.dart';
import 'package:neptunesystem_mobile/screen/machine_management.dart';
import 'package:sqflite/sqlite_api.dart';
import 'add_machine_form.dart';
import 'package:neptunesystem_mobile/services/machine_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.database});

  final String title;
  final Database database;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Machine> machinelist = [];
  SSHClient? sshClient;
  bool isConnecting = true; // Stato per la connessione SSH

  @override
  void initState() {
    super.initState();
    _loadMachines();
    _connectSSH();
  }

  Future<void> _loadMachines() async {
    print("Ricarico la lista delle macchine...");
    MachineService machineService = MachineService(database: widget.database);

    final machineMaps = await machineService.getMachines();

    setState(() {
      machinelist =
          machineMaps.map((map) {
            return Machine(
              machineid: map['machineid'] as String,
              ip_address: map['ip_address'] as String,
            );
          }).toList();
    });
  }

  Future<void> _connectSSH() async {
    try {
      final socket = await SSHSocket.connect('168.119.172.16', 22000);
      final client = SSHClient(
        socket,
        username: 'root',
        onPasswordRequest: () => 'RW9gJbnM9xtRxJXXgxqV',
      );

      setState(() {
        sshClient = client;
        isConnecting = false;
      });

      Future.delayed(Duration(milliseconds: 300), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connessione SSH riuscita')),
        );
      });
    } catch (e) {
      setState(() {
        isConnecting = false;
      });
      print("errore ssh  $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nella connessione SSH: $e')),
      );
    }
  }

  void goToManagementPage(String machineid, String ip_address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MachineManagement(
              machineid: machineid,
              ipValue: ip_address,
              sshClient: sshClient!,
            ),
      ),
    );
  }

  void goToFormPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddMachineForm(
              machinelist: machinelist,
              sshClient: sshClient!,
              database: widget.database,
            ),
      ),
    ).then((result) {
      if (result == true) {
        _loadMachines();
      }
    });
  }

  @override
  void dispose() {
    sshClient?.close();
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
                                                    machineService
                                                        .deleteMachine(
                                                          machine.machineid,
                                                        );
                                                    Navigator.pop(context);
                                                    await _loadMachines();
                                                    setState(() {});
                                                  },
                                                  icon: const Icon(Icons.check),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                    child: FloatingActionButton(
                                      onPressed: () {
                                        if (sshClient != null) {
                                          goToManagementPage(
                                            machine.machineid,
                                            machine.ip_address,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Non è stato possibile connettersi in ssh alla macchina',
                                              ),
                                            ),
                                          );
                                        }
                                      },

                                      backgroundColor: Colors.white,
                                      elevation: 5,
                                      child:
                                          machine.machineid.contains('900') ||
                                                  machine.machineid.contains(
                                                    'S2',
                                                  )
                                              ? Image.asset(
                                                'assets/MACH900.png',
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
          if (sshClient != null) {
            goToFormPage();
          }
        },
        tooltip: 'Aggiungi',
        child: const Icon(Icons.add),
      ),
    );
  }
}
