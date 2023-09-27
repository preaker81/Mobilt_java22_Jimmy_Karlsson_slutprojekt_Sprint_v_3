import 'package:flutter/material.dart';
import 'package:mtg_companion/data/firestore_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A StatefulWidget responsible for rendering a view for an MTG card.
class CardView extends StatefulWidget {
  // Data for the MTG card to be displayed
  final dynamic cardData;

  // Initialize the cardData through constructor
  const CardView({super.key, required this.cardData});

  @override
  _CardViewState createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  final FirestoreHelper firestoreHelper = FirestoreHelper();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  /// Check if the card is marked as favorite by the user.
  Future<void> _checkIfFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    if (username != null) {
      bool status =
          await firestoreHelper.isFavoriteCard(username, widget.cardData['id']);
      setState(() {
        isFavorite = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) => Scaffold(
        appBar: _buildAppBar(),
        body: orientation == Orientation.portrait
            ? _buildPortraitLayout()
            : _buildLandscapeLayout(),
      ),
    );
  }

  /// Build the app bar for the card view.
  AppBar _buildAppBar() {
    return AppBar(title: Text(widget.cardData['name'] ?? 'Unknown Card'));
  }

  /// Build the layout in portrait mode.
  Widget _buildPortraitLayout() {
    return _buildLayoutWithPadding(_buildCommonWidgets(true));
  }

  /// Build the layout in landscape mode.
  Widget _buildLandscapeLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildScrollableImage(),
        Expanded(child: _buildLayoutWithPadding(_buildCommonWidgets(false))),
      ],
    );
  }

  /// Helper method to build layout with padding.
  Widget _buildLayoutWithPadding(List<Widget> children) {
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

  /// Build the scrollable image view of the card.
  Widget _buildScrollableImage() {
    return SingleChildScrollView(
      child: Image.network(
        widget.cardData['image_uris']['normal'] ?? '',
        fit: BoxFit.cover,
      ),
    );
  }

  /// Build widgets common to both portrait and landscape layout.
  List<Widget> _buildCommonWidgets(bool includeImage) {
    return [
      if (includeImage) _buildImageWithDivider(),
      _buildTextWithDivider(widget.cardData['mana_cost']),
      _buildTextWithDivider(widget.cardData['type_line']),
      _buildTextWithDivider(widget.cardData['oracle_text']),
      if (widget.cardData['power'] != null ||
          widget.cardData['toughness'] != null)
        _buildTextWithDivider(
            '${widget.cardData['power'] ?? ''} / ${widget.cardData['toughness'] ?? ''}'),
      _buildTextWithDivider(
          'Illustrated by ${widget.cardData['artist'] ?? ''}'),
      _buildLegalitiesBox(widget.cardData['legalities']),
      const Divider(thickness: 2),
      ElevatedButton(
        onPressed: () async => _toggleFavoriteStatus(),
        child: Text(isFavorite ? "Remove from Favorites" : "Add to Favorites"),
      ),
    ];
  }

  /// Helper method to toggle favorite status of the card.
  Future<void> _toggleFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    if (username != null) {
      if (isFavorite) {
        await firestoreHelper.removeUserFromFavorite(
            username, widget.cardData['id']);
      } else {
        await firestoreHelper.addFavoriteCard(username, widget.cardData);
      }
      _checkIfFavorite();
    }
  }

  /// Build a text view with a divider below it.
  Widget _buildTextWithDivider(String? text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text ?? '', textAlign: TextAlign.left),
        const Divider(thickness: 1),
      ],
    );
  }

  /// Build the image view with a divider below it.
  Widget _buildImageWithDivider() {
    return Column(
      children: [
        Image.network(widget.cardData['image_uris']['normal'] ?? ''),
        const Divider(thickness: 2),
      ],
    );
  }

  /// Build the legalities box that displays legal status for the card.
  Widget _buildLegalitiesBox(Map<String, dynamic>? legalities) {
    if (legalities == null) return Container();

    var legalityItems = legalities.entries.map((e) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              color: e.value == 'legal' ? Colors.green : Colors.grey,
              padding: const EdgeInsets.all(6.0),
              child: SizedBox(
                height: 20,
                width: 60, // Set your desired minimum width here
                child: Center(
                  child: Text(e.value),
                ),
              ),
            ),
            const SizedBox(width: 4.0), // Adding some spacing
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
