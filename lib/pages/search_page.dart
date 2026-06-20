import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
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
              final item = results[index];
              return _buildResultCard(context, item);
            },
          );
        },
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, Movie item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(movie: item)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.fullPosterPath,
                width: 70,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.white10),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${item.voteAverage.toStringAsFixed(1)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item.releaseDate.isNotEmpty ? item.releaseDate.split('-')[0] : 'N/A',
                        style: const TextStyle(color: Colors.white30, fontSize: 13),
                      ),
                    ],
                  ),
                  if (item.isTv)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'DRAMA',
                        style: TextStyle(color: Colors.blueAccent, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
