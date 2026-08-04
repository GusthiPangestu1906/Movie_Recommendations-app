import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../features/search/presentation/providers/search_provider.dart';
import '../features/tv/presentation/providers/tv_provider.dart';
import '../core/widgets/movie_card.dart';
import '../core/widgets/shimmer_loading.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1E),
      body: Consumer2<SearchProvider, TvProvider>(
        builder: (context, searchProvider, tvProvider, child) {
          final results = tvProvider.isDramaMode
              ? searchProvider.tvSearchResults
              : searchProvider.searchResults;

          if (searchProvider.isLoading && results.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) => const MovieCardShimmer()
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 1200.ms,
                    color: Colors.white.withOpacity(0.05),
                  ),
            );
          }

          if (results.isEmpty) {
            return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          size: 80,
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Search for your favorites',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Movies, Dramas, and more...',
                        style: TextStyle(color: Colors.white38, fontSize: 14),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.9, 0.9));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: MovieCard(movie: results[index])
                    .animate(delay: (index * 50).ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1),
              );
            },
          );
        },
      ),
    );
  }
}
