import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../models/movie.dart';
import '../../../movie/presentation/providers/movie_provider.dart';
import '../../../favorite/presentation/providers/favorite_provider.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../actor_detail/presentation/pages/actor_detail_page.dart';

class MovieCastSection extends StatelessWidget {
  final List<Cast>? cast;

  const MovieCastSection({super.key, this.cast});

  @override
  Widget build(BuildContext context) {
    final castList = cast;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cast',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: castList == null || castList.isEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 16),
                    child: const Column(
                      children: [
                        ShimmerLoading(
                          width: 60,
                          height: 60,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        SizedBox(height: 12),
                        ShimmerLoading(width: 50, height: 10),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: castList.length,
                  itemBuilder: (context, index) {
                    return _buildCastItem(context, castList[index])
                        .animate(delay: (index * 50).ms)
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: 0.2);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCastItem(BuildContext context, Cast castMember) {
    return Consumer2<MovieProvider, FavoriteProvider>(
      builder: (context, movieProvider, favoriteProvider, child) {
        final isFav = favoriteProvider.isFavoriteActor(castMember.id);
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActorDetailPage(
                  actorId: castMember.id,
                  actorName: castMember.name,
                ),
              ),
            );
          },
          child: Container(
            width: 80,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white10, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: CachedNetworkImage(
                          imageUrl: castMember.fullProfilePath,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: AppLoadingIndicator(size: 20),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person, color: Colors.white30),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          favoriteProvider.toggleFavoriteActor(castMember);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1D2E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFav ? Colors.redAccent : Colors.white70,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  castMember.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
