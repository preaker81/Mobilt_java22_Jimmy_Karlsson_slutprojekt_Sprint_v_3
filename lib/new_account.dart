import 'package:flutter/material.dart';
import 'data/firestore_helper.dart'; // import FirestoreHelper

class NewAccountScreen extends StatefulWidget {
  @override
  _NewAccountScreenState createState() => _NewAccountScreenState();
}

class _NewAccountScreenState extends State<NewAccountScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirestoreHelper firestoreHelper = FirestoreHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create New Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (usernameController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty) {
                    await firestoreHelper.addUser(
                        usernameController.text, passwordController.text);
                    Navigator.pop(context); // Go back to the login screen
                  } else {
                    // You can show a dialog or snackbar here for failed validation
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800], // background
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text('Create New User',
                    style: TextStyle(color: Colors.black)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
