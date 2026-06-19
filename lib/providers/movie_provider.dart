import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class MovieProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  Timer? _debounce;

  List<Movie> _movies = [];
  List<Movie> get movies => _movies;

  List<Movie> _searchResults = [];
  List<Movie> get searchResults => _searchResults;

  List<Movie> _suggestions = [];
  List<Movie> get suggestions => _suggestions;

  List<Movie> _favoriteMovies = [];
  List<Movie> get favoriteMovies => _favoriteMovies;

  String _favoriteSearchQuery = '';
  List<Movie> get filteredFavorites {
    if (_favoriteSearchQuery.isEmpty) return _favoriteMovies;
    return _favoriteMovies
        .where((movie) =>
            movie.title.toLowerCase().contains(_favoriteSearchQuery.toLowerCase()))
        .toList();
  }

  void setFavoriteSearchQuery(String query) {
    _favoriteSearchQuery = query;
    notifyListeners();
  }

  List<Movie> _recommendations = [];
  List<Movie> get recommendations => _recommendations;

  List<Movie> _relatedMovies = [];
  List<Movie> get relatedMovies => _relatedMovies;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  int _currentPage = 1;
  String _currentCategory = 'popular';
  
  final List<String> _selectedGenreIds = [];
  List<String> get selectedGenreIds => _selectedGenreIds;

  MovieProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadFavorites();
    fetchRecommendations();
  }

  Future<void> fetchNowPlaying() async {
    _isLoading = true;
    _currentPage = 1;
    notifyListeners();
    try {
      _movies = await _apiService.getNowPlayingMovies();
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchByCategory(String category) async {
    _isLoading = true;
    _currentPage = 1;
    _currentCategory = category;
    notifyListeners();
    try {
      _movies = await _apiService.getMoviesByCategory(category, page: _currentPage);
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNextPage() async {
    if (_isFetchingMore) return;
    _isFetchingMore = true;
    notifyListeners();

    _currentPage++;
    try {
      List<Movie> nextMovies = await _apiService.getMoviesByCategory(_currentCategory, page: _currentPage);
      _movies.addAll(nextMovies);
    } catch (e) {
      print(e);
      _currentPage--;
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecommendations({List<Movie>? history}) async {
    // Priority 1: Favorites
    if (_favoriteMovies.isNotEmpty) {
      try {
        final latestFavorite = _favoriteMovies.first;
        _recommendations = await _apiService.getRecommendations(latestFavorite.id);
        notifyListeners();
        return;
      } catch (e) {
        print('Error fetching favorite-based recommendations: $e');
      }
    }

    // Priority 2: History (if favorites are empty or fetch failed)
    if (history != null && history.isNotEmpty) {
      try {
        final latestHistory = history.first;
        _recommendations = await _apiService.getRecommendations(latestHistory.id);
        notifyListeners();
        return;
      } catch (e) {
        print('Error fetching history-based recommendations: $e');
      }
    }

    // Fallback: If both are empty, we can show popular movies or keep it empty
    _recommendations = [];
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    if (query.isEmpty) {
      _searchResults = [];
      _suggestions = [];
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _isLoading = true;
      _selectedGenreIds.clear();
      notifyListeners();
      try {
        _searchResults = await _apiService.searchMovies(query);
        _suggestions = _searchResults.take(5).toList(); // Top 5 as "guesses"
      } catch (e) {
        print(e);
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void clearSearch() {
    _searchResults = [];
    _suggestions = [];
    notifyListeners();
  }

  Future<void> searchByCategory(String category) async {
    _isLoading = true;
    _selectedGenreIds.clear();
    notifyListeners();
    try {
      _searchResults = await _apiService.getMoviesByCategory(category);
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleGenre(String genreId) {
    if (_selectedGenreIds.contains(genreId)) {
      _selectedGenreIds.remove(genreId);
    } else {
      _selectedGenreIds.add(genreId);
    }
    notifyListeners();
  }

  Future<void> applyGenreFilter() async {
    if (_selectedGenreIds.isEmpty) return;
    
    _isLoading = true;
    notifyListeners();
    try {
      final genreString = _selectedGenreIds.join(',');
      _searchResults = await _apiService.discoverMovies(withGenres: genreString);
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMovieExtras(Movie movie) async {
    if (movie.cast != null && movie.trailerKey != null && movie.certification != null) {
      // Still need to fetch related movies for the specific detail page context
      try {
        _relatedMovies = await _apiService.getRecommendations(movie.id);
        notifyListeners();
      } catch (e) {
        print(e);
      }
      return;
    }
    try {
      final cast = await _apiService.getMovieCast(movie.id);
      final trailer = await _apiService.getMovieTrailer(movie.id);
      final certification = await _apiService.getMovieCertification(movie.id);
      _relatedMovies = await _apiService.getRecommendations(movie.id);
      movie.cast = cast;
      movie.trailerKey = trailer;
      movie.certification = certification;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void toggleFavorite(Movie movie, {List<Movie>? history}) {
    final index = _favoriteMovies.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      _favoriteMovies.removeAt(index);
    } else {
      _favoriteMovies.insert(0, movie); // Insert at top for "latest" logic
    }
    saveFavorites();
    fetchRecommendations(history: history); // Update recommendations when favorites change
    notifyListeners();
  }

  bool isFavorite(int movieId) {
    return _favoriteMovies.any((m) => m.id == movieId);
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      _favoriteMovies.map((m) => {
        'id': m.id,
        'title': m.title,
        'overview': m.overview,
        'poster_path': m.posterPath,
        'backdrop_path': m.backdropPath,
        'vote_average': m.voteAverage,
        'release_date': m.releaseDate,
      }).toList(),
    );
    await prefs.setString('favorites', encodedData);
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('favorites');
    if (encodedData != null) {
      final List decodedData = json.decode(encodedData);
      _favoriteMovies = decodedData.map((m) => Movie.fromJson(m)).toList();
      notifyListeners();
    }
  }

  Future<List<Movie>> searchForHistory(String query) async {
    try {
      return await _apiService.searchMovies(query);
    } catch (e) {
      print(e);
      return [];
    }
  }
}
