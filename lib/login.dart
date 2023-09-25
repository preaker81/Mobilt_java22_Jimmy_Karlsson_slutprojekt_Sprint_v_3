import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/firestore_helper.dart'; // Adjust this import as needed

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoggedInStatus();
  }

  void _checkLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');
    if (isLoggedIn == true) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    FirestoreHelper helper = FirestoreHelper();
    bool isValid = await helper.validateUser(username, password);

    if (isValid) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Column(
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(hintText: 'Username'),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(hintText: 'Password'),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: _login,
            child: Text('Login'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/new_account');
            },
            child: Text('New User'),
          ),
        ],
      ),
    );
  }
}
