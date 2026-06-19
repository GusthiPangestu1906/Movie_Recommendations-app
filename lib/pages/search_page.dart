import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../providers/history_provider.dart';
import '../models/movie.dart';
import 'detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  final List<Map<String, String>> _genres = [
    {'label': 'Action', 'value': '28'},
    {'label': 'Adventure', 'value': '12'},
    {'label': 'Animation', 'value': '16'},
    {'label': 'Comedy', 'value': '35'},
    {'label': 'Crime', 'value': '80'},
    {'label': 'Documentary', 'value': '99'},
    {'label': 'Drama', 'value': '18'},
    {'label': 'Family', 'value': '10751'},
    {'label': 'Fantasy', 'value': '14'},
    {'label': 'Horror', 'value': '27'},
    {'label': 'Music', 'value': '10402'},
    {'label': 'Mystery', 'value': '9648'},
    {'label': 'Romance', 'value': '10749'},
    {'label': 'Sci-Fi', 'value': '878'},
    {'label': 'Thriller', 'value': '53'},
    {'label': 'War', 'value': '10752'},
    {'label': 'Western', 'value': '37'},
  ];

  final List<Map<String, String>> _categories = [
    {'label': 'Now Playing', 'value': 'now_playing'},
    {'label': 'Popular', 'value': 'popular'},
    {'label': 'Top Rated', 'value': 'top_rated'},
    {'label': 'Upcoming', 'value': 'upcoming'},
  ];

  void _showFilterPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final provider = Provider.of<MovieProvider>(context);
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
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
                          const Text(
                            'Filter Movies',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Categories',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          _buildCategoryList(context, provider),
                          const SizedBox(height: 32),
                          const Text(
                            'Genres (Combine multiple)',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          _buildGenreGrid(context, provider, setModalState),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                provider.applyGenreFilter();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5C6AC4),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text('Apply Filter', style: TextStyle(fontWeight: FontWeight.bold)),
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
      },
    );
  }

  Widget _buildCategoryList(BuildContext context, MovieProvider provider) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((cat) {
        return GestureDetector(
          onTap: () {
            provider.searchByCategory(cat['value']!);
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              cat['label']!,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenreGrid(BuildContext context, MovieProvider provider, StateSetter setModalState) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _genres.map((genre) {
        final isSelected = provider.selectedGenreIds.contains(genre['value']);
        return GestureDetector(
          onTap: () {
            setModalState(() {
              provider.toggleGenre(genre['value']!);
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF5C6AC4) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.white10,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: const Color(0xFF5C6AC4).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ] : [],
            ),
            child: Text(
              genre['label']!,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E1E),
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search movies...',
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.white30),
                    suffixIcon: _searchController.text.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.white30, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            Provider.of<MovieProvider>(context, listen: false).clearSearch();
                          },
                        )
                      : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (query) {
                    Provider.of<MovieProvider>(context, listen: false).search(query);
                  },
                  onSubmitted: (query) {
                    if (query.isNotEmpty) {
                      Provider.of<MovieProvider>(context, listen: false).search(query);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF5C6AC4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: const Icon(Icons.tune, color: Color(0xFF5C6AC4)),
                onPressed: () => _showFilterPicker(context),
              ),
            ),
          ],
        ),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5C6AC4)));
          }
          if (provider.searchResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.movie_outlined, size: 64, color: Colors.white.withOpacity(0.05)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Search for your next favorite film',
                    style: TextStyle(color: Colors.white30, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use filters to combine genres',
                    style: TextStyle(color: Colors.white10, fontSize: 12),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: provider.searchResults.length,
            itemBuilder: (context, index) {
              final movie = provider.searchResults[index];
              return _buildSearchResultCard(context, movie);
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchResultCard(BuildContext context, dynamic movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(movie: movie)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              CachedNetworkImage(
                imageUrl: movie.fullPosterPath,
                width: 100,
                height: 140,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.white10),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${movie.voteAverage.round()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            ' / 10 IMDb',
                            style: TextStyle(color: Colors.white30, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.white30, size: 12),
                          const SizedBox(width: 6),
                          Text(
                            movie.releaseDate.split('-')[0],
                            style: const TextStyle(color: Colors.white30, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white10),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
