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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(cardData['image_uris']['normal'] ?? ''),
            Divider(thickness: 2),
            ...buildCommonWidgets(),
          ],
        ),
      ),
    );
  }

  Widget buildLandscapeLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Card image
        Expanded(
          child: SingleChildScrollView(
            child: Image.network(
              cardData['image_uris']['normal'] ?? '',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Right side: Information Container
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: buildCommonWidgets(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> buildCommonWidgets() {
    return [
      Divider(thickness: 2),
      Text(cardData['name'] ?? ''),
      Text(cardData['mana_cost'] ?? ''),
      Divider(thickness: 1),
      Text(cardData['type_line'] ?? ''),
      Divider(thickness: 1),
      Text(cardData['oracle_text'] ?? ''),
      Divider(thickness: 1),
      if (cardData['power'] != null || cardData['toughness'] != null)
        Text('${cardData['power'] ?? ''} / ${cardData['toughness'] ?? ''}'),
      Divider(thickness: 1),
      Text(cardData['artist'] ?? ''),
      Divider(thickness: 1),
      buildLegalitiesBox(cardData['legalities']),
      Divider(thickness: 2),
    ];
  }

  Widget buildLegalitiesBox(Map<String, dynamic>? legalities) {
    if (legalities == null) return Container();

    var legalityItems = legalities.entries.map((e) {
      return Row(
        children: [
          Text(e.key),
          Container(
            color: e.value == 'legal' ? Colors.green : Colors.grey,
            child: Text(e.value),
          ),
        ],
      );
    }).toList();

    var column1 = Column(
      children: legalityItems.sublist(0, (legalityItems.length / 2).floor()),
    );
    var column2 = Column(
      children: legalityItems.sublist((legalityItems.length / 2).floor()),
    );

    return Row(
      children: [column1, column2],
    );
  }
}
