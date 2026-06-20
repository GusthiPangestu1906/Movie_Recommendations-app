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

  List<Movie> _favoriteTv = [];
  List<Movie> get favoriteTv => _favoriteTv;

  List<Cast> _favoriteActors = [];
  List<Cast> get favoriteActors => _favoriteActors;

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
  
  bool _isDramaMode = false;
  bool get isDramaMode => _isDramaMode;

  void setDramaMode(bool value) {
    _isDramaMode = value;
    _searchResults = [];
    _tvSearchResults = [];
    notifyListeners();
  }

  // TV/Drama state
  List<Movie> _tvSeries = [];
  List<Movie> get tvSeries => _tvSeries;
  String? _selectedCountry;
  String? get selectedCountry => _selectedCountry;

  final List<String> _selectedGenreIds = [];
  List<String> get selectedGenreIds => _selectedGenreIds;

  MovieProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadFavorites();
    await loadFavoriteActors();
    fetchRecommendations();
    fetchTvSeries();
  }

  Future<void> fetchTvSeries({String? country}) async {
    _isLoading = true;
    _selectedCountry = country;
    _tvSearchResults = []; // Clear search results when switching country
    notifyListeners();
    try {
      _tvSeries = await _apiService.getTvSeries(originCountry: country);
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Movie> _tvSearchResults = [];
  List<Movie> get tvSearchResults => _tvSearchResults;

  Future<void> searchTv(String query) async {
    if (query.isEmpty) {
      _tvSearchResults = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      _tvSearchResults = await _apiService.searchMovies(query, isTv: true);
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      if (_selectedGenreIds.isNotEmpty) {
        applyGenreFilter();
      } else {
        _searchResults = [];
        _suggestions = [];
        notifyListeners();
      }
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _isLoading = true;
      notifyListeners();
      try {
        final genreString = _selectedGenreIds.isEmpty ? null : _selectedGenreIds.join(',');
        _searchResults = await _apiService.searchMovies(query, withGenres: genreString);
        
        // If results are sparse and it's a long title, try a more aggressive approach if needed
        // but typically searchMovies handles long titles well if encoded.

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
    
    // Auto-apply if there's an active search or if query is empty
    // This allows "combining" genres with the current search query
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
      final cast = await _apiService.getMovieCast(movie.id, isTv: movie.isTv);
      final trailer = await _apiService.getMovieTrailer(movie.id, isTv: movie.isTv);
      final certification = await _apiService.getMovieCertification(movie.id, isTv: movie.isTv);
      _relatedMovies = await _apiService.getRecommendations(movie.id);
      movie.cast = cast;
      movie.trailerKey = trailer;
      movie.certification = certification;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<Cast?> getFullActorDetails(int actorId) async {
    // Only basic loading for person info initially
    return await _apiService.getPersonDetails(actorId);
  }

  Future<Map<String, List<Movie>>> fetchVerifiedWork(int actorId) async {
    return await _apiService.getVerifiedFilmography(actorId);
  }

  void toggleFavorite(Movie movie, {List<Movie>? history}) {
    final list = movie.isTv ? _favoriteTv : _favoriteMovies;
    final index = list.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      list.removeAt(index);
    } else {
      list.insert(0, movie);
    }
    saveFavorites();
    fetchRecommendations(history: history);
    notifyListeners();
  }

  void toggleFavoriteActor(Cast actor) {
    final index = _favoriteActors.indexWhere((a) => a.id == actor.id);
    if (index != -1) {
      _favoriteActors.removeAt(index);
    } else {
      _favoriteActors.insert(0, actor);
    }
    saveFavoriteActors();
    notifyListeners();
  }

  bool isFavoriteActor(int actorId) {
    return _favoriteActors.any((a) => a.id == actorId);
  }

  Future<void> saveFavoriteActors() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      _favoriteActors.map((a) => {
        'id': a.id,
        'name': a.name,
        'profile_path': a.profilePath,
      }).toList(),
    );
    await prefs.setString('favorite_actors', encodedData);
  }

  Future<void> loadFavoriteActors() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('favorite_actors');
    if (encodedData != null) {
      final List decodedData = json.decode(encodedData);
      _favoriteActors = decodedData.map((a) => Cast.fromJson(a)).toList();
      notifyListeners();
    }
  }

  bool isFavorite(int movieId) {
    return _favoriteMovies.any((m) => m.id == movieId) || _favoriteTv.any((m) => m.id == movieId);
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedMovies = json.encode(
      _favoriteMovies.map((m) => _movieToMap(m)).toList(),
    );
    final String encodedTv = json.encode(
      _favoriteTv.map((m) => _movieToMap(m)).toList(),
    );
    await prefs.setString('favorites', encodedMovies);
    await prefs.setString('favorites_tv', encodedTv);
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
      'isTv': m.isTv,
    };
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedMovies = prefs.getString('favorites');
    final String? encodedTv = prefs.getString('favorites_tv');
    
    if (encodedMovies != null) {
      final List decodedData = json.decode(encodedMovies);
      _favoriteMovies = decodedData.map((m) => Movie.fromJson(m, isTv: false)).toList();
    }
    if (encodedTv != null) {
      final List decodedData = json.decode(encodedTv);
      _favoriteTv = decodedData.map((m) => Movie.fromJson(m, isTv: true)).toList();
    }
    notifyListeners();
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
