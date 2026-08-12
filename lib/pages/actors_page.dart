import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/widgets/common/loading/app_loading_indicator.dart';
import '../features/actors/presentation/widgets/actor_card.dart';
import '../features/actors/presentation/widgets/actor_search_bar.dart';
import '../features/actors/presentation/widgets/actors_empty_state.dart';
import '../features/favorite/presentation/providers/favorite_provider.dart';
import '../features/movie/presentation/providers/movie_provider.dart';
import '../features/search/presentation/providers/search_provider.dart';
import '../providers/connectivity_provider.dart';

class FavoriteActorsPage extends StatefulWidget {
  const FavoriteActorsPage({super.key});

  @override
  State<FavoriteActorsPage> createState() => _FavoriteActorsPageState();
}

class _FavoriteActorsPageState extends State<FavoriteActorsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoriteProvider>(
        context,
        listen: false,
      ).setActorSearchQuery('');
      Provider.of<SearchProvider>(context, listen: false).searchActors('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    Provider.of<FavoriteProvider>(
      context,
      listen: false,
    ).setActorSearchQuery(value);
    Provider.of<SearchProvider>(context, listen: false).searchActors(value);
    setState(() {});
  }

  void _onSearchClear() {
    _searchController.clear();
    Provider.of<FavoriteProvider>(
      context,
      listen: false,
    ).setActorSearchQuery('');
    Provider.of<SearchProvider>(context, listen: false).searchActors('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1E),
      appBar: AppBar(
        title: const Text(
          'Stars Galaxy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: ActorSearchBar(
          controller: _searchController,
          onChanged: _onSearchChanged,
          onClear: _onSearchClear,
        ),
      ),
      body: Consumer<ConnectivityProvider>(
        builder: (context, connectivity, _) {
          return Stack(
            children: [
              Consumer3<MovieProvider, FavoriteProvider, SearchProvider>(
                builder:
                    (
                      context,
                      movieProvider,
                      favoriteProvider,
                      searchProvider,
                      child,
                    ) {
                      final favorites = favoriteProvider.filteredFavoriteActors;
                      final globalResults =
                          searchProvider.globalActorSearchResults;
                      final isSearching = _searchController.text.isNotEmpty;

                      if (favoriteProvider.favoriteActors.isEmpty &&
                          !isSearching) {
                        return const ActorsEmptyState(isListEmpty: true);
                      }

                      if (isSearching &&
                          favorites.isEmpty &&
                          globalResults.isEmpty &&
                          !searchProvider.isActorLoading) {
                        return const ActorsEmptyState(isListEmpty: false);
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          await favoriteProvider.refreshFavorites();
                        },
                        color: const Color(0xFF5C6AC4),
                        backgroundColor: const Color(0xFF1A1D2E),
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            if (favorites.isNotEmpty) ...[
                              SliverToBoxAdapter(
                                child: _buildSectionHeader('Your Favorites'),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) => ActorCard(
                                      actor: favorites[index],
                                      favoriteProvider: favoriteProvider,
                                    ),
                                    childCount: favorites.length,
                                  ),
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 20),
                              ),
                            ],
                            if (isSearching) ...[
                              SliverToBoxAdapter(
                                child: _buildSectionHeader(
                                  'Discover New Stars',
                                ),
                              ),
                              if (searchProvider.isActorLoading)
                                const SliverToBoxAdapter(
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: AppLoadingIndicator(
                                        color: Color(0xFF5C6AC4),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final searchResults = globalResults
                                            .where(
                                              (g) => !favoriteProvider
                                                  .isFavoriteActor(g.id),
                                            )
                                            .toList();
                                        return ActorCard(
                                          actor: searchResults[index],
                                          favoriteProvider: favoriteProvider,
                                        );
                                      },
                                      childCount: globalResults
                                          .where(
                                            (g) => !favoriteProvider
                                                .isFavoriteActor(g.id),
                                          )
                                          .length,
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      );
                    },
              ),

              if (!connectivity.isOnline) _buildOfflineOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 0, 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOfflineOverlay() {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, color: Colors.white24, size: 90),
            SizedBox(height: 24),
            Text(
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
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                'You\'ll see more stars once you\'re back online.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
