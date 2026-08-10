import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../models/movie.dart';
import '../../../../providers/auth_provider.dart';
import '../../domain/repositories/movie_repository.dart';

class MovieProvider with ChangeNotifier {
  final MovieRepository _repository;
  String? _userId;

  MovieProvider(this._repository);

  List<Movie> _movies = [];
  List<Movie> get movies => _movies;

  List<Movie> _recommendations = [];
  List<Movie> get recommendations => _recommendations;

  List<Movie> _tvRecommendations = [];
  List<Movie> get tvRecommendations => _tvRecommendations;

  List<Movie> _relatedMovies = [];
  List<Movie> get relatedMovies => _relatedMovies;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  int _currentPage = 1;
  String _currentCategory = 'popular';

  void update(AuthProvider auth) {
    if (_userId != auth.user?.uid) {
      _userId = auth.user?.uid;
    }
  }

  void _syncWithHistory(List<Movie> list, List<Movie> history) {
    if (history.isEmpty) return;
    for (var movie in list) {
      final historyItem = history.firstWhere(
        (h) => h.id == movie.id && h.isTv == movie.isTv,
        orElse: () => movie,
      );
      if (historyItem.watchDate != null) {
        movie.watchDate = historyItem.watchDate;
      }
    }
  }

  Future<void> fetchNowPlaying({List<Movie>? history}) async {
    _isLoading = true;
    _currentPage = 1;
    notifyListeners();
    try {
      _movies = await _repository.getNowPlayingMovies();
      if (history != null) _syncWithHistory(_movies, history);
    } catch (e) {
      debugPrint('Error fetching now playing: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchByCategory(String category, {List<Movie>? history}) async {
    _isLoading = true;
    _currentPage = 1;
    _currentCategory = category;
    notifyListeners();
    try {
      _movies = await _repository.getMoviesByCategory(
        category,
        page: _currentPage,
      );
      if (history != null) _syncWithHistory(_movies, history);
    } catch (e) {
      debugPrint('Error fetching category $category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNextPage({List<Movie>? history}) async {
    if (_isFetchingMore) return;
    _isFetchingMore = true;
    notifyListeners();

    _currentPage++;
    try {
      List<Movie> nextMovies = await _repository.getMoviesByCategory(
        _currentCategory,
        page: _currentPage,
      );
      if (history != null) _syncWithHistory(nextMovies, history);
      _movies.addAll(nextMovies);
    } catch (e) {
      debugPrint('Error fetching next page: $e');
      _currentPage--;
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecommendations({
    List<Movie>? favoriteMovies,
    List<Movie>? history,
  }) async {
    if (favoriteMovies != null && favoriteMovies.isNotEmpty) {
      try {
        final latestFavorite = favoriteMovies.first;
        _recommendations = await _repository.getRecommendations(
          latestFavorite.id,
          isTv: false,
        );
        if (history != null) {
          _syncWithHistory(_recommendations, history);
        }
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('Error fetching favorite-based recommendations: $e');
      }
    }

    if (history != null && history.isNotEmpty) {
      final movieHistory = history.where((m) => !m.isTv).toList();
      if (movieHistory.isNotEmpty) {
        try {
          final latestHistory = movieHistory.first;
          _recommendations = await _repository.getRecommendations(
            latestHistory.id,
            isTv: false,
          );
          _syncWithHistory(_recommendations, history);
          notifyListeners();
          return;
        } catch (e) {
          debugPrint('Error fetching history-based recommendations: $e');
        }
      }
    }

    _recommendations = [];
    notifyListeners();
  }

  Future<void> fetchTvRecommendations({
    List<Movie>? favoriteTv,
    List<Movie>? history,
  }) async {
    if (favoriteTv != null && favoriteTv.isNotEmpty) {
      try {
        final latestFavorite = favoriteTv.first;
        _tvRecommendations = await _repository.getRecommendations(
          latestFavorite.id,
          isTv: true,
        );
        if (history != null) {
          _syncWithHistory(_tvRecommendations, history);
        }
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('Error fetching favorite-based TV recommendations: $e');
      }
    }

    if (history != null && history.isNotEmpty) {
      final tvHistory = history.where((m) => m.isTv).toList();
      if (tvHistory.isNotEmpty) {
        try {
          final latestHistory = tvHistory.first;
          _tvRecommendations = await _repository.getRecommendations(
            latestHistory.id,
            isTv: true,
          );
          _syncWithHistory(_tvRecommendations, history);
          notifyListeners();
          return;
        } catch (e) {
          debugPrint('Error fetching history-based TV recommendations: $e');
        }
      }
    }

    _tvRecommendations = [];
    notifyListeners();
  }

  Future<void> loadMovieExtras(Movie movie, {List<Movie>? history}) async {
    if (movie.cast != null &&
        movie.trailerKey != null &&
        movie.certification != null) {
      try {
        _relatedMovies = await _repository.getRecommendations(
          movie.id,
          isTv: movie.isTv,
        );
        if (history != null) _syncWithHistory(_relatedMovies, history);
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading related movies: $e');
      }
      return;
    }

    try {
      final results = await Future.wait([
        _repository.getMovieCast(movie.id, isTv: movie.isTv),
        _repository.getMovieTrailer(movie.id, isTv: movie.isTv),
        _repository.getMovieCertification(movie.id, isTv: movie.isTv),
        _repository.getRecommendations(movie.id, isTv: movie.isTv),
      ]);

      movie.cast = results[0] as List<Cast>;
      movie.trailerKey = results[1] as String?;
      movie.certification = results[2] as String?;
      _relatedMovies = results[3] as List<Movie>;

      if (history != null) _syncWithHistory(_relatedMovies, history);

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading movie extras: $e');
    }
  }

  Future<Cast?> getFullActorDetails(int actorId) async {
    try {
      return await _repository.getPersonDetails(actorId);
    } catch (e) {
      debugPrint('Error fetching actor details: $e');
      return null;
    }
  }

  Future<Map<String, List<Movie>>> fetchVerifiedWork(int actorId) async {
    try {
      return await _repository.getVerifiedFilmography(actorId);
    } catch (e) {
      debugPrint('Error fetching filmography: $e');
      return {'movies': [], 'tv': []};
    }
  }

  Future<List<Movie>> searchForHistory(
    String query, {
    bool isTv = false,
  }) async {
    try {
      return await _repository.searchMovies(query, isTv: isTv);
    } catch (e) {
      debugPrint('Error searching for history: $e');
      return [];
    }
  }
}
