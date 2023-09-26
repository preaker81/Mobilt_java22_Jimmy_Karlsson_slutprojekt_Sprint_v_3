import 'package:flutter/material.dart';
import 'package:mtg_companion/login.dart';
import 'package:mtg_companion/search_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mtg_companion/data/api_helper.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? minCmcValue; // Default value is null, so the hint will show
  String? maxCmcValue; // Default value is null, so the hint will show
  final TextEditingController searchStringController = TextEditingController();
  final apiHelper = ApiHelper();

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
        const SnackBar(content: Text('You are already logged in.')),
      );
      return false; // Cancel the pop operation
    }
    return true; // Allow the pop operation
  }

  @override
  Widget build(BuildContext context) {
    // Generate the list of CMC values beforehand
    var minCmcItems = List<String>.generate(16, (i) => i.toString());
    var maxCmcItems = List<String>.generate(21, (i) => i.toString())
      ..add('1000000');

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: searchStringController,
                decoration: InputDecoration(labelText: 'Search by string'),
              ),
              DropdownButton<String>(
                hint: const Text('Select color'),
                items: ['White', 'Blue', 'Black', 'Red', 'Green']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
              ),
              // CMC dropdowns in a Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: minCmcValue,
                      hint: const Text('Min CMC'),
                      items: minCmcItems.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          minCmcValue = newValue;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0), // Gap between dropdowns
                  Expanded(
                    child: DropdownButton<String>(
                      value: maxCmcValue,
                      hint: const Text('Max CMC'),
                      items: maxCmcItems.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          maxCmcValue = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
              DropdownButton<String>(
                hint: const Text('Select card type'),
                items: [
                  'Creature',
                  'Instant',
                  'Sorcery',
                  'Enchantment',
                  'Artifact',
                  'Land'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final cards = await apiHelper.fetchCards(
                      searchString: searchStringController.text,
                      minCmc: minCmcValue,
                      maxCmc: maxCmcValue,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultScreen(cards: cards),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to fetch cards')),
                    );
                  }
                },
                child: const Text('Search'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
