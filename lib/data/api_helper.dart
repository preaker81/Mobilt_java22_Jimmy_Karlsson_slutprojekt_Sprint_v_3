import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHelper {
  final String baseUrl = 'https://api.scryfall.com';

  Future<Map<String, dynamic>> fetchCards({
    String? searchString,
    String? minCmc,
    String? maxCmc,
  }) async {
    // Properly encoding the search string
    String query = Uri.encodeFull(searchString ?? '');

    // Create the full URL
    String url = '$baseUrl/cards/search?q=$query';

    if (minCmc != null) {
      url += "&cmc>=${minCmc}";
    }
    if (maxCmc != null) {
      url += "&cmc<=${maxCmc}";
    }

    // Make the GET request
    final response = await http.get(Uri.parse(url));

    // Check the status code before proceeding
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("Status code: ${response.statusCode}");
      print("Error message: ${response.body}");
      throw Exception('Failed to load cards');
    }
  }
}
