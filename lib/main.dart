import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mtg_companion/firebase_options.dart';
import 'login.dart'; // import the login screen
import 'new_account.dart'; // import the new account screen
import 'dashboard.dart'; // import the dashboard screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blank App',
      initialRoute: '/login', // Set the initial route as '/login'
      routes: {
        '/login': (context) => LoginScreen(),
        '/new_account': (context) => NewAccountScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Removed the 'home' property because 'initialRoute' is set
    );
  }
}
