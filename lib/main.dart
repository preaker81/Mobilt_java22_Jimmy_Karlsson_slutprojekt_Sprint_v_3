import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mtg_companion/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //firestore ------------------------------------------------------------------
  final FirebaseFirestore storedb = FirebaseFirestore.instance;
  final city = <String, String>{
    "name": "ALRIK",
    "age": "31",
    "country": "Sweden"
  };
  print(storedb);
  storedb
      .collection("cities")
      .doc("LA")
      .set(city)
      .onError((e, _) => print("Error writing document: $e"));
  // ---------------------------------------------------------------------------

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blank App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Blank Page'),
      ),
      body: const Center(
        child: Text(''), // Blank text to have a "blank" body
      ),
    );
  }
}
