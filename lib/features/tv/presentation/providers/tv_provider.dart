import 'package:flutter/material.dart';
import '../../../../models/movie.dart';
import '../../../movie/domain/repositories/movie_repository.dart';

class TvProvider with ChangeNotifier {
  final MovieRepository _repository;

  TvProvider(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  int _currentTvPage = 1;

  bool _isDramaMode = false;
  bool get isDramaMode => _isDramaMode;

  List<Movie> _tvSeries = [];
  List<Movie> get tvSeries => _tvSeries;

  String? _selectedCountry;
  String? get selectedCountry => _selectedCountry;

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

  void setDramaMode(bool value) {
    _isDramaMode = value;
    notifyListeners();
  }

  Future<void> fetchTvSeries({String? country, List<Movie>? history}) async {
    _isLoading = true;
    _selectedCountry = country;
    _currentTvPage = 1;
    notifyListeners();
    try {
      _tvSeries = await _repository.getTvSeries(
        originCountry: country,
        page: _currentTvPage,
      );
      if (history != null) _syncWithHistory(_tvSeries, history);
    } catch (e) {
      debugPrint('Error fetching TV series: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreTvSeries({List<Movie>? history}) async {
    if (_isFetchingMore) return;
    _isFetchingMore = true;
    notifyListeners();

    _currentTvPage++;
    try {
      List<Movie> nextTv = await _repository.getTvSeries(
        originCountry: _selectedCountry,
        page: _currentTvPage,
      );
      if (history != null) _syncWithHistory(nextTv, history);
      _tvSeries.addAll(nextTv);
    } catch (e) {
      debugPrint('Error fetching more TV series: $e');
      _currentTvPage--;
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }
}
