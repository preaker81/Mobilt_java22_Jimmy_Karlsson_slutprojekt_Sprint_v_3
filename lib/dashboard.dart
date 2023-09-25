import 'package:flutter/material.dart';
import 'package:mtg_companion/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');

    if (isLoggedIn == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are already logged in.')),
      );
      return false; // Cancel the pop operation.
    }
    return true; // Allow the pop operation.
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(title: Text('Dashboard')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => _logout(context),
            child: Text('Log out'),
          ),
        ),
      ),
    );
  }
}
