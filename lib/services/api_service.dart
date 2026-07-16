import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';

class ApiService {
  // Gunakan API Key dari .env, jika gagal gunakan hardcoded key sebagai fallback (Khusus Web)
  static String get _apiKey {
    final key = dotenv.env['TMDB_API_KEY'];
    if (key != null && key.isNotEmpty) return key;
    return '12d2377d20d4f51bf7c4c31f6b13a70b'; // API Key Anda
  }
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

  Future<List<Movie>> searchMovies(String query, {String? withGenres, bool isTv = false, int page = 1}) async {
    final encodedQuery = Uri.encodeComponent(query);
    final type = isTv ? 'tv' : 'movie';
    var url = '$_baseUrl/search/$type?api_key=$_apiKey&query=$encodedQuery&page=$page';
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];
      
      if (withGenres != null && withGenres.isNotEmpty) {
        final genreSet = withGenres.split(',')
            .map((id) => int.tryParse(id))
            .whereType<int>()
            .toSet();

        return results.where((item) {
          final List<dynamic> genreIds = item['genre_ids'] ?? [];
          return genreIds.any((id) => genreSet.contains(id));
        }).map((item) => Movie.fromJson(item, isTv: isTv)).toList();
      }

      return results.map((item) => Movie.fromJson(item, isTv: isTv)).toList();
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

  Future<List<Cast>> searchActors(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = '$_baseUrl/search/person?api_key=$_apiKey&query=$encodedQuery';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];
      List<Cast> actors = results.map((c) => Cast.fromJson(c)).toList();

      // If no results from TMDB, try Wikidata
      if (actors.isEmpty) {
        actors = await searchWikidataActors(query);
      }

      return actors;
    } else {
      throw Exception('Failed to search actors');
    }
  }

  Future<List<Cast>> searchWikidataActors(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    // Mencari di Wikidata dengan prioritas bahasa Indonesia dan Inggris
    final searchUrl = 'https://www.wikidata.org/w/api.php?action=wbsearchentities&search=$encodedQuery&language=id&continue=0&format=json&uselang=id';

    try {
      final response = await http.get(Uri.parse(searchUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List searchResults = data['search'] ?? [];

        List<Cast> actors = [];
        for (var item in searchResults.take(8)) {
          final String qid = item['id'];
          final String name = item['label'] ?? 'Unknown';
          final String description = (item['description'] ?? '').toLowerCase();

          // Filter lebih luas: Cek kata kunci umum pemeran/manusia
          bool isLikelyPerson = description.contains('pemeran') ||
                                description.contains('aktris') ||
                                description.contains('aktor') ||
                                description.contains('actor') ||
                                description.contains('actress') ||
                                description.contains('human') ||
                                description.contains('indonesia');

          if (isLikelyPerson) {
            // Ambil detail entitas untuk mendapatkan gambar menggunakan API wbgetentities yang lebih stabil
            final detailUrl = 'https://www.wikidata.org/w/api.php?action=wbgetentities&ids=$qid&props=claims&format=json';

            try {
              final detailRes = await http.get(Uri.parse(detailUrl)).timeout(const Duration(seconds: 3));

              String? imageUrl;
              if (detailRes.statusCode == 200) {
                final detailData = json.decode(detailRes.body);
                if (detailData['entities'] != null && detailData['entities'][qid] != null) {
                  final claims = detailData['entities'][qid]['claims'];

                  // P18 (Image)
                  if (claims != null && claims['P18'] != null) {
                    final String imageName = claims['P18'][0]['mainsnak']['datavalue']['value'];
                    final encodedImage = Uri.encodeComponent(imageName.replaceAll(' ', '_'));
                    imageUrl = 'https://commons.wikimedia.org/wiki/Special:FilePath/$encodedImage?width=500';
                  }
                }
              }

              actors.add(Cast(
                id: qid.hashCode,
                name: name,
                profilePath: imageUrl,
                character: item['description'] ?? 'Wikidata Entity',
              ));
            } catch (e) {
              // Jika gagal ambil gambar, tetap tambahkan tanpa gambar
              actors.add(Cast(
                id: qid.hashCode,
                name: name,
                profilePath: null,
                character: item['description'] ?? 'Wikidata Entity',
              ));
            }
          }
        }
        return actors;
      }
    } catch (e) {
      print('Wikidata search error: $e');
    }
    return [];
  }

  Future<Map<String, String?>> getPersonExternalIds(int personId) async {
    final url = '$_baseUrl/person/$personId/external_ids?api_key=$_apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'instagram': data['instagram_id'],
        'twitter': data['twitter_id'],
        'facebook': data['facebook_id'],
      };
    }
    return {};
  }

  Future<Cast?> getPersonDetails(int personId) async {
    final url = '$_baseUrl/person/$personId?api_key=$_apiKey&append_to_response=combined_credits';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final cast = Cast.fromJson(data);

      // Fetch external IDs
      final externals = await getPersonExternalIds(personId);
      cast.instagramId = externals['instagram'];
      cast.twitterId = externals['twitter'];
      cast.facebookId = externals['facebook'];

      return cast;
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
