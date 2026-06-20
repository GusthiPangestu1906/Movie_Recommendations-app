import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import 'movie_provider.dart';

class HistoryProvider with ChangeNotifier {
  List<Movie> _history = [];
  List<Movie> get history => _history;

  List<Movie> _tvHistory = [];
  List<Movie> get tvHistory => _tvHistory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  
  List<Movie> get filteredHistory {
    final list = _searchQuery.isEmpty ? _history : _history.where((movie) => movie.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    return list..sort((a, b) => (b.watchDate ?? DateTime(0)).compareTo(a.watchDate ?? DateTime(0)));
  }

  List<Movie> get filteredTvHistory {
    final list = _searchQuery.isEmpty ? _tvHistory : _tvHistory.where((movie) => movie.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    return list..sort((a, b) => (b.watchDate ?? DateTime(0)).compareTo(a.watchDate ?? DateTime(0)));
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  bool isWatched(int movieId) {
    return _history.any((movie) => movie.id == movieId) || _tvHistory.any((movie) => movie.id == movieId);
  }

  DateTime? getWatchDate(int movieId) {
    try {
      return [..._history, ..._tvHistory].firstWhere((movie) => movie.id == movieId).watchDate;
    } catch (_) {
      return null;
    }
  }

  MovieProvider? _movieProvider;

  HistoryProvider() {
    _loadHistory();
  }

  void update(MovieProvider movieProvider) {
    _movieProvider = movieProvider;
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? movieData = prefs.getString('watch_history');
    final String? tvData = prefs.getString('watch_history_tv');
    
    if (movieData != null) {
      final List<dynamic> decoded = json.decode(movieData);
      _history = decoded.map((item) => _mapToMovie(item, false)).toList();
    }
    if (tvData != null) {
      final List<dynamic> decoded = json.decode(tvData);
      _tvHistory = decoded.map((item) => _mapToMovie(item, true)).toList();
    }
    notifyListeners();
  }

  Movie _mapToMovie(dynamic item, bool isTv) {
    final movie = Movie.fromJson(item, isTv: isTv);
    if (item['watch_date'] != null) {
      movie.watchDate = DateTime.parse(item['watch_date']);
    }
    return movie;
  }

  Future<void> addToHistory(Movie movie, DateTime watchDate) async {
    final list = movie.isTv ? _tvHistory : _history;
    final existingIndex = list.indexWhere((item) => item.id == movie.id);
    
    if (existingIndex != -1) {
      list.removeAt(existingIndex);
    }
    
    movie.watchDate = watchDate;
    list.insert(0, movie);
    list.sort((a, b) => (b.watchDate ?? DateTime.now()).compareTo(a.watchDate ?? DateTime.now()));

    notifyListeners();
    await _saveHistory();
    _movieProvider?.fetchRecommendations(history: _history);
  }

  Future<void> removeFromHistory(int movieId, {bool isTv = false}) async {
    final list = isTv ? _tvHistory : _history;
    list.removeWhere((movie) => movie.id == movieId);
    notifyListeners();
    await _saveHistory();
    _movieProvider?.fetchRecommendations(history: _history);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('watch_history', json.encode(_history.map((m) => _movieToMap(m)).toList()));
    await prefs.setString('watch_history_tv', json.encode(_tvHistory.map((m) => _movieToMap(m)).toList()));
  }

  Map<String, dynamic> _movieToMap(Movie m) {
    return {
      'id': m.id,
      'title': m.title,
      'overview': m.overview,
      'poster_path': m.posterPath,
      'backdrop_path': m.backdropPath,
      'vote_average': m.voteAverage,
      'release_date': m.releaseDate,
      'watch_date': m.watchDate?.toIso8601String(),
      'isTv': m.isTv,
    };
  }
}
