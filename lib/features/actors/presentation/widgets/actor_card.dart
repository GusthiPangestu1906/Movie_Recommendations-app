import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/common/loading/app_loading_indicator.dart';
import '../../../../models/movie.dart';
import '../../../actor_detail/presentation/pages/actor_detail_page.dart';
import '../../../favorite/presentation/providers/favorite_provider.dart';
import 'animated_favorite_button.dart';

class ActorCard extends StatelessWidget {
  final Cast actor;
  final FavoriteProvider favoriteProvider;

  const ActorCard({
    super.key,
    required this.actor,
    required this.favoriteProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isFav = favoriteProvider.isFavoriteActor(actor.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ActorDetailPage(actorId: actor.id, actorName: actor.name),
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
                    alignment: Alignment.topCenter,
                    placeholder: (context, url) =>
                        const Center(child: AppLoadingIndicator(size: 30)),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person, color: Colors.white10),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: AnimatedFavoriteButton(
                      isFavorite: isFav,
                      onTap: () => favoriteProvider.toggleFavoriteActor(actor),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
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
                      const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF5C6AC4),
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.movie_outlined,
                              color: Colors.white30,
                              size: 12,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Tap to find movies',
                              style: TextStyle(
                                color: Colors.white30,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
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
}
