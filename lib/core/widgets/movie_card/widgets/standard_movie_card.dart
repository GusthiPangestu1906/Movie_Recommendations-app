import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animations/animations.dart';
import '../../../../models/movie.dart';
import '../../../../features/movie_detail/presentation/pages/movie_detail_page.dart';
import '../../common/loading/app_loading_indicator.dart';
import 'favorite_button.dart';
import 'movie_badge.dart';

class StandardMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onFlip;

  const StandardMovieCard({super.key, required this.movie, this.onFlip});

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedElevation: 0,
      closedColor: const Color(0xFF161927),
      openColor: const Color(0xFF0B0E1E),
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      transitionType: ContainerTransitionType.fadeThrough,
      openBuilder: (context, _) => MovieDetailPage(movie: movie),
      closedBuilder: (context, openContainer) => RepaintBoundary(
        child: GestureDetector(
          onTap: openContainer,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF161927),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Row(
                    children: [
                      // Poster Section
                      Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: movie.fullPosterPath,
                            width: 135,
                            height: 200,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: AppLoadingIndicator(size: 20),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.movie, color: Colors.white10),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: FavoriteButton(movie: movie),
                          ),
                        ],
                      ),

                      // Content Section
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                movie.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    movie.voteAverage.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Text(
                                    ' / 10 TMDb',
                                    style: TextStyle(
                                      color: Colors.white30,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  MovieBadge(
                                    icon: Icons.calendar_today,
                                    text: movie.releaseDate.isNotEmpty
                                        ? movie.releaseDate.split('-')[0]
                                        : 'N/A',
                                  ),
                                  const SizedBox(width: 8),
                                  MovieBadge(
                                    icon: movie.isTv
                                        ? Icons.tv
                                        : Icons.movie_filter,
                                    text: movie.isTv ? 'Drama' : 'Movie',
                                    color: const Color(
                                      0xFF5C6AC4,
                                    ).withOpacity(0.15),
                                    textColor: const Color(0xFF5C6AC4),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Action button at the bottom right
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: movie.watchDate != null
                        ? GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onFlip?.call();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.greenAccent.withOpacity(0.3),
                                  width: 0.8,
                                ),
                              ),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.greenAccent,
                                size: 14,
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                                width: 0.8,
                              ),
                            ),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white.withOpacity(
                                0.25,
                              ), // Increased visibility
                              size: 14,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
