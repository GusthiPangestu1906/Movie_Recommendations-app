import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'actor_detail_page.dart';

class FavoriteActorsPage extends StatelessWidget {
  const FavoriteActorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1E),
      appBar: AppBar(
        title: const Text('My Favorite Stars', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          final actors = provider.favoriteActors;

          if (actors.isEmpty) {
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
                    child: Icon(Icons.auto_awesome_outlined, size: 80, color: const Color(0xFF5C6AC4).withOpacity(0.2)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Stars in Your Galaxy',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your favorite actors to see them here!',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 20,
              mainAxisSpacing: 25,
            ),
            itemCount: actors.length,
            itemBuilder: (context, index) {
              final actor = actors[index];
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
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Hero(
                                tag: 'actor-${actor.id}',
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF5C6AC4).withOpacity(0.2),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      )
                                    ],
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(actor.fullProfilePath),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => provider.toggleFavoriteActor(actor),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1D2E).withOpacity(0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.favorite, color: Colors.redAccent, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                        child: Column(
                          children: [
                            Text(
                              actor.name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap to find movies',
                              style: TextStyle(color: Color(0xFF5C6AC4), fontSize: 10, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
