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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final provider = Provider.of<MovieProvider>(context, listen: false);
        if (provider.searchResults.isNotEmpty || provider.tvSearchResults.isNotEmpty) {
          provider.fetchMoreSearchResults();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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
          
          if (provider.isLoading && results.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5C6AC4)));
          }

          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    provider.isLoading ? Icons.search : (isDramaMode ? Icons.tv : Icons.movie_outlined),
                    size: 64,
                    color: Colors.white.withOpacity(0.05),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.isLoading ? 'Searching...' : 'Find your next ${isDramaMode ? 'drama' : 'movie'}',
                    style: const TextStyle(color: Colors.white30, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: results.length + (provider.isFetchingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == results.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              return MovieCard(movie: results[index]);
            },
          );
        },
      ),
    );
  }
}
