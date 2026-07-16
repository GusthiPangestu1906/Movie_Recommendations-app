import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/movie_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/movie_card.dart';
import '../widgets/shimmer_loading.dart';

class TvPage extends StatefulWidget {
  const TvPage({super.key});

  @override
  State<TvPage> createState() => _TvPageState();
}

class _TvPageState extends State<TvPage> {
  final TextEditingController _tvSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final provider = Provider.of<MovieProvider>(context, listen: false);
      final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
      provider.fetchTvSeries();
      provider.fetchTvRecommendations(history: historyProvider.history);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final provider = Provider.of<MovieProvider>(context, listen: false);
        if (_tvSearchController.text.isEmpty) {
          provider.fetchMoreTvSeries();
        } else {
          provider.fetchMoreSearchResults();
        }
      }
    });
  }

  @override
  void dispose() {
    _tvSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1E),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.tvSeries.isEmpty && provider.tvSearchResults.isEmpty) {
            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 32, 16, 12),
                    child: ShimmerLoading(width: 100, height: 20),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 5,
                      itemBuilder: (context, index) => const MovieCardShimmer(isHorizontal: true),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: ShimmerLoading(width: 100, height: 20),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const MovieCardShimmer(),
                      childCount: 5,
                    ),
                  ),
                ),
              ],
            );
          }

          final list = _tvSearchController.text.isNotEmpty
              ? provider.tvSearchResults
              : provider.tvSeries;

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Recommendation Section Header
              if (_tvSearchController.text.isEmpty && provider.tvRecommendations.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 32, 16, 12),
                    child: Text(
                      'For You',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.tvRecommendations.length,
                      itemBuilder: (context, index) {
                        return MovieCard(
                          movie: provider.tvRecommendations[index],
                          isHorizontal: true,
                        )
                            .animate(delay: (index * 100).ms)
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: 0.2);
                      },
                    ),
                  ),
                ),
              ],

              // Main List Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    _tvSearchController.text.isNotEmpty ? 'Search Results' : 'Popular Dramas',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              if (list.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('No dramas found', style: TextStyle(color: Colors.white38)),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => MovieCard(movie: list[index])
                          .animate(delay: (index * 50).ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1),
                      childCount: list.length,
                    ),
                  ),
                ),

              if (provider.isFetchingMore)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const MovieCardShimmer(),
                      childCount: 2,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),
    );
  }
}
