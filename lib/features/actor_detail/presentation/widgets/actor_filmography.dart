import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../models/movie.dart';
import '../../../../pages/detail_page.dart';
import '../providers/actor_detail_provider.dart';

class ActorFilmography extends StatelessWidget {
  const ActorFilmography({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActorDetailProvider>(context);

    if (provider.isLoadingFilmography) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filmography',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) => Container(
                width: 140,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final movieCount = provider.verifiedMovies?.length ?? 0;
    final tvCount = provider.verifiedTv?.length ?? 0;

    return Column(
      children: [
        if (movieCount > 0) ...[
          _buildCategorizedFilmography(
            context,
            'Top Movies',
            provider.verifiedMovies!,
          ),
          const SizedBox(height: 32),
        ],
        if (tvCount > 0)
          _buildCategorizedFilmography(
            context,
            'Top TV Series',
            provider.verifiedTv!,
          ),
      ],
    );
  }

  Widget _buildCategorizedFilmography(
    BuildContext context,
    String title,
    List<Movie> list,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${list.length} items',
              style: const TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return RepaintBoundary(
                child: _buildFilmographyCard(context, item)
                    .animate(delay: (index * 100).ms)
                    .fadeIn(duration: 500.ms)
                    .scale(begin: const Offset(0.9, 0.9)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilmographyCard(BuildContext context, Movie item) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(movie: item)),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl: item.fullPosterPath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    alignment: Alignment.topCenter,
                    placeholder: (context, url) =>
                        Container(color: Colors.white10),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.movie, color: Colors.white10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  item.voteAverage.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  item.releaseDate.isNotEmpty
                      ? item.releaseDate.split('-')[0]
                      : 'N/A',
                  style: const TextStyle(color: Colors.white24, fontSize: 11),
                ),
              ],
            ),
            if (item.character != null && item.character!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  item.character!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF5C6AC4),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
