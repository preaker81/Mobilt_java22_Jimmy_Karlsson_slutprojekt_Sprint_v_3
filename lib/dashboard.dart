import 'package:flutter/material.dart';
import 'package:mtg_companion/login.dart';
import 'package:mtg_companion/search_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mtg_companion/data/api_helper.dart';
import 'package:mtg_companion/data/firestore_helper.dart';

// DashboardScreen is a StatefulWidget to handle state changes
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

// _DashboardScreenState is the mutable state for DashboardScreen
class _DashboardScreenState extends State<DashboardScreen> {
  // Controller for the search TextField
  final TextEditingController searchStringController = TextEditingController();

  // Helpers for API and Firestore operations
  final apiHelper = ApiHelper();
  final firestoreHelper = FirestoreHelper();

  // Asynchronously handle logging out
  Future<void> _logout(BuildContext context) async {
    // Retrieve SharedPreferences instance
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    // Navigate to LoginScreen and remove all other screens from the stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  // Handle back press with custom logic
  Future<bool> _onWillPop(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');

    if (isLoggedIn == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are already logged in.')),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Custom back press handling
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Card Search'),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: searchStringController,
                decoration:
                    const InputDecoration(labelText: 'Search by string'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Fetch cards from API
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
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      // Fetch favorite cards
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String? username = prefs.getString('username');

                      if (username != null) {
                        final favoriteCards =
                            await firestoreHelper.fetchFavoriteCards(username);

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
                                cards: {'data': favoriteCards},
                                isFavorites: true,
                              ),
                            ),
                          );
                        }
                      } else {
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
