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
    await _firestore
        .collection("users")
        .doc(username)
        .collection("favorites")
        .add(cardData);
  }
}
