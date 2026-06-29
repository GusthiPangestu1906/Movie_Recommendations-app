import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';
import 'movie_provider.dart';
import 'auth_provider.dart';

class HistoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;
  MovieProvider? _movieProvider;

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

  void update(AuthProvider auth, MovieProvider movieProvider) {
    _movieProvider = movieProvider;
    if (_userId != auth.user?.uid) {
      _userId = auth.user?.uid;
      if (_userId != null) {
        _loadFromFirestore();
      } else {
        _history = [];
        _tvHistory = [];
        _loadHistory(); // Load local history if logged out
      }
    }
  }

  Future<void> _loadFromFirestore() async {
    if (_userId == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('history')
          .orderBy('watch_date', descending: true)
          .limit(50)
          .get(const GetOptions(source: Source.serverAndCache));

      final List<Movie> allHistory = snapshot.docs.map((doc) {
        final data = doc.data();
        final movie = Movie.fromJson(data, isTv: data['isTv'] ?? false);
        if (data['watch_date'] != null) {
          movie.watchDate = (data['watch_date'] as Timestamp).toDate();
        }
        return movie;
      }).toList();

      _history = allHistory.where((m) => !m.isTv).toList();
      _tvHistory = allHistory.where((m) => m.isTv).toList();

      notifyListeners();
    } catch (e) {
      print('Error loading history from Firestore: $e');
    }
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
    if (_userId != null) {
      await _saveToFirestore(movie);
    }
    _movieProvider?.fetchRecommendations(history: _history);
  }

  Future<void> _saveToFirestore(Movie movie) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('history')
        .doc(movie.id.toString())
        .set(_movieToFirestoreMap(movie));
  }

  Future<void> removeFromHistory(int movieId, {bool isTv = false}) async {
    final list = isTv ? _tvHistory : _history;
    list.removeWhere((movie) => movie.id == movieId);
    notifyListeners();
    await _saveHistory();
    if (_userId != null) {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('history')
          .doc(movieId.toString())
          .delete();
    }
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

  Map<String, dynamic> _movieToFirestoreMap(Movie m) {
    return {
      'id': m.id,
      'title': m.title,
      'overview': m.overview,
      'poster_path': m.posterPath,
      'backdrop_path': m.backdropPath,
      'vote_average': m.voteAverage,
      'release_date': m.releaseDate,
      'watch_date': m.watchDate != null ? Timestamp.fromDate(m.watchDate!) : null,
      'isTv': m.isTv,
    };
  }
}
