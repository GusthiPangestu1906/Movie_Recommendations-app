import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../providers/connectivity_provider.dart';
import '../widgets/movie_card.dart';

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
      body: Consumer<ConnectivityProvider>(
        builder: (context, connectivity, _) {
          return Stack(
            children: [
              Consumer<MovieProvider>(
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
                            color: Colors.white.withValues(alpha: 0.05),
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

                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index == results.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                );
                              }
                              return MovieCard(movie: results[index]);
                            },
                            childCount: results.length + (provider.isFetchingMore ? 1 : 0),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Overlay Offline
              if (!connectivity.isOnline)
                Container(
                  color: Colors.black,
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off_outlined,
                          color: Colors.white24,
                          size: 90,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Looks like you\'re\noffline!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: const Text(
                            'Search results will appear once you\'re back online.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () => connectivity.checkConnection(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C6AC4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Try Again',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
