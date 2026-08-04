import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../models/movie.dart';
import '../providers/movie_detail_provider.dart';

class MovieInfoCard extends StatelessWidget {
  final Movie movie;

  const MovieInfoCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MovieDetailProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child:
                  Text(
                        movie.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: -0.1),
            ),
            Row(
              children: [
                _AnimatedFavoriteButton(
                  isFavorite: provider.isFavorite,
                  onToggle: () => provider.toggleFavorite(),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              '${movie.voteAverage.toStringAsFixed(1)} / 10 IMDb',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildChip('ACTION'),
            _buildChip('ADVENTURE'),
            _buildChip('FANTASY'),
          ],
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 28),
        Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem('Length', '2h 28min'),
                  _buildInfoItem('Language', 'English'),
                  _buildInfoItem(
                    'Rating',
                    provider.getFormattedRating(movie.certification),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(delay: 400.ms)
            .scale(begin: const Offset(0.9, 0.9)),
        const SizedBox(height: 32),
        // Watch Now Button
        SizedBox(
          width: double.infinity,
          height: 64,
          child: GestureDetector(
            onTapDown: (_) => HapticFeedback.mediumImpact(),
            child: ElevatedButton(
              onPressed: () => provider.watchOnPlatform(
                context,
                movie.title,
                movie.isTv,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: movie.isTv ? Colors.orange : Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.play_circle_fill_rounded,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    movie.isTv ? 'Watch on WeTV' : 'Watch on Netflix',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDBE3FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF88A4E8).withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF88A4E8),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _AnimatedFavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onToggle;

  const _AnimatedFavoriteButton({
    required this.isFavorite,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onToggle();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(
            scale: animation.drive(
              Tween<double>(
                begin: 0.7,
                end: 1.0,
              ).chain(CurveTween(curve: Curves.elasticOut)),
            ),
            child: child,
          );
        },
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          key: ValueKey<bool>(isFavorite),
          color: isFavorite ? Colors.redAccent : Colors.white70,
          size: 28,
        ),
      ),
    );
  }
}
