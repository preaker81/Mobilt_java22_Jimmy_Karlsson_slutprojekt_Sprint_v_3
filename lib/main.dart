import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mtg_companion/firebase_options.dart';

// Import custom screens
import 'login.dart'; // Login screen
import 'new_account.dart'; // New Account screen
import 'dashboard.dart'; // Dashboard screen

/// The `main()` function serves as the entry point for the Flutter application.
/// It initializes Firebase before running the app.
void main() async {
  // Ensures that the Flutter widgets library is properly initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the application
  runApp(const MyApp());
}

/// `MyApp` is the root widget of the application.
///
/// This is a StatelessWidget, meaning it is immutable. It sets up routes and app-wide theme.
class MyApp extends StatelessWidget {
  // Constructor for MyApp widget
  const MyApp({super.key});

  /// Builds the widget tree for `MyApp`.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mtg Companion', // Title of the app
      debugShowCheckedModeBanner: false, // Remove debug banner

      // Set the initial route to login screen
      initialRoute: '/login',

      // Define routes and map them to corresponding screens
      routes: {
        '/login': (context) => const LoginScreen(),
        '/new_account': (context) => const NewAccountScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },

      // Define the app-wide theme
      theme: ThemeData(
        // Set the color scheme based on a seed color
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),

        // Configure the AppBar theme
        appBarTheme: const AppBarTheme(
          backgroundColor:
              Colors.blueGrey, // Set AppBar background to light blue
        ),

        useMaterial3: true, // Use the Material 3 design system
      ),
    );
  }
}
