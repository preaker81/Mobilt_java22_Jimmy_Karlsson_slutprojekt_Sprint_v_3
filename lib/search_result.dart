import 'package:flutter/material.dart';
import 'card_view.dart'; // Import the CardView screen

class SearchResultScreen extends StatefulWidget {
  final Map<String, dynamic> cards;
  final bool isFavorites;

  const SearchResultScreen(
      {Key? key, required this.cards, this.isFavorites = false})
      : super(key: key);

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  List<dynamic>? allCardData;
  List<dynamic>? filteredCardData;
  List<String>? uniqueCmcs;
  List<String>? uniqueColors;
  List<String>? uniqueTypes;
  String? selectedCmc;
  String? selectedColor;
  String? selectedType;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() {
    if (widget.isFavorites) {
      // Assuming the favorite cards are coming in a Map with a 'data' key that contains the list
      allCardData = widget.cards['data'] as List<dynamic>?;
    } else {
      // Handle your API data here, it may already be a List or still be a Map
      allCardData = widget.cards['data'] as List<
          dynamic>?; // Adjust this line based on your API response structure
    }
    filteredCardData = List.from(allCardData ?? []);
    populateUniqueFields();
  }

  void populateUniqueFields() {
    uniqueCmcs =
        allCardData?.map((card) => card['cmc'].toString()).toSet().toList();
    uniqueColors =
        allCardData?.map((card) => card['colors'].toString()).toSet().toList();
    uniqueTypes = allCardData
        ?.map((card) => card['type_line'].toString().split('//')[0].trim())
        .toSet()
        .toList();

    uniqueCmcs?.sort((a, b) => double.parse(a).compareTo(double.parse(b)));
    uniqueTypes?.sort((a, b) => a.compareTo(b));
  }

  void _filterCards() {
    setState(() {
      filteredCardData = allCardData?.where((card) {
        return (selectedCmc == null || card['cmc'].toString() == selectedCmc) &&
            (selectedColor == null ||
                card['colors'].toString() == selectedColor) &&
            (selectedType == null ||
                card['type_line'].toString() == selectedType);
      }).toList();
    });
  }

  DropdownButton<String> buildDropdown(String hint, List<String>? items,
      ValueChanged<String?> onChanged, String? selectedValue) {
    return DropdownButton<String>(
      value: selectedValue,
      hint: Text(hint),
      items: buildDropdownItems(items),
      onChanged: onChanged,
    );
  }

  List<DropdownMenuItem<String>> buildDropdownItems(List<String>? items) {
    return [
      const DropdownMenuItem<String>(
        value: null,
        child: Text('None'),
      ),
      ...?items?.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }),
    ];
  }

  Widget buildPortraitLayout() {
    return Column(
      children: [
        Row(
          children: [
            buildDropdown(
              'Select CMC',
              uniqueCmcs,
              (value) {
                setState(() => selectedCmc = value);
                _filterCards();
              },
              selectedCmc,
            ),
            buildDropdown(
              'Select Color',
              uniqueColors,
              (value) {
                setState(() => selectedColor = value);
                _filterCards();
              },
              selectedColor,
            ),
          ],
        ),
        buildDropdown(
          'Select Type',
          uniqueTypes,
          (value) {
            setState(() => selectedType = value);
            _filterCards();
          },
          selectedType,
        ),
      ],
    );
  }

  Widget buildLandscapeLayout() {
    return Row(
      children: [
        buildDropdown(
          'Select CMC',
          uniqueCmcs,
          (value) {
            setState(() => selectedCmc = value);
            _filterCards();
          },
          selectedCmc,
        ),
        buildDropdown(
          'Select Color',
          uniqueColors,
          (value) {
            setState(() => selectedColor = value);
            _filterCards();
          },
          selectedColor,
        ),
        buildDropdown(
          'Select Type',
          uniqueTypes,
          (value) {
            setState(() => selectedType = value);
            _filterCards();
          },
          selectedType,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Results')),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (orientation == Orientation.portrait) buildPortraitLayout(),
                if (orientation == Orientation.landscape)
                  buildLandscapeLayout(),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          orientation == Orientation.portrait ? 2 : 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredCardData?.length ?? 0,
                    itemBuilder: (context, index) {
                      var currentCard = filteredCardData?[index];
                      var name = currentCard?['name'] ?? 'Unknown';
                      var imageUris = currentCard?['image_uris'];
                      var normalImageUrl = imageUris?['normal'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CardView(
                                cardData: currentCard,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(name, overflow: TextOverflow.ellipsis),
                            Expanded(
                              child: normalImageUrl != null
                                  ? Image.network(normalImageUrl)
                                  : Container(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
