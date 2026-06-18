import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class MovieProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Movie> _movies = [];
  List<Movie> get movies => _movies;

  List<Movie> _searchResults = [];
  List<Movie> get searchResults => _searchResults;

  List<Movie> _favoriteMovies = [];
  List<Movie> get favoriteMovies => _favoriteMovies;

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

  Future<void> fetchRecommendations() async {
    if (_favoriteMovies.isEmpty) {
      _recommendations = [];
      notifyListeners();
      return;
    }

    try {
      // Get recommendations based on the most recent favorite
      final latestFavorite = _favoriteMovies.first;
      _recommendations = await _apiService.getRecommendations(latestFavorite.id);
      
      // If recommendations are sparse, try discovering by genres of favorites
      if (_recommendations.length < 5) {
        // Simple genre analysis could be added here if needed
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching recommendations: $e');
    }
  }

  Future<void> search(String query) async {
    _isLoading = true;
    _selectedGenreIds.clear();
    notifyListeners();
    try {
      _searchResults = await _apiService.searchMovies(query);
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  void toggleFavorite(Movie movie) {
    final index = _favoriteMovies.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      _favoriteMovies.removeAt(index);
    } else {
      _favoriteMovies.insert(0, movie); // Insert at top for "latest" logic
    }
    saveFavorites();
    fetchRecommendations(); // Update recommendations when favorites change
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
}
