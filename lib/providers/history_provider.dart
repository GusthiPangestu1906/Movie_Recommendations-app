import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import 'movie_provider.dart';

class HistoryProvider with ChangeNotifier {
  List<Movie> _history = [];
  List<Movie> get history => _history;

  String _searchQuery = '';
  List<Movie> get filteredHistory {
    if (_searchQuery.isEmpty) return _history;
    return _history
        .where((movie) =>
            movie.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  bool isWatched(int movieId) {
    return _history.any((movie) => movie.id == movieId);
  }

  DateTime? getWatchDate(int movieId) {
    try {
      return _history.firstWhere((movie) => movie.id == movieId).watchDate;
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
    final String? historyData = prefs.getString('watch_history');
    if (historyData != null) {
      final List<dynamic> decodedData = json.decode(historyData);
      _history = decodedData.map((item) {
        final movie = Movie.fromJson(item);
        if (item['watch_date'] != null) {
          movie.watchDate = DateTime.parse(item['watch_date']);
        }
        return movie;
      }).toList();
      notifyListeners();
    }
  }

  Future<void> addToHistory(Movie movie, DateTime watchDate) async {
    // Check for duplicates (same ID)
    final existingIndex = _history.indexWhere((item) => item.id == movie.id);
    
    if (existingIndex != -1) {
      // If found, check if it's the same watch date
      final existingMovie = _history[existingIndex];
      if (existingMovie.watchDate != null && 
          existingMovie.watchDate!.year == watchDate.year &&
          existingMovie.watchDate!.month == watchDate.month &&
          existingMovie.watchDate!.day == watchDate.day) {
        // Exactly the same movie on the same day, just update to be sure but don't notify/save extra if unnecessary
        return;
      }
      // If different date, remove old one to replace with new date
      _history.removeAt(existingIndex);
    }
    
    movie.watchDate = watchDate;
    
    // Insert at the beginning of the list
    _history.insert(0, movie);
    
    // Sort history by watch date (descending)
    _history.sort((a, b) => (b.watchDate ?? DateTime.now()).compareTo(a.watchDate ?? DateTime.now()));

    notifyListeners();
    await _saveHistory();

    // Trigger recommendation update in MovieProvider
    _movieProvider?.fetchRecommendations(history: _history);
  }

  Future<void> removeFromHistory(int movieId) async {
    _history.removeWhere((movie) => movie.id == movieId);
    notifyListeners();
    await _saveHistory();
    
    // Update recommendations based on new history state
    _movieProvider?.fetchRecommendations(history: _history);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String historyData = json.encode(
      _history.map((movie) => {
        'id': movie.id,
        'title': movie.title,
        'overview': movie.overview,
        'poster_path': movie.posterPath,
        'backdrop_path': movie.backdropPath,
        'vote_average': movie.voteAverage,
        'release_date': movie.releaseDate,
        'watch_date': movie.watchDate?.toIso8601String(),
      }).toList(),
    );
    await prefs.setString('watch_history', historyData);
  }

  Future<void> clearHistory() async {
    _history.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('watch_history');
    
    // Trigger recommendation update in MovieProvider
    _movieProvider?.fetchRecommendations(history: _history);
  }
}
