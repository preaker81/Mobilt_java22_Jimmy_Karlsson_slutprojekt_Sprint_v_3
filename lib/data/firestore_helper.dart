import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

/// A helper class for interacting with Firestore database.
class FirestoreHelper {
  // Instance of the Firestore database
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Adds a user to Firestore with hashed password.
  ///
  /// [username] and [password] are user credentials.
  Future<void> addUser(String username, String password) async {
    // Hash the password
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);

    // Add the user to Firestore
    await _firestore.collection("users").add({
      "username": username,
      "password": digest.toString(),
    });
  }

  /// Validates user credentials against stored data in Firestore.
  ///
  /// Returns `true` if the user is valid, otherwise returns `false`.
  Future<bool> validateUser(String username, String password) async {
    // Hash the password for comparison
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);

    // Query Firestore to validate the user
    var querySnapshot = await _firestore
        .collection("users")
        .where("username", isEqualTo: username)
        .where("password", isEqualTo: digest.toString())
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  /// Adds a card to the favorites collection.
  ///
  /// [username] is the username of the user who likes the card.
  /// [cardData] is a Map containing the card information.
  Future<void> addFavoriteCard(
      String username, Map<String, dynamic> cardData) async {
    // Get the unique card ID
    var cardId = cardData['id'];

    // Check if the card is already in the 'favorites' collection
    DocumentSnapshot cardSnapshot =
        await _firestore.collection('favorites').doc(cardId).get();

    // If the card exists, update its data; otherwise, add it to the collection
    if (cardSnapshot.exists) {
      await _firestore.collection('favorites').doc(cardId).update({
        'users': FieldValue.arrayUnion(
            [username]), // Add the username to the 'users' array
      });
    } else {
      cardData['users'] = [
        username
      ]; // Initialize the 'users' array with the username
      await _firestore.collection('favorites').doc(cardId).set(cardData);
    }
  }

  /// Checks if a card is a favorite for a user.
  ///
  /// [username] is the username of the user.
  /// [cardId] is the unique ID of the card.
  /// Returns `true` if the card is a favorite for the user, otherwise `false`.
  Future<bool> isFavoriteCard(String username, String cardId) async {
    DocumentSnapshot cardSnapshot =
        await _firestore.collection('favorites').doc(cardId).get();

    if (cardSnapshot.exists) {
      var data =
          cardSnapshot.data() as Map<String, dynamic>?; // Explicit casting
      if (data != null) {
        List<dynamic> users = data['users'] as List<dynamic>? ?? [];
        return users
            .contains(username); // Check if username is in the 'users' array
      }
    }
    return false;
  }

  /// Removes a user from the favorite list of a card.
  ///
  /// [username] is the username of the user.
  /// [cardId] is the unique ID of the card.
  Future<void> removeUserFromFavorite(String username, String cardId) async {
    await _firestore.collection('favorites').doc(cardId).update({
      'users': FieldValue.arrayRemove(
          [username]), // Remove the username from the 'users' array
    });
  }

  /// Fetches all favorite cards for a user.
  ///
  /// [username] is the username of the user.
  /// Returns a `List<Map<String, dynamic>>` containing all the favorite cards for the user.
  Future<List<Map<String, dynamic>>> fetchFavoriteCards(String username) async {
    List<Map<String, dynamic>> favoriteCards = [];

    QuerySnapshot snapshot = await _firestore.collection('favorites').get();
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      List<dynamic> users = data['users'] as List<dynamic>? ?? [];
      if (users.contains(username)) {
        // If username is in the 'users' array, add card to list
        favoriteCards.add(data);
      }
    }

    return favoriteCards;
  }
}
