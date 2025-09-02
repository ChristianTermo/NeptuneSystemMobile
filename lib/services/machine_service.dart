import 'package:neptunesystem_mobile/data/entity/machine.dart';
import 'package:sqflite/sqlite_api.dart';

class MachineService {
  final Database database;

  const MachineService({required this.database});

  Future<List<Map<String, Object?>>> getMachines() async {
    final db = await database;

    final List<Map<String, Object?>> machineMaps = await db.query('machines');

    return machineMaps;
  }

  Future<void> insertMachine(Machine machine) async {
    final db = await database;

    await db.insert(
      'machines',
      machine.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMachine(String id) async {
    final db = await database;
    await db.delete('machines', where: 'machineid = ?', whereArgs: [id]);
  }

  
  Future<void> deleteAllMachine() async {
    final db = await database;
    await db.delete('machines');
  }

  Future<List<Map<String, Object?>>> findByid(String id) async {
    final db = await database;
    List<Map<String, Object?>> machine = await db.query('machines', where: 'machineid = ?', whereArgs: [id]);

    return machine;
  }
}
