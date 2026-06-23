import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';
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
                fillColor: Colors.white.withOpacity(0.05),
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
      body: Consumer<MovieProvider>(
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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (favorites.isNotEmpty) ...[
                _buildSectionHeader('Your Favorites'),
                ...favorites.map((actor) => _buildActorCard(actor, provider)).toList(),
                const SizedBox(height: 20),
              ],
              if (isSearching) ...[
                _buildSectionHeader('Discover New Stars'),
                if (provider.isActorLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFF5C6AC4)),
                  ))
                else
                  ...globalResults
                      .where((g) => !provider.isFavoriteActor(g.id))
                      .map((actor) => _buildActorCard(actor, provider))
                      .toList(),
              ],
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
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                          color: Colors.white.withOpacity(0.05),
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
              color: Colors.white.withOpacity(0.02),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isListEmpty ? Icons.auto_awesome_outlined : Icons.search_off_outlined,
              size: 80,
              color: const Color(0xFF5C6AC4).withOpacity(0.2),
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
