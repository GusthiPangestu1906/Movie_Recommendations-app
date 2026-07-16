import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';
import '../pages/detail_page.dart';

class FavoriteButton extends StatefulWidget {
  final Movie movie;
  const FavoriteButton({super.key, required this.movie});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MovieProvider, bool>(
      selector: (_, provider) => provider.isFavorite(widget.movie.id),
      builder: (context, isFavorite, child) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _controller.forward(from: 0);
            context.read<MovieProvider>().toggleFavorite(widget.movie);
          },
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey<bool>(isFavorite),
                  color: isFavorite ? Colors.redAccent : Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;
  final bool isHorizontal;

  const MovieCard({
    super.key,
    required this.movie,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return isHorizontal ? _buildHorizontalCard(context) : _buildStandardCard(context);
  }

  Widget _buildHorizontalCard(BuildContext context) {
    return OpenContainer(
      closedElevation: 0,
      closedColor: Colors.transparent,
      openColor: const Color(0xFF0B0E1E),
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      transitionType: ContainerTransitionType.fadeThrough,
      openBuilder: (context, _) => DetailPage(movie: movie),
      closedBuilder: (context, openContainer) => RepaintBoundary(
        child: GestureDetector(
          onTap: openContainer,
          child: Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: movie.fullPosterPath,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => Container(color: Colors.white10),
                          errorWidget: (context, url, error) => const Icon(Icons.movie, color: Colors.white10),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: FavoriteButton(movie: movie),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                                const SizedBox(width: 2),
                                Text(
                                  movie.voteAverage.toStringAsFixed(1),
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        movie.releaseDate.isNotEmpty ? movie.releaseDate.split('-')[0] : 'N/A',
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardCard(BuildContext context) {
    return OpenContainer(
      closedElevation: 0,
      closedColor: Colors.transparent,
      openColor: const Color(0xFF0B0E1E),
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      transitionType: ContainerTransitionType.fadeThrough,
      openBuilder: (context, _) => DetailPage(movie: movie),
      closedBuilder: (context, openContainer) => RepaintBoundary(
        child: GestureDetector(
          onTap: openContainer,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(4),
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
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: movie.fullPosterPath,
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        placeholder: (context, url) => Container(color: Colors.white10),
                        errorWidget: (context, url, error) => const Icon(Icons.movie, color: Colors.white10),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: FavoriteButton(movie: movie),
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
                            movie.title,
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
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                movie.voteAverage.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const Text(
                                ' / 10 TMDb',
                                style: TextStyle(color: Colors.white30, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildBadge(
                                icon: Icons.calendar_today,
                                text: movie.releaseDate.isNotEmpty ? movie.releaseDate.split('-')[0] : 'N/A',
                              ),
                              _buildBadge(
                                icon: movie.isTv ? Icons.tv : Icons.movie_filter,
                                text: movie.isTv ? 'Drama' : 'Movie',
                                color: const Color(0xFF5C6AC4).withValues(alpha: 0.2),
                                textColor: const Color(0xFF5C6AC4),
                              ),
                            ],
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
        ),
      ),
    );
  }

  Widget _buildBadge({required IconData icon, required String text, Color? color, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor ?? Colors.white30, size: 10),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: textColor ?? Colors.white30, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
