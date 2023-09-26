import 'package:flutter/material.dart';
import 'package:mtg_companion/login.dart';
import 'package:mtg_companion/search_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mtg_companion/data/api_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController searchStringController = TextEditingController();
  final apiHelper = ApiHelper();

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');

    if (isLoggedIn == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are already logged in.')),
      );
      return false; // Cancel the pop operation
    }
    return true; // Allow the pop operation
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            TextButton(
              onPressed: () => _logout(context),
              child: const Text(
                'Log out',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Stretch to full width
            children: [
              TextField(
                controller: searchStringController,
                decoration:
                    const InputDecoration(labelText: 'Search by string'),
              ),
              // Removed dropdowns
              // Center the search button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final cards = await apiHelper.fetchCards(
                        searchString: searchStringController.text,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SearchResultScreen(cards: cards),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to fetch cards')),
                      );
                    }
                  },
                  child: const Text('Search'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
