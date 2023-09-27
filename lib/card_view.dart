import 'package:flutter/material.dart';

class CardView extends StatelessWidget {
  final dynamic cardData;

  CardView({required this.cardData});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          appBar: AppBar(title: Text(cardData['name'] ?? 'Unknown Card')),
          body: orientation == Orientation.portrait
              ? buildPortraitLayout()
              : buildLandscapeLayout(),
        );
      },
    );
  }

  Widget buildPortraitLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: buildCommonWidgets(true),
        ),
      ),
    );
  }

  Widget buildLandscapeLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Card image wrapped in SingleChildScrollView
        SingleChildScrollView(
          child: Image.network(
            cardData['image_uris']['normal'] ?? '',
            fit: BoxFit.cover,
          ),
        ),
        // Right side: Information Container
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: buildCommonWidgets(false),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> buildCommonWidgets(bool includeImage) {
    List<Widget> widgets = [];

    if (includeImage) {
      widgets.add(Image.network(cardData['image_uris']['normal'] ?? ''));
      widgets.add(Divider(thickness: 2));
    }

    widgets.addAll([
      // Name and Mana Cost
      Text(cardData['mana_cost'] ?? '', textAlign: TextAlign.left),
      Divider(thickness: 1),
      // Type Line
      Text(cardData['type_line'] ?? '', textAlign: TextAlign.left),
      Divider(thickness: 1),
      // Oracle Text
      Text(cardData['oracle_text'] ?? '', textAlign: TextAlign.left),
      Divider(thickness: 1),
      // Power and Toughness
      if (cardData['power'] != null || cardData['toughness'] != null)
        Text(
          '${cardData['power'] ?? ''} / ${cardData['toughness'] ?? ''}',
          textAlign: TextAlign.left,
        ),
      Divider(thickness: 1),
      // Artist
      Text(
        'Illustrated by ${cardData['artist'] ?? ''}',
        textAlign: TextAlign.left,
      ),
      Divider(thickness: 1),
      // Legalities
      buildLegalitiesBox(cardData['legalities']),
      Divider(thickness: 2),
    ]);

    return widgets;
  }

  Widget buildLegalitiesBox(Map<String, dynamic>? legalities) {
    if (legalities == null) return Container();

    var legalityItems = legalities.entries.map((e) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              color: e.value == 'legal' ? Colors.green : Colors.grey,
              padding: EdgeInsets.all(6.0),
              child: SizedBox(
                height: 20,
                width: 60, // Set your desired minimum width here
                child: Center(
                  child: Text(e.value),
                ),
              ),
            ),
            SizedBox(width: 4.0), // Adding some spacing
            Flexible(
              child: Text(e.key, textAlign: TextAlign.left),
            ),
          ],
        ),
      );
    }).toList();

    var half = (legalityItems.length / 2).floor();
    var column1 = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: legalityItems.sublist(0, half),
    );
    var column2 = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: legalityItems.sublist(half),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Aligning items to the top
      children: [
        Expanded(child: column1),
        Expanded(child: column2),
      ],
    );
  }
}
