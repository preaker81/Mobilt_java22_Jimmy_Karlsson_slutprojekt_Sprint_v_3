import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUser(String username, String password) async {
    var bytes = utf8.encode(password); // data being hashed
    var digest = sha256.convert(bytes); // Hashing Process

    await _firestore.collection("users").add({
      "username": username,
      "password": digest.toString(), // Storing the hashed password
    });
  }

  Future<bool> validateUser(String username, String password) async {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    var hashedPassword = digest.toString();

    var querySnapshot = await _firestore
        .collection("users")
        .where("username", isEqualTo: username)
        .where("password", isEqualTo: hashedPassword)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> addFavoriteCard(
      String username, Map<String, dynamic> cardData) async {
    // Use the unique card "id" as the document identifier
    var cardId = cardData['id'];

    // Check if the card already exists in the 'favorites' collection
    DocumentSnapshot cardSnapshot =
        await _firestore.collection('favorites').doc(cardId).get();

    // Update or Set the card data in 'favorites'
    if (cardSnapshot.exists) {
      await _firestore.collection('favorites').doc(cardId).update({
        'users': FieldValue.arrayUnion([username]),
      });
    } else {
      cardData['users'] = [username]; // Initialize the 'users' array
      await _firestore.collection('favorites').doc(cardId).set(cardData);
    }
  }

  Future<bool> isFavoriteCard(String username, String cardId) async {
    DocumentSnapshot cardSnapshot =
        await _firestore.collection('favorites').doc(cardId).get();

    if (cardSnapshot.exists) {
      var data =
          cardSnapshot.data() as Map<String, dynamic>?; // Explicit casting here
      if (data != null) {
        List<dynamic> users = data['users'] as List<dynamic>? ?? [];
        return users.contains(username);
      }
    }
    return false;
  }

  Future<void> removeUserFromFavorite(String username, String cardId) async {
    await _firestore.collection('favorites').doc(cardId).update({
      'users': FieldValue.arrayRemove([username]),
    });
  }

  Future<List<Map<String, dynamic>>> fetchFavoriteCards(String username) async {
    List<Map<String, dynamic>> favoriteCards = [];

    QuerySnapshot snapshot = await _firestore.collection('favorites').get();
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      List<dynamic> users = data['users'] as List<dynamic>? ?? [];
      if (users.contains(username)) {
        favoriteCards.add(data);
      }
    }

    return favoriteCards;
  }
}
