import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../../models/movie.dart';
import '../../../movie/presentation/providers/movie_provider.dart';
import '../../../favorite/presentation/providers/favorite_provider.dart';
import '../../../../providers/history_provider.dart';

class MovieDetailProvider extends ChangeNotifier {
  final MovieProvider movieProvider;
  final FavoriteProvider favoriteProvider;
  final HistoryProvider historyProvider;
  final Movie movie;

  MovieDetailProvider({
    required this.movieProvider,
    required this.favoriteProvider,
    required this.historyProvider,
    required this.movie,
  });

  Future<void> init() async {
    await movieProvider.loadMovieExtras(
      movie,
      history: historyProvider.allHistory,
    );
  }

  void playTrailer(BuildContext context, String? key) async {
    if (key != null) {
      final url = Uri.parse('https://www.youtube.com/watch?v=$key');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Trailer not available')));
    }
  }

  String getFormattedRating(String? cert) {
    if (cert == null || cert.isEmpty) return 'General';
    if (cert.toUpperCase() == 'R') return 'For 18+';
    return cert;
  }

  void watchOnPlatform(BuildContext context, String title, bool isTv) async {
    final encodedTitle = Uri.encodeComponent(title);
    final url = isTv
        ? Uri.parse('https://wetv.vip/search?q=$encodedTitle')
        : Uri.parse('https://www.netflix.com/search?q=$encodedTitle');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${isTv ? 'WeTV' : 'Netflix'}')),
      );
    }
  }

  Future<void> selectWatchDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF5C6AC4),
              onPrimary: Colors.white,
              surface: Color(0xFF1A1D2E),
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          child: Center(
            child: FittedBox(fit: BoxFit.contain, child: child!),
          ),
        );
      },
    );

    if (picked != null) {
      historyProvider.addToHistory(movie, picked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added to History: ${DateFormat('yyyy-MM-dd').format(picked)}',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void removeFromHistory(BuildContext context) {
    historyProvider.removeFromHistory(movie.id, isTv: movie.isTv);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from history'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void toggleFavorite() {
    favoriteProvider.toggleFavorite(movie);
    if (movie.isTv) {
      movieProvider.fetchTvRecommendations(
        favoriteTv: favoriteProvider.favoriteTv,
        history: historyProvider.allHistory,
      );
    } else {
      movieProvider.fetchRecommendations(
        favoriteMovies: favoriteProvider.favoriteMovies,
        history: historyProvider.allHistory,
      );
    }
  }

  bool get isFavorite => favoriteProvider.isFavorite(movie.id);
  bool get isWatched => historyProvider.isWatched(movie.id);
}
