import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String _apiKey = '12d2377d20d4f51bf7c4c31f6b13a70b';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> getNowPlayingMovies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/now_playing?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<List<Movie>> getMoviesByCategory(String category, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$category?api_key=$_apiKey&page=$page'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
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

  Future<List<Movie>> getRecommendations(int movieId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId/recommendations?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      return [];
    }
  }

  Future<List<Movie>> getDetails(int movieId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return [Movie.fromJson(data)];
    } else {
      return [];
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to search movies');
    }
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId/credits?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List castList = data['cast'];
      return castList.take(10).map((c) => Cast.fromJson(c)).toList();
    } else {
      return [];
    }
  }

  Future<String?> getMovieTrailer(int movieId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId/videos?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
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

  Future<String?> getMovieCertification(int movieId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId/release_dates?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
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
}
