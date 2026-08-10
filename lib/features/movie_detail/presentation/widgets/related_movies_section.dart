import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../models/movie.dart';
import '../../../../core/widgets/movie_card.dart';
import '../../../../core/widgets/movie_card/widgets/movie_card_shimmer.dart';

class RelatedMoviesSection extends StatelessWidget {
  final List<Movie> related;
  final bool isTv;

  const RelatedMoviesSection({
    super.key,
    required this.related,
    required this.isTv,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTv ? 'Related Dramas' : 'Related Movies',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: related.isEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) =>
                      MovieCardShimmer(isHorizontal: true),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: related.length,
                  itemBuilder: (context, index) {
                    return RepaintBoundary(
                      child:
                          MovieCard(movie: related[index], isHorizontal: true)
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
}
