import 'dart:convert';
import 'package:http/http.dart' as http;

/// A helper class for making API requests to the Scryfall API.
class ApiHelper {
  // Base URL for the Scryfall API
  final String baseUrl = 'https://api.scryfall.com';

  /// Fetches card data from the Scryfall API.
  ///
  /// [searchString] is the query term used for the search.
  /// Returns a `Future<Map<String, dynamic>>` containing the search result.
  Future<Map<String, dynamic>> fetchCards({String? searchString}) async {
    // Properly encode the search string
    String query = Uri.encodeFull(searchString ?? '');

    // Construct the complete URL for the GET request
    String url = '$baseUrl/cards/search?q=$query';

    // Make the GET request
    final response = await http.get(Uri.parse(url));

    // Validate the status code before processing the response
    if (response.statusCode == 200) {
      // Decode the JSON response and return as a Map
      return json.decode(response.body);
    } else {
      // Log the error and throw an exception
      print("Status code: ${response.statusCode}");
      print("Error message: ${response.body}");
      throw Exception('Failed to load cards');
    }
  }
}
