import 'package:flutter/material.dart';

class CardView extends StatelessWidget {
  final dynamic cardData;

  CardView({required this.cardData});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) => Scaffold(
        appBar: buildAppBar(),
        body: orientation == Orientation.portrait
            ? buildPortraitLayout()
            : buildLandscapeLayout(),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(title: Text(cardData['name'] ?? 'Unknown Card'));
  }

  Widget buildPortraitLayout() {
    return buildLayoutWithPadding(buildCommonWidgets(true));
  }

  Widget buildLandscapeLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildScrollableImage(),
        Expanded(child: buildLayoutWithPadding(buildCommonWidgets(false))),
      ],
    );
  }

  Widget buildLayoutWithPadding(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget buildScrollableImage() {
    return SingleChildScrollView(
      child: Image.network(
        cardData['image_uris']['normal'] ?? '',
        fit: BoxFit.cover,
      ),
    );
  }

  List<Widget> buildCommonWidgets(bool includeImage) {
    return [
      if (includeImage) buildImageWithDivider(),
      buildTextWithDivider(cardData['mana_cost']),
      buildTextWithDivider(cardData['type_line']),
      buildTextWithDivider(cardData['oracle_text']),
      if (cardData['power'] != null || cardData['toughness'] != null)
        buildTextWithDivider(
            '${cardData['power'] ?? ''} / ${cardData['toughness'] ?? ''}'),
      buildTextWithDivider('Illustrated by ${cardData['artist'] ?? ''}'),
      buildLegalitiesBox(cardData['legalities']),
      Divider(thickness: 2),
    ];
  }

  Widget buildTextWithDivider(String? text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text ?? '', textAlign: TextAlign.left),
        Divider(thickness: 1),
      ],
    );
  }

  Widget buildImageWithDivider() {
    return Column(
      children: [
        Image.network(cardData['image_uris']['normal'] ?? ''),
        Divider(thickness: 2),
      ],
    );
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: column1),
        Expanded(child: column2),
      ],
    );
  }
}
