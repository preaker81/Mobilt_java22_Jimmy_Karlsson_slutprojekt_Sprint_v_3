import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/firestore_helper.dart';

// LoginScreen Widget - Represents the login screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

// _LoginScreenState - Stateful logic for LoginScreen.
class _LoginScreenState extends State<LoginScreen> {
  // Controllers for text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoggedInStatus();
  }

  // Check if the user is already logged in.
  Future<void> _checkLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');
    if (isLoggedIn == true) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  // Login functionality.
  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    FirestoreHelper helper = FirestoreHelper();
    bool isValid = await helper.validateUser(username, password);

    if (isValid) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: OrientationBuilder(
        builder: (context, orientation) => (orientation == Orientation.portrait)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _buildLoginUI(),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _buildLoginUI(),
                ),
              ),
      ),
    );
  }

  // Build the UI components for login.
  List<Widget> _buildLoginUI() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          controller: _usernameController,
          decoration: const InputDecoration(hintText: 'Username'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: TextField(
          controller: _passwordController,
          decoration: const InputDecoration(hintText: 'Password'),
          obscureText: true,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/new_account');
              },
              child: const Text('New User'),
            ),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 21, 248, 32),
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    ];
  }
}
