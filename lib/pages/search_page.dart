import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';
import 'detail_page.dart';
import '../widgets/movie_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final isDramaMode = movieProvider.isDramaMode;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1E),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          final results = isDramaMode ? provider.tvSearchResults : provider.searchResults;
          
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5C6AC4)));
          }

          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchController.text.isEmpty 
                      ? (isDramaMode ? Icons.tv : Icons.movie_outlined) 
                      : Icons.sentiment_dissatisfied,
                    size: 64,
                    color: Colors.white.withOpacity(0.05),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isEmpty 
                      ? 'Find your next ${isDramaMode ? 'drama' : 'movie'}' 
                      : 'No ${isDramaMode ? 'dramas' : 'movies'} found',
                    style: const TextStyle(color: Colors.white30, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return MovieCard(movie: results[index]);
            },
          );
        },
      ),
    );
  }

  // _buildResultCard removed - now using MovieCard widget
}
