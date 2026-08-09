import 'package:flutter/material.dart';
import '../../../../models/movie.dart';
import '../../../../providers/auth_provider.dart';
import '../../../movie/domain/repositories/movie_repository.dart';

class FavoriteProvider with ChangeNotifier {
  final MovieRepository _repository;
  String? _userId;

  FavoriteProvider(this._repository);

  List<Movie> _favoriteMovies = [];
  List<Movie> get favoriteMovies => _favoriteMovies;

  List<Movie> _favoriteTv = [];
  List<Movie> get favoriteTv => _favoriteTv;

  List<Cast> _favoriteActors = [];
  List<Cast> get favoriteActors => _favoriteActors;

  String _favoriteSearchQuery = '';
  List<Movie> get filteredFavorites {
    if (_favoriteSearchQuery.isEmpty) return _favoriteMovies;
    return _favoriteMovies
        .where(
          (movie) => movie.title.toLowerCase().contains(
            _favoriteSearchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  void setFavoriteSearchQuery(String query) {
    _favoriteSearchQuery = query;
    notifyListeners();
  }

  String _actorSearchQuery = '';
  List<Cast> get filteredFavoriteActors {
    if (_actorSearchQuery.isEmpty) return _favoriteActors;
    return _favoriteActors
        .where(
          (actor) => actor.name.toLowerCase().contains(
            _actorSearchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  void setActorSearchQuery(String query) {
    _actorSearchQuery = query;
    notifyListeners();
  }

  void update(AuthProvider auth) {
    if (_userId != auth.user?.uid) {
      _userId = auth.user?.uid;
      if (_userId != null) {
        loadFromFirestore();
      } else {
        _favoriteMovies = [];
        _favoriteTv = [];
        _favoriteActors = [];
        loadFromLocal();
      }
    }
  }

  Future<void> refreshFavorites() async {
    if (_userId != null) {
      await loadFromFirestore();
    } else {
      await loadFromLocal();
    }
  }

  Future<void> loadFromFirestore() async {
    if (_userId == null) return;
    try {
      final results = await Future.wait([
        _repository.loadFavoritesFromFirestore(_userId!),
        _repository.loadFavoriteActorsFromFirestore(_userId!),
      ]);

      final List<Movie> allFavs = results[0] as List<Movie>;
      _favoriteMovies = allFavs.where((m) => !m.isTv).toList();
      _favoriteTv = allFavs.where((m) => m.isTv).toList();
      _favoriteActors = results[1] as List<Cast>;

      await Future.wait([
        _repository.saveFavorites(_favoriteMovies, isTv: false),
        _repository.saveFavorites(_favoriteTv, isTv: true),
        _repository.saveFavoriteActors(_favoriteActors),
      ]);

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites from Firestore: $e');
    }
  }

  Future<void> loadFromLocal() async {
    try {
      final results = await Future.wait([
        _repository.loadFavorites(isTv: false),
        _repository.loadFavorites(isTv: true),
        _repository.loadFavoriteActors(),
      ]);

      _favoriteMovies = results[0] as List<Movie>;
      _favoriteTv = results[1] as List<Movie>;
      _favoriteActors = results[2] as List<Cast>;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites from local: $e');
    }
  }

  void toggleFavorite(Movie movie) {
    final list = movie.isTv ? _favoriteTv : _favoriteMovies;
    final index = list.indexWhere((m) => m.id == movie.id);
    bool isFav;
    if (index != -1) {
      list.removeAt(index);
      isFav = false;
    } else {
      list.insert(0, movie);
      isFav = true;
    }

    _repository.saveFavorites(list, isTv: movie.isTv);

    if (_userId != null) {
      _repository.syncFavoriteToFirestore(_userId!, movie, isFav);
    }
    notifyListeners();
  }

  void toggleFavoriteActor(Cast actor) {
    final index = _favoriteActors.indexWhere((a) => a.id == actor.id);
    bool isFav;
    if (index != -1) {
      _favoriteActors.removeAt(index);
      isFav = false;
    } else {
      _favoriteActors.insert(0, actor);
      isFav = true;
    }

    _repository.saveFavoriteActors(_favoriteActors);

    if (_userId != null) {
      _repository.syncActorToFirestore(_userId!, actor, isFav);
    }
    notifyListeners();
  }

  bool isFavorite(int movieId) {
    return _favoriteMovies.any((m) => m.id == movieId) ||
        _favoriteTv.any((m) => m.id == movieId);
  }

  bool isFavoriteActor(int actorId) {
    return _favoriteActors.any((a) => a.id == actorId);
  }
}
