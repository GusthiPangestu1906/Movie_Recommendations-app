import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../tv/presentation/providers/tv_provider.dart';
import '../../../search/presentation/providers/search_provider.dart';

class FilterSheet extends StatelessWidget {
  final bool isDramaMode;

  const FilterSheet({super.key, required this.isDramaMode});

  static final List<Map<String, String>> _genres = [
    {'label': 'Action', 'value': '28'},
    {'label': 'Adventure', 'value': '12'},
    {'label': 'Animation', 'value': '16'},
    {'label': 'Comedy', 'value': '35'},
    {'label': 'Crime', 'value': '80'},
    {'label': 'Drama', 'value': '18'},
    {'label': 'Fantasy', 'value': '14'},
    {'label': 'Horror', 'value': '27'},
    {'label': 'Mystery', 'value': '9648'},
    {'label': 'Romance', 'value': '10749'},
    {'label': 'Sci-Fi', 'value': '878'},
    {'label': 'Thriller', 'value': '53'},
  ];

  static final List<Map<String, String>> _countries = [
    {'label': 'All Countries', 'value': ''},
    {'label': 'Korea (K-Drama)', 'value': 'KR'},
    {'label': 'Japan (J-Drama)', 'value': 'JP'},
    {'label': 'China (C-Drama)', 'value': 'CN'},
    {'label': 'USA', 'value': 'US'},
    {'label': 'Thailand', 'value': 'TH'},
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final tvProvider = Provider.of<TvProvider>(context);
            final searchProvider = Provider.of<SearchProvider>(context);
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        isDramaMode ? 'Drama Selection' : 'Filter Movies',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isDramaMode
                            ? 'Select Origin Country'
                            : 'Select Movie Genres',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (isDramaMode)
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _countries.map((country) {
                            final isSelected =
                                (tvProvider.selectedCountry ?? '') ==
                                country['value'];
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setModalState(() {
                                  tvProvider.fetchTvSeries(
                                    country: country['value']!.isEmpty
                                        ? null
                                        : country['value'],
                                  );
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF5C6AC4)
                                      : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : Colors.white10,
                                  ),
                                ),
                                child: Text(
                                  country['label']!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      else
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _genres.map((genre) {
                            final isSelected = searchProvider.selectedGenreIds
                                .contains(genre['value']);
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setModalState(() {
                                  searchProvider.toggleGenre(genre['value']!);
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF5C6AC4)
                                      : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : Colors.white10,
                                  ),
                                ),
                                child: Text(
                                  genre['label']!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (!isDramaMode) {
                              searchProvider.applyGenreFilter();
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDramaMode
                                ? const Color(0xFF5C6AC4).withOpacity(0.1)
                                : const Color(0xFF5C6AC4),
                            foregroundColor: isDramaMode
                                ? const Color(0xFF5C6AC4)
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            isDramaMode ? 'Close' : 'Apply Combined Filter',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
