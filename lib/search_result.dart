import 'package:flutter/material.dart';

class SearchResultScreen extends StatelessWidget {
  final Map<String, dynamic> cards;

  SearchResultScreen({required this.cards});

  @override
  Widget build(BuildContext context) {
    List<dynamic>? cardData = cards['data']; // Can be null

    return Scaffold(
      appBar: AppBar(title: Text('Search Results')),
      body: ListView.builder(
        itemCount: cardData?.length ?? 0, // Use 0 if cardData is null
        itemBuilder: (context, index) {
          var currentCard = cardData?[index]; // Can be null
          var name = currentCard?['name'] ??
              'Unknown'; // Use 'Unknown' if currentCard is null
          var imageUris = currentCard?['image_uris']; // Can be null
          var normalImageUrl = imageUris?['normal']; // Can be null

          return ListTile(
            title: Text(name),
            leading: normalImageUrl != null
                ? Image.network(normalImageUrl)
                : null, // Only show image if URL is not null
          );
        },
      ),
    );
  }
}
