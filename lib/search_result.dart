import 'package:flutter/material.dart';
import 'card_view.dart'; // Import the CardView screen

// A StatefulWidget for displaying search results and handling filters.
class SearchResultScreen extends StatefulWidget {
  final Map<String, dynamic> cards; // Card data
  final bool isFavorites; // Flag to check if the view is for favorite cards

  // Constructor with named parameters
  const SearchResultScreen({
    Key? key,
    required this.cards,
    this.isFavorites = false,
  }) : super(key: key);

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  // Member variables to hold the card data and filter options
  List<dynamic>? allCardData;
  List<dynamic>? filteredCardData;
  List<String>? uniqueCmcs;
  List<String>? uniqueColors;
  List<String>? uniqueTypes;
  String? selectedCmc;
  String? selectedColor;
  String? selectedType;

  // Initialization
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  // Initialize data based on whether it's a favorites view or not
  void initializeData() {
    allCardData =
        widget.cards['data'] as List<dynamic>?; // Populate the card data
    filteredCardData =
        List.from(allCardData ?? []); // Copy all data to the filtered list
    populateUniqueFields(); // Populate unique filter options
  }

  // Populate unique filter options based on allCardData
  void populateUniqueFields() {
    uniqueCmcs =
        allCardData?.map((card) => card['cmc'].toString()).toSet().toList();
    uniqueColors =
        allCardData?.map((card) => card['colors'].toString()).toSet().toList();
    uniqueTypes = allCardData
        ?.map((card) => card['type_line'].toString().split('//')[0].trim())
        .toSet()
        .toList();

    // Sort options for better user experience
    uniqueCmcs?.sort((a, b) => double.parse(a).compareTo(double.parse(b)));
    uniqueTypes?.sort((a, b) => a.compareTo(b));
  }

  /// Filters the list of cards based on selected CMC, color, and type.
  void _filterCards() {
    setState(() {
      // Filter cards based on selected values.
      filteredCardData = allCardData?.where((card) {
        return (selectedCmc == null || card['cmc'].toString() == selectedCmc) &&
            (selectedColor == null ||
                card['colors'].toString() == selectedColor) &&
            (selectedType == null ||
                card['type_line'].toString() == selectedType);
      }).toList();
    });
  }

  /// Builds a dropdown menu with the given parameters.
  DropdownButton<String> buildDropdown(String hint, List<String>? items,
      ValueChanged<String?> onChanged, String? selectedValue) {
    return DropdownButton<String>(
      value: selectedValue,
      hint: Text(hint),
      items: buildDropdownItems(items),
      onChanged: onChanged,
    );
  }

  /// Builds the list of items for the dropdown menu.
  List<DropdownMenuItem<String>> buildDropdownItems(List<String>? items) {
    return [
      const DropdownMenuItem<String>(
        value: null,
        child: Text('None'),
      ),
      // Add items if the list is not null
      ...?items?.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }),
    ];
  }

  /// Builds the layout for portrait orientation.
  Widget buildPortraitLayout() {
    return Column(
      children: [
        // Dropdowns for CMC and Color
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
        // Dropdown for Type
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

  /// Builds the layout for landscape orientation.
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
      // App bar with title
      appBar: AppBar(title: const Text('Search Results')),
      // Main body of the widget
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Padding(
            // Outer padding for the entire screen
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Conditionally render layout based on orientation
                if (orientation == Orientation.portrait) buildPortraitLayout(),
                if (orientation == Orientation.landscape)
                  buildLandscapeLayout(),
                // Spacing between the dropdowns and the grid
                const SizedBox(height: 16),
                // Grid view to display filtered cards
                Expanded(
                  child: GridView.builder(
                    // Define grid properties
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          orientation == Orientation.portrait ? 2 : 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    // Number of items in the grid
                    itemCount: filteredCardData?.length ?? 0,
                    // Define each grid item
                    itemBuilder: (context, index) {
                      // Fetch current card details
                      var currentCard = filteredCardData?[index];
                      var name = currentCard?['name'] ?? 'Unknown';
                      var imageUris = currentCard?['image_uris'];
                      var normalImageUrl = imageUris?['normal'];

                      // Grid item UI
                      return GestureDetector(
                        onTap: () {
                          // Navigation to CardView screen on tap
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
                            // Card name with text overflow handling
                            Text(name, overflow: TextOverflow.ellipsis),
                            // Display card image if available
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
