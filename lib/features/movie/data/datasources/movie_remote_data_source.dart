import '../../../../core/network/api_client.dart';
import '../../../../models/movie.dart';

abstract class MovieRemoteDataSource {
  Future<List<Movie>> getNowPlayingMovies();
  Future<List<Movie>> getTvSeries({int page = 1, String? originCountry});
  Future<List<Movie>> getMoviesByCategory(String category, {int page = 1});
  Future<List<Movie>> discoverMovies({
    int page = 1,
    String? releaseDateGte,
    String? releaseDateLte,
    String? withGenres,
  });
  Future<List<Movie>> getRecommendations(int movieId, {bool isTv = false});
  Future<List<Movie>> getDetails(int movieId, {bool isTv = false});
  Future<List<Movie>> searchMovies(
    String query, {
    String? withGenres,
    bool isTv = false,
    int page = 1,
  });
  Future<List<Cast>> getMovieCast(int movieId, {bool isTv = false});
  Future<String?> getMovieTrailer(int movieId, {bool isTv = false});
  Future<String?> getMovieCertification(int movieId, {bool isTv = false});
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final ApiClient apiClient;

  MovieRemoteDataSourceImpl(this.apiClient);

  void _verifyApiKey() {
    if (!apiClient.isApiKeyAvailable) {
      throw Exception('API Key is missing');
    }
  }

  @override
  Future<List<Movie>> getNowPlayingMovies() async {
    _verifyApiKey();
    final url = apiClient.buildTmdbUrl('/movie/now_playing');
    final data = await apiClient.getWithCache(url);
    if (data != null) {
      final List results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  @override
  Future<List<Movie>> getTvSeries({int page = 1, String? originCountry}) async {
    _verifyApiKey();
    final params = {
      'page': page.toString(),
      'sort_by': 'popularity.desc',
      if (originCountry != null && originCountry.isNotEmpty)
        'with_origin_country': originCountry,
    };
    final url = apiClient.buildTmdbUrl('/discover/tv', params: params);
    final data = await apiClient.getWithCache(url);
    if (data != null) {
      final List results = data['results'];
      return results.map((tv) => Movie.fromJson(tv, isTv: true)).toList();
    } else {
      throw Exception('Failed to load TV series');
    }
  }

  @override
  Future<List<Movie>> getMoviesByCategory(
    String category, {
    int page = 1,
  }) async {
    _verifyApiKey();
    final params = {'page': page.toString()};
    final url = apiClient.buildTmdbUrl('/movie/$category', params: params);
    final data = await apiClient.getWithCache(url);
    if (data != null) {
      final List results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load movies by category');
    }
  }

  @override
  Future<List<Movie>> discoverMovies({
    int page = 1,
    String? releaseDateGte,
    String? releaseDateLte,
    String? withGenres,
  }) async {
    _verifyApiKey();
    final params = {
      'page': page.toString(),
      'sort_by': 'popularity.desc',
      if (releaseDateGte != null) 'primary_release_date.gte': releaseDateGte,
      if (releaseDateLte != null) 'primary_release_date.lte': releaseDateLte,
      if (withGenres != null) 'with_genres': withGenres,
    };
    final url = apiClient.buildTmdbUrl('/discover/movie', params: params);
    final data = await apiClient.makeGetRequest(url);

    if (data != null) {
      final List results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to discover movies');
    }
  }

  @override
  Future<List<Movie>> getRecommendations(
    int movieId, {
    bool isTv = false,
  }) async {
    _verifyApiKey();
    final type = isTv ? 'tv' : 'movie';
    final url = apiClient.buildTmdbUrl('/$type/$movieId/recommendations');
    final data = await apiClient.getWithCache(url);
    if (data != null) {
      final List results = data['results'];
      return results.map((movie) => Movie.fromJson(movie, isTv: isTv)).toList();
    } else {
      return [];
    }
  }

  @override
  Future<List<Movie>> getDetails(int movieId, {bool isTv = false}) async {
    _verifyApiKey();
    final type = isTv ? 'tv' : 'movie';
    final url = apiClient.buildTmdbUrl('/$type/$movieId');
    final data = await apiClient.getWithCache(url);
    if (data != null) {
      return [Movie.fromJson(data, isTv: isTv)];
    } else {
      return [];
    }
  }

  @override
  Future<List<Movie>> searchMovies(
    String query, {
    String? withGenres,
    bool isTv = false,
    int page = 1,
  }) async {
    _verifyApiKey();
    final type = isTv ? 'tv' : 'movie';
    final params = {
      'query': query,
      'page': page.toString(),
      if (withGenres != null) 'with_genres': withGenres,
    };
    final url = apiClient.buildTmdbUrl('/search/$type', params: params);
    final data = await apiClient.makeGetRequest(url);

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

  @override
  Future<List<Cast>> getMovieCast(int movieId, {bool isTv = false}) async {
    _verifyApiKey();
    final type = isTv ? 'tv' : 'movie';
    final url = apiClient.buildTmdbUrl('/$type/$movieId/credits');
    final data = await apiClient.getWithCache(url);
    if (data != null) {
      final List castList = data['cast'];
      return castList.take(10).map((c) => Cast.fromJson(c)).toList();
    } else {
      return [];
    }
  }

  @override
  Future<String?> getMovieTrailer(int movieId, {bool isTv = false}) async {
    _verifyApiKey();
    final type = isTv ? 'tv' : 'movie';
    final url = apiClient.buildTmdbUrl('/$type/$movieId/videos');
    final data = await apiClient.getWithCache(url);
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

  @override
  Future<String?> getMovieCertification(
    int movieId, {
    bool isTv = false,
  }) async {
    if (isTv) return 'TV-PG';
    _verifyApiKey();
    final url = apiClient.buildTmdbUrl('/movie/$movieId/release_dates');
    final data = await apiClient.getWithCache(url);
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
}
