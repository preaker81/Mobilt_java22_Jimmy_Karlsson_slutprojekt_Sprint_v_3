import 'package:flutter/material.dart';
import 'package:mtg_companion/login.dart';
import 'package:mtg_companion/search_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mtg_companion/data/api_helper.dart';
import 'package:mtg_companion/data/firestore_helper.dart'; // New import

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController searchStringController = TextEditingController();
  final apiHelper = ApiHelper();
  final firestoreHelper = FirestoreHelper(); // New variable

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
              // Center the search and favorites buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final cards = await apiHelper.fetchCards(
                          searchString: searchStringController.text,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchResultScreen(
                              cards: cards,
                              isFavorites: false,
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to fetch cards')),
                        );
                      }
                    },
                    child: const Text('Search'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String? username = prefs.getString('username');
                      if (username != null) {
                        // fetchFavoriteCards() fetches favorite cards for the user
                        final favoriteCards = await FirestoreHelper()
                            .fetchFavoriteCards(username);

                        if (favoriteCards.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('You have no favorites yet')),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchResultScreen(
                                cards: {
                                  'data': favoriteCards
                                }, // wrapping it in a Map
                                isFavorites: true,
                              ),
                            ),
                          );
                        }
                      } else {
                        // Handle user not found case, maybe by showing a SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User not found')),
                        );
                      }
                    },
                    child: const Text('Favorites'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
