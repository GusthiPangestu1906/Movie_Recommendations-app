import 'package:flutter/material.dart';
import '../../../../models/movie.dart';
import '../../../movie/presentation/providers/movie_provider.dart';

import '../../../favorite/presentation/providers/favorite_provider.dart';
import '../../../search/presentation/providers/search_provider.dart';

class ActorDetailProvider extends ChangeNotifier {
  final MovieProvider movieProvider;
  final FavoriteProvider favoriteProvider;
  final SearchProvider searchProvider;
  final int actorId;

  Cast? _actorDetails;
  List<Movie>? _verifiedMovies;
  List<Movie>? _verifiedTv;
  bool _isLoadingBasic = true;
  bool _isLoadingFilmography = true;
  bool _isBiographyExpanded = false;

  ActorDetailProvider({
    required this.movieProvider,
    required this.favoriteProvider,
    required this.searchProvider,
    required this.actorId,
  });

  Cast? get actorDetails => _actorDetails;
  List<Movie>? get verifiedMovies => _verifiedMovies;
  List<Movie>? get verifiedTv => _verifiedTv;
  bool get isLoadingBasic => _isLoadingBasic;
  bool get isLoadingFilmography => _isLoadingFilmography;
  bool get isBiographyExpanded => _isBiographyExpanded;

  void toggleBiography() {
    _isBiographyExpanded = !_isBiographyExpanded;
    notifyListeners();
  }

  Future<void> loadActorData() async {
    _isLoadingBasic = true;
    _isLoadingFilmography = true;
    notifyListeners();

    try {
      final details = await movieProvider.getFullActorDetails(actorId);

      if (details != null) {
        _actorDetails = details;
        _isLoadingBasic = false;
        notifyListeners();

        final work = await movieProvider.fetchVerifiedWork(actorId);
        _verifiedMovies = work['movies'];
        _verifiedTv = work['tv'];
        _isLoadingFilmography = false;
        notifyListeners();
      } else {
        // Fallback logic
        Cast? fallbackActor;

        try {
          fallbackActor = favoriteProvider.favoriteActors.firstWhere(
            (a) => a.id == actorId,
          );
        } catch (_) {}

        if (fallbackActor == null) {
          try {
            fallbackActor = searchProvider.globalActorSearchResults.firstWhere(
              (a) => a.id == actorId,
            );
          } catch (_) {}
        }

        if (fallbackActor != null) {
          _actorDetails = fallbackActor;
        }

        _isLoadingBasic = false;
        _isLoadingFilmography = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoadingBasic = false;
      _isLoadingFilmography = false;
      notifyListeners();
    }
  }
}
