import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../models/movie.dart';
import '../../../../features/movie/presentation/providers/movie_provider.dart';
import '../../../../features/favorite/presentation/providers/favorite_provider.dart';
import '../../../../providers/history_provider.dart';
import '../providers/movie_detail_provider.dart';
import '../widgets/movie_detail_app_bar.dart';
import '../widgets/movie_info_card.dart';
import '../widgets/movie_cast_section.dart';
import '../widgets/related_movies_section.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MovieDetailProvider(
        movieProvider: Provider.of<MovieProvider>(context, listen: false),
        favoriteProvider: Provider.of<FavoriteProvider>(context, listen: false),
        historyProvider: Provider.of<HistoryProvider>(context, listen: false),
        movie: widget.movie,
      )..init(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0E1E),
        body: Consumer<MovieProvider>(
          builder: (context, movieProvider, child) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                MovieDetailAppBar(movie: widget.movie),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MovieInfoCard(movie: widget.movie),
                        const SizedBox(height: 36),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.movie.overview,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ).animate().fadeIn(delay: 600.ms),
                        const SizedBox(height: 32),
                        MovieCastSection(cast: widget.movie.cast),
                        const SizedBox(height: 32),
                        RelatedMoviesSection(
                          related: movieProvider.relatedMovies,
                          isTv: widget.movie.isTv,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
