import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';
import '../providers/connectivity_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'actor_detail_page.dart';

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
      Provider.of<MovieProvider>(context, listen: false).setActorSearchQuery('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1E),
      appBar: AppBar(
        title: const Text('Stars Galaxy', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                Provider.of<MovieProvider>(context, listen: false).setActorSearchQuery(value);
                setState(() {});
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search stars globally...',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.search, color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<MovieProvider>(context, listen: false).setActorSearchQuery('');
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ConnectivityProvider>(
        builder: (context, connectivity, _) {
          return Stack(
            children: [
              Consumer<MovieProvider>(
                builder: (context, provider, child) {
                  final favorites = provider.filteredFavoriteActors;
                  final globalResults = provider.globalActorSearchResults;
                  final isSearching = _searchController.text.isNotEmpty;

                  if (provider.favoriteActors.isEmpty && !isSearching) {
                    return _buildEmptyState(true);
                  }

                  if (isSearching && favorites.isEmpty && globalResults.isEmpty && !provider.isActorLoading) {
                    return _buildEmptyState(false);
                  }

                  return CustomScrollView(
                    slivers: [
                      if (favorites.isNotEmpty) ...[
                        SliverToBoxAdapter(child: _buildSectionHeader('Your Favorites')),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildActorCard(favorites[index], provider),
                              childCount: favorites.length,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      ],
                      if (isSearching) ...[
                        SliverToBoxAdapter(child: _buildSectionHeader('Discover New Stars')),
                        if (provider.isActorLoading)
                          const SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(color: Color(0xFF5C6AC4)),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final searchResults = globalResults
                                      .where((g) => !provider.isFavoriteActor(g.id))
                                      .toList();
                                  return _buildActorCard(searchResults[index], provider);
                                },
                                childCount: globalResults
                                    .where((g) => !provider.isFavoriteActor(g.id))
                                    .length,
                              ),
                            ),
                          ),
                      ],
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
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off_outlined,
                          color: Colors.white24,
                          size: 90,
                        ),
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
                ),
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
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActorCard(Cast actor, MovieProvider provider) {
    final isFav = provider.isFavoriteActor(actor.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActorDetailPage(actorId: actor.id, actorName: actor.name),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Row(
            children: [
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: actor.fullProfilePath,
                    width: 110,
                    height: 140,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    placeholder: (context, url) => Container(color: Colors.white10),
                    errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white10),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () => provider.toggleFavoriteActor(actor),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.redAccent : Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        actor.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Color(0xFF5C6AC4), size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            'Star Profile',
                            style: TextStyle(
                              color: Color(0xFF5C6AC4),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.movie_outlined, color: Colors.white30, size: 12),
                            const SizedBox(width: 6),
                            Text(
                              'Tap to find movies',
                              style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right, color: Colors.white10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isListEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isListEmpty ? Icons.auto_awesome_outlined : Icons.search_off_outlined,
              size: 80,
              color: const Color(0xFF5C6AC4).withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isListEmpty ? 'No Stars in Your Galaxy' : 'No matches found',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isListEmpty ? 'Add your favorite actors to see them here!' : 'Try searching with a different name',
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
