import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../features/movie/presentation/providers/movie_provider.dart';
import '../features/tv/presentation/providers/tv_provider.dart';
import '../features/search/presentation/providers/search_provider.dart';
import '../features/favorite/presentation/providers/favorite_provider.dart';
import '../providers/history_provider.dart';
import '../core/widgets/movie_card.dart';
import '../core/widgets/common/loading/shimmer_loading.dart';
import '../core/widgets/movie_card/widgets/movie_card_shimmer.dart';

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
      final historyProvider = context.read<HistoryProvider>();
      context.read<TvProvider>().fetchTvSeries(
        history: historyProvider.allHistory,
      );
      final movieProvider = context.read<MovieProvider>();
      final favoriteProvider = context.read<FavoriteProvider>();
      movieProvider.fetchTvRecommendations(
        favoriteTv: favoriteProvider.favoriteTv,
        history: historyProvider.allHistory,
      );
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final historyProvider = context.read<HistoryProvider>();
        if (_tvSearchController.text.isEmpty) {
          context.read<TvProvider>().fetchMoreTvSeries(
            history: historyProvider.allHistory,
          );
        } else {
          context.read<SearchProvider>().fetchMoreSearchResults(
            isDramaMode: true,
            selectedCountry: context.read<TvProvider>().selectedCountry,
            history: historyProvider.allHistory,
          );
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
    return MultiProvider(
      providers: [
        // Ensure UI rebuilds when any of these change
        Consumer<MovieProvider>(builder: (context, _, child) => child!),
        Consumer<TvProvider>(builder: (context, _, child) => child!),
        Consumer<SearchProvider>(builder: (context, _, child) => child!),
      ],
      child: Consumer3<MovieProvider, TvProvider, SearchProvider>(
        builder: (context, movieProvider, tvProvider, searchProvider, child) {
          final bool isLoading =
              tvProvider.isLoading || searchProvider.isLoading;
          final bool isFetchingMore =
              tvProvider.isFetchingMore || searchProvider.isFetchingMore;

          if (isLoading &&
              tvProvider.tvSeries.isEmpty &&
              searchProvider.tvSearchResults.isEmpty) {
            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                      itemBuilder: (context, index) =>
                          const MovieCardShimmer(isHorizontal: true),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
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
              ? searchProvider.tvSearchResults
              : tvProvider.tvSeries;

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              // Recommendation Section Header
              if (_tvSearchController.text.isEmpty &&
                  movieProvider.tvRecommendations.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                      itemCount: movieProvider.tvRecommendations.length,
                      itemBuilder: (context, index) {
                        return MovieCard(
                              movie: movieProvider.tvRecommendations[index],
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Text(
                    _tvSearchController.text.isNotEmpty
                        ? 'Search Results'
                        : 'Popular Dramas',
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
                      child: Text(
                        'No dramas found',
                        style: TextStyle(color: Colors.white38),
                      ),
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

              if (isFetchingMore)
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
