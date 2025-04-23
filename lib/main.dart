import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:neptunesystem_mobile/screen/home.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 Future<Database> initializeDb() async {
    return openDatabase(
      join(await getDatabasesPath(), 'neptunesystemmobile_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE machines(machineid TEXT PRIMARY KEY, ip_address TEXT)',
        );
      },
      version: 1,
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const title = 'Neptune System';
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
         home: FutureBuilder<Database>(
        future: initializeDb(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Errore: ${snapshot.error}"));
          } else {
            return MyHomePage(title: title, database: snapshot.data!);
          }
        },
      ),
    );
  }
}




