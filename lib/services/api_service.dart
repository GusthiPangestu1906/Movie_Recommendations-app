import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String _apiKey = '12d2377d20d4f51bf7c4c31f6b13a70b';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // Simple in-memory cache
  final Map<String, dynamic> _cache = {};

  Future<dynamic> _getWithCache(String url) async {
    if (_cache.containsKey(url)) {
      return _cache[url];
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _cache[url] = data;
      return data;
    }
    return null;
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    final data = await _getWithCache('$_baseUrl/movie/now_playing?api_key=$_apiKey');
    if (data != null) {
      final List results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<List<Movie>> getTvSeries({int page = 1, String? originCountry}) async {
    var url = '$_baseUrl/discover/tv?api_key=$_apiKey&page=$page&sort_by=popularity.desc';
    if (originCountry != null && originCountry.isNotEmpty) {
      url += '&with_origin_country=$originCountry';
    }
    
    final data = await _getWithCache(url);
    if (data != null) {
      final List results = data['results'];
      return results.map((tv) => Movie.fromJson(tv, isTv: true)).toList();
    } else {
      throw Exception('Failed to load TV series');
    }
  }

  Future<List<Movie>> getMoviesByCategory(String category, {int page = 1}) async {
    final data = await _getWithCache('$_baseUrl/movie/$category?api_key=$_apiKey&page=$page');
    if (data != null) {
      final List results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load movies by category');
    }
  }

  Future<List<Movie>> discoverMovies({int page = 1, String? releaseDateGte, String? releaseDateLte, String? withGenres}) async {
    var url = '$_baseUrl/discover/movie?api_key=$_apiKey&page=$page&sort_by=popularity.desc';
    if (releaseDateGte != null) url += '&primary_release_date.gte=$releaseDateGte';
    if (releaseDateLte != null) url += '&primary_release_date.lte=$releaseDateLte';
    if (withGenres != null) url += '&with_genres=$withGenres';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to discover movies');
    }
  }

  Future<List<Movie>> getRecommendations(int movieId, {bool isTv = false}) async {
    final type = isTv ? 'tv' : 'movie';
    final data = await _getWithCache('$_baseUrl/$type/$movieId/recommendations?api_key=$_apiKey');
    if (data != null) {
      final List results = data['results'];
      return results.map((movie) => Movie.fromJson(movie, isTv: isTv)).toList();
    } else {
      return [];
    }
  }

  Future<List<Movie>> getDetails(int movieId, {bool isTv = false}) async {
    final type = isTv ? 'tv' : 'movie';
    final data = await _getWithCache('$_baseUrl/$type/$movieId?api_key=$_apiKey');
    if (data != null) {
      return [Movie.fromJson(data, isTv: isTv)];
    } else {
      return [];
    }
  }

  Future<List<Movie>> searchMovies(String query, {String? withGenres, bool isTv = false}) async {
    final encodedQuery = Uri.encodeComponent(query);
    final type = isTv ? 'tv' : 'movie';
    var url = '$_baseUrl/search/$type?api_key=$_apiKey&query=$encodedQuery';
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      var items = results.map((item) => Movie.fromJson(item, isTv: isTv)).toList();
      
      if (withGenres != null && withGenres.isNotEmpty) {
        final genreList = withGenres.split(',').map((id) => int.tryParse(id)).whereType<int>().toList();
        items = items.where((item) {
          // This assumes genre_ids exist in the response for TV too
          final List<dynamic> gIds = (results.firstWhere((r) => r['id'] == item.id, orElse: () => {})['genre_ids'] ?? []);
          return gIds.any((id) => genreList.contains(id));
        }).toList();
      }
      return items;
    } else {
      throw Exception('Failed to search');
    }
  }

  Future<List<Cast>> getMovieCast(int movieId, {bool isTv = false}) async {
    final type = isTv ? 'tv' : 'movie';
    final data = await _getWithCache('$_baseUrl/$type/$movieId/credits?api_key=$_apiKey');
    if (data != null) {
      final List castList = data['cast'];
      return castList.take(10).map((c) => Cast.fromJson(c)).toList();
    } else {
      return [];
    }
  }

  Future<String?> getMovieTrailer(int movieId, {bool isTv = false}) async {
    final type = isTv ? 'tv' : 'movie';
    final data = await _getWithCache('$_baseUrl/$type/$movieId/videos?api_key=$_apiKey');
    if (data != null) {
      final List results = data['results'];
      final trailer = results.firstWhere(
        (v) => v['type'] == 'Trailer' && v['site'] == 'YouTube',
        orElse: () => null,
      );
      return trailer?['key'];
    } else {
      return null;
    }
  }

  Future<String?> getMovieCertification(int movieId, {bool isTv = false}) async {
    if (isTv) return 'TV-PG'; // Simplify for TV for now or fetch /tv/{id}/content_ratings
    final data = await _getWithCache('$_baseUrl/movie/$movieId/release_dates?api_key=$_apiKey');
    if (data != null) {
      final List results = data['results'];
      
      // Try to find US certification as it's the most common
      final usResult = results.firstWhere(
        (r) => r['iso_3166_1'] == 'US',
        orElse: () => results.isNotEmpty ? results.first : null,
      );

      if (usResult != null) {
        final List releaseDates = usResult['release_dates'];
        final cert = releaseDates.firstWhere(
          (d) => d['certification'] != null && d['certification'].toString().isNotEmpty,
          orElse: () => null,
        );
        return cert?['certification'];
      }
    }
    return null;
  }

  Future<Cast?> getPersonDetails(int personId) async {
    final url = '$_baseUrl/person/$personId?api_key=$_apiKey&append_to_response=combined_credits';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Cast.fromJson(data);
    }
    return null;
  }

  Future<Map<String, List<Movie>>> getVerifiedFilmography(int personId) async {
    final url = '$_baseUrl/person/$personId/combined_credits?api_key=$_apiKey';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List credits = data['cast'] ?? [];
      
      final seenIds = <int>{};
      final List<Movie> verifiedMovies = [];
      final List<Movie> candidateTv = [];

      for (var item in credits) {
        final id = item['id'];
        if (id == null || seenIds.contains(id)) continue;
        
        final bool isTv = item['media_type'] == 'tv';
        final movie = Movie.fromJson(item, isTv: isTv);
        
        if (isTv) {
          candidateTv.add(movie);
        } else {
          verifiedMovies.add(movie);
        }
        seenIds.add(id);
      }

      // Sort by popularity
      verifiedMovies.sort((a, b) {
        final double popA = (credits.firstWhere((c) => c['id'] == a.id)['popularity'] as num?)?.toDouble() ?? 0.0;
        final double popB = (credits.firstWhere((c) => c['id'] == b.id)['popularity'] as num?)?.toDouble() ?? 0.0;
        return popB.compareTo(popA);
      });

      candidateTv.sort((a, b) {
        final double popA = (credits.firstWhere((c) => c['id'] == a.id)['popularity'] as num?)?.toDouble() ?? 0.0;
        final double popB = (credits.firstWhere((c) => c['id'] == b.id)['popularity'] as num?)?.toDouble() ?? 0.0;
        return popB.compareTo(popA);
      });

      // Verify TV in parallel - Optimized: Only check top 10 and skip if character info is already present
      final List<Future<Movie?>> verificationTasks = candidateTv.take(12).map((tv) async {
        // Optimization: If character is already known from combined_credits, we trust it as verified
        if (tv.character != null && tv.character!.isNotEmpty) {
          return tv;
        }

        try {
          final creditUrl = '$_baseUrl/tv/${tv.id}/credits?api_key=$_apiKey';
          final creditRes = await http.get(Uri.parse(creditUrl));
          if (creditRes.statusCode == 200) {
            final creditData = json.decode(creditRes.body);
            final List castList = creditData['cast'] ?? [];
            if (castList.any((c) => c['id'] == personId)) return tv;
          }
        } catch (_) {}
        return null;
      }).toList();

      final List<Movie?> results = await Future.wait(verificationTasks);
      final List<Movie> verifiedTv = results.whereType<Movie>().toList();

      return {
        'movies': verifiedMovies.take(20).toList(),
        'tv': verifiedTv,
      };
    }
    return {'movies': [], 'tv': []};
  }
}
