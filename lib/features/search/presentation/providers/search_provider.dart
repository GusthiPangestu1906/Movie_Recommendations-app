import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../models/movie.dart';
import '../../../movie/domain/repositories/movie_repository.dart';

class SearchProvider with ChangeNotifier {
  final MovieRepository _repository;
  Timer? _debounce;

  SearchProvider(this._repository);

  List<Movie> _searchResults = [];
  List<Movie> get searchResults => _searchResults;

  List<Movie> _tvSearchResults = [];
  List<Movie> get tvSearchResults => _tvSearchResults;

  List<Movie> _suggestions = [];
  List<Movie> get suggestions => _suggestions;

  List<Cast> _globalActorSearchResults = [];
  List<Cast> get globalActorSearchResults => _globalActorSearchResults;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  bool _isActorLoading = false;
  bool get isActorLoading => _isActorLoading;

  int _currentSearchPage = 1;
  String _lastSearchQuery = '';

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

  final List<String> _selectedGenreIds = [];
  List<String> get selectedGenreIds => _selectedGenreIds;

  void toggleGenre(String genreId) {
    if (_selectedGenreIds.contains(genreId)) {
      _selectedGenreIds.remove(genreId);
    } else {
      _selectedGenreIds.add(genreId);
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    _suggestions = [];
    notifyListeners();
  }

  Future<void> search(
    String query, {
    bool isDramaMode = false,
    String? selectedCountry,
    List<Movie>? history,
  }) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    if (query.isEmpty) {
      if (isDramaMode) {
        _tvSearchResults = [];
      } else if (_selectedGenreIds.isNotEmpty) {
        applyGenreFilter(history: history);
      } else {
        _searchResults = [];
        _suggestions = [];
      }
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _isLoading = true;
      _currentSearchPage = 1;
      _lastSearchQuery = query;
      notifyListeners();

      try {
        if (isDramaMode) {
          List<Movie> results = await _repository.searchMovies(
            query,
            isTv: true,
            page: _currentSearchPage,
          );

          if (selectedCountry != null && selectedCountry.isNotEmpty) {
            _tvSearchResults = results
                .where((m) => m.originCountry.contains(selectedCountry))
                .toList();
          } else {
            _tvSearchResults = results;
          }
          if (history != null) _syncWithHistory(_tvSearchResults, history);
        } else {
          final genreString = _selectedGenreIds.isEmpty
              ? null
              : _selectedGenreIds.join(',');
          _searchResults = await _repository.searchMovies(
            query,
            withGenres: genreString,
            page: _currentSearchPage,
          );
          if (history != null) _syncWithHistory(_searchResults, history);
          _suggestions = _searchResults.take(5).toList();
        }
      } catch (e) {
        debugPrint('Error during search: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> fetchMoreSearchResults({
    bool isDramaMode = false,
    String? selectedCountry,
    List<Movie>? history,
  }) async {
    if (_isFetchingMore) return;

    final bool isQuerySearch = _lastSearchQuery.isNotEmpty;
    final bool isGenreDiscover =
        _selectedGenreIds.isNotEmpty && _lastSearchQuery.isEmpty;

    if (!isQuerySearch && !isGenreDiscover) return;

    _isFetchingMore = true;
    notifyListeners();

    _currentSearchPage++;
    try {
      List<Movie> nextResults;
      if (isQuerySearch) {
        final genreString = _selectedGenreIds.isEmpty
            ? null
            : _selectedGenreIds.join(',');
        nextResults = await _repository.searchMovies(
          _lastSearchQuery,
          withGenres: genreString,
          isTv: isDramaMode,
          page: _currentSearchPage,
        );
      } else {
        final genreString = _selectedGenreIds.join(',');
        nextResults = await _repository.discoverMovies(
          withGenres: genreString,
          page: _currentSearchPage,
        );
      }

      if (history != null) _syncWithHistory(nextResults, history);

      if (isDramaMode) {
        _tvSearchResults.addAll(nextResults);
      } else {
        _searchResults.addAll(nextResults);
      }
    } catch (e) {
      debugPrint('Error fetching more search results: $e');
      _currentSearchPage--;
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> searchActors(String query) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    if (query.isEmpty) {
      _globalActorSearchResults = [];
      notifyListeners();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _isActorLoading = true;
      notifyListeners();
      try {
        _globalActorSearchResults = await _repository.searchActors(query);
      } catch (e) {
        debugPrint('Error searching actors: $e');
      } finally {
        _isActorLoading = false;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  Future<void> applyGenreFilter({List<Movie>? history}) async {
    if (_selectedGenreIds.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _currentSearchPage = 1;
    _lastSearchQuery = '';
    notifyListeners();
    try {
      final genreString = _selectedGenreIds.join(',');
      _searchResults = await _repository.discoverMovies(
        withGenres: genreString,
        page: _currentSearchPage,
      );
      if (history != null) _syncWithHistory(_searchResults, history);
    } catch (e) {
      debugPrint('Error applying genre filter: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchByCategory(String category, {List<Movie>? history}) async {
    _isLoading = true;
    _selectedGenreIds.clear();
    notifyListeners();
    try {
      _searchResults = await _repository.getMoviesByCategory(category);
      if (history != null) _syncWithHistory(_searchResults, history);
    } catch (e) {
      debugPrint('Error searching by category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
