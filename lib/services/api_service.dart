import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';

class ApiService {
  // KEAMANAN: API Key diambil dari environment variables atau build flags
  // Tidak ada hardcoded key di source code
  static String get _apiKey {
    const keyFromEnv = String.fromEnvironment('TMDB_API_KEY');
    if (keyFromEnv.isNotEmpty) return keyFromEnv;
    return dotenv.env['TMDB_API_KEY'] ?? '';
  }

  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // Simple in-memory cache
  final Map<String, dynamic> _cache = {};

  Future<dynamic> _makeGetRequest(
    String url, {
    bool isWikidata = false,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final uri = Uri.parse(url);

      // KEAMANAN: Persiapkan headers dengan aman
      Map<String, String>? headers;
      if (!uri.host.contains('wikidata.org') && !isWikidata) {
        headers = {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        };
        if (additionalHeaders != null) {
          headers.addAll(additionalHeaders);
        }
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      // KEAMANAN: Gunakan debugPrint agar log tidak muncul di Production
      debugPrint('API Request Error: $e');
      return null;
    }
  }

  Future<dynamic> _getWithCache(String url) async {
    if (_cache.containsKey(url)) {
      return _cache[url];
    }
    final data = await _makeGetRequest(url);
    if (data != null) {
      _cache[url] = data;
    }
    return data;
  }

  // KEAMANAN: Helper untuk build URL dengan API key di query parameter
  // (TMDB tidak support header auth, jadi key harus di URL)
  String _buildTmdbUrl(String endpoint, {Map<String, String>? params}) {
    final queryParams = {...?params, 'api_key': _apiKey};
    final uri = Uri.parse(_baseUrl + endpoint);
    return uri.replace(queryParameters: queryParams).toString();
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    if (_apiKey.isEmpty) throw Exception('API Key is missing');
    final url = _buildTmdbUrl('/movie/now_playing');
    final data = await _getWithCache(url);
    if (data != null) {
      final List results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<List<Movie>> getTvSeries({int page = 1, String? originCountry}) async {
    if (_apiKey.isEmpty) throw Exception('API Key is missing');
    final params = {
      'page': page.toString(),
      'sort_by': 'popularity.desc',
      if (originCountry != null && originCountry.isNotEmpty)
        'with_origin_country': originCountry,
    };
    final url = _buildTmdbUrl('/discover/tv', params: params);
    final data = await _getWithCache(url);
    if (data != null) {
      final List results = data['results'];
      return results.map((tv) => Movie.fromJson(tv, isTv: true)).toList();
    } else {
      throw Exception('Failed to load TV series');
    }
  }

  Future<List<Movie>> getMoviesByCategory(
    String category, {
    int page = 1,
  }) async {
    if (_apiKey.isEmpty) throw Exception('API Key is missing');
    final params = {'page': page.toString()};
    final url = _buildTmdbUrl('/movie/$category', params: params);
    final data = await _getWithCache(url);
    if (data != null) {
      final List results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load movies by category');
    }
  }

  Future<List<Movie>> discoverMovies({
    int page = 1,
    String? releaseDateGte,
    String? releaseDateLte,
    String? withGenres,
  }) async {
    if (_apiKey.isEmpty) throw Exception('API Key is missing');
    final params = {
      'page': page.toString(),
      'sort_by': 'popularity.desc',
      if (releaseDateGte != null) 'primary_release_date.gte': releaseDateGte,
      if (releaseDateLte != null) 'primary_release_date.lte': releaseDateLte,
      if (withGenres != null) 'with_genres': withGenres,
    };
    final url = _buildTmdbUrl('/discover/movie', params: params);
    final data = await _makeGetRequest(url);

    if (data != null) {
      final List results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to discover movies');
    }
  }

  Future<List<Movie>> getRecommendations(
    int movieId, {
    bool isTv = false,
  }) async {
    if (_apiKey.isEmpty) throw Exception('API Key is missing');
    final type = isTv ? 'tv' : 'movie';
    final url = _buildTmdbUrl('/$type/$movieId/recommendations');
    final data = await _getWithCache(url);
    if (data != null) {
      final List results = data['results'];
      return results.map((movie) => Movie.fromJson(movie, isTv: isTv)).toList();
    } else {
      return [];
    }
  }

  Future<List<Movie>> getDetails(int movieId, {bool isTv = false}) async {
    if (_apiKey.isEmpty) throw Exception('API Key is missing');
    final type = isTv ? 'tv' : 'movie';
    final url = _buildTmdbUrl('/$type/$movieId');
    final data = await _getWithCache(url);
    if (data != null) {
      return [Movie.fromJson(data, isTv: isTv)];
    } else {
      return [];
    }
  }

  Future<List<Movie>> searchMovies(
    String query, {
    String? withGenres,
    bool isTv = false,
    int page = 1,
  }) async {
    if (_apiKey.isEmpty) throw Exception('API Key is missing');
    final type = isTv ? 'tv' : 'movie';
    final params = {
      'query': query,
      'page': page.toString(),
      if (withGenres != null) 'with_genres': withGenres,
    };
    final url = _buildTmdbUrl('/search/$type', params: params);
    final data = await _makeGetRequest(url);

    if (data != null) {
      final List results = data['results'] ?? [];

      if (withGenres != null && withGenres.isNotEmpty) {
        final genreSet = withGenres
            .split(',')
            .map((id) => int.tryParse(id))
            .whereType<int>()
            .toSet();

        return results
            .where((item) {
              final List<dynamic> genreIds = item['genre_ids'] ?? [];
              return genreIds.any((id) => genreSet.contains(id));
            })
            .map((item) => Movie.fromJson(item, isTv: isTv))
            .toList();
      }

      return results.map((item) => Movie.fromJson(item, isTv: isTv)).toList();
    } else {
      throw Exception('Failed to search');
    }
  }

  Future<List<Cast>> getMovieCast(int movieId, {bool isTv = false}) async {
    if (_apiKey.isEmpty) throw Exception('API Key is missing');
    final type = isTv ? 'tv' : 'movie';
    final url = _buildTmdbUrl('/$type/$movieId/credits');
    final data = await _getWithCache(url);
    if (data != null) {
      final List castList = data['cast'];
      return castList.take(10).map((c) => Cast.fromJson(c)).toList();
    } else {
      return [];
    }
  }

  Future<String?> getMovieTrailer(int movieId, {bool isTv = false}) async {
    if (_apiKey.isEmpty) throw Exception('API Key is missing');
    final type = isTv ? 'tv' : 'movie';
    final url = _buildTmdbUrl('/$type/$movieId/videos');
    final data = await _getWithCache(url);
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

  Future<String?> getMovieCertification(
    int movieId, {
    bool isTv = false,
  }) async {
    if (isTv) return 'TV-PG';
    if (_apiKey.isEmpty) throw Exception('API Key is missing');
    final url = _buildTmdbUrl('/movie/$movieId/release_dates');
    final data = await _getWithCache(url);
    if (data != null) {
      final List results = data['results'];
      final usResult = results.firstWhere(
        (r) => r['iso_3166_1'] == 'US',
        orElse: () => results.isNotEmpty ? results.first : null,
      );

      if (usResult != null) {
        final List releaseDates = usResult['release_dates'];
        final cert = releaseDates.firstWhere(
          (d) =>
              d['certification'] != null &&
              d['certification'].toString().isNotEmpty,
          orElse: () => null,
        );
        return cert?['certification'];
      }
    }
    return null;
  }

  Future<List<Cast>> searchActors(String query) async {
    if (_apiKey.isEmpty) throw Exception('API Key is missing');
    final params = {'query': query};
    final url = _buildTmdbUrl('/search/person', params: params);

    final data = await _makeGetRequest(url);

    if (data != null) {
      final List results = data['results'] ?? [];
      List<Cast> actors = results.map((c) => Cast.fromJson(c)).toList();
      if (actors.isEmpty) {
        actors = await searchWikidataActors(query);
      }
      return actors;
    } else {
      throw Exception('Failed to search actors');
    }
  }

  Future<List<Cast>> searchWikidataActors(String query) async {
    // Gunakan Uri.https untuk konstruksi URL yang lebih aman
    final searchUri = Uri.https('www.wikidata.org', '/w/api.php', {
      'origin': '*',
      'action': 'wbsearchentities',
      'search': query,
      'language': 'id',
      'format': 'json',
    });

    try {
      final data = await _makeGetRequest(
        searchUri.toString(),
        isWikidata: true,
      );
      if (data == null) return [];

      final List searchResults = data['search'] ?? [];
      final itemsToFetch = searchResults.take(5).toList();

      final results = await Future.wait(
        itemsToFetch.map((item) async {
          final String qid = item['id'];
          final String name = item['label'] ?? 'Unknown';
          final String description = (item['description'] ?? '').toLowerCase();

          bool isLikelyPerson =
              description.contains('pemeran') ||
              description.contains('aktris') ||
              description.contains('aktor') ||
              description.contains('actor') ||
              description.contains('actress') ||
              description.contains('human') ||
              description.contains('sutradara');

          if (!isLikelyPerson) return null;

          final detailUri = Uri.https('www.wikidata.org', '/w/api.php', {
            'origin': '*',
            'action': 'wbgetentities',
            'ids': qid,
            'props': 'claims',
            'format': 'json',
          });

          final detailData = await _makeGetRequest(
            detailUri.toString(),
            isWikidata: true,
          );

          String? imageUrl;
          if (detailData != null &&
              detailData['entities'] != null &&
              detailData['entities'][qid] != null) {
            final claims = detailData['entities'][qid]['claims'];
            if (claims != null && claims['P18'] != null) {
              final String imageName =
                  claims['P18'][0]['mainsnak']['datavalue']['value'];
              final encodedImage = Uri.encodeComponent(
                imageName.replaceAll(' ', '_'),
              );
              imageUrl =
                  'https://commons.wikimedia.org/wiki/Special:FilePath/$encodedImage?width=500';
            }
          }

          return Cast(
            id: qid.hashCode,
            name: name,
            profilePath: imageUrl,
            character: item['description'] ?? 'Wikidata Entity',
          );
        }),
      );

      return results.whereType<Cast>().toList();
    } catch (e) {
      debugPrint('Wikidata search error: $e');
    }
    return [];
  }

  Future<Map<String, String?>> getPersonExternalIds(int personId) async {
    if (_apiKey.isEmpty) throw Exception('API Key is missing');
    final url = _buildTmdbUrl('/person/$personId/external_ids');
    final data = await _makeGetRequest(url);
    if (data != null) {
      return {
        'instagram': data['instagram_id'],
        'twitter': data['twitter_id'],
        'facebook': data['facebook_id'],
      };
    }
    return {};
  }

  Future<Cast?> getPersonDetails(int personId) async {
    if (_apiKey.isEmpty) throw Exception('API Key is missing');
    final params = {'append_to_response': 'combined_credits'};
    final url = _buildTmdbUrl('/person/$personId', params: params);
    final data = await _makeGetRequest(url);

    if (data != null) {
      final cast = Cast.fromJson(data);
      final externals = await getPersonExternalIds(personId);
      cast.instagramId = externals['instagram'];
      cast.twitterId = externals['twitter'];
      cast.facebookId = externals['facebook'];
      return cast;
    }
    return null;
  }

  Future<Map<String, List<Movie>>> getVerifiedFilmography(int personId) async {
    if (_apiKey.isEmpty) throw Exception('API Key is missing');
    final url = _buildTmdbUrl('/person/$personId/combined_credits');
    final data = await _makeGetRequest(url);

    if (data != null) {
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

      verifiedMovies.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
      candidateTv.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));

      return {
        'movies': verifiedMovies.take(20).toList(),
        'tv': candidateTv.take(10).toList(),
      };
    }
    return {'movies': [], 'tv': []};
  }
}
