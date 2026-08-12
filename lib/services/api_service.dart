import '../core/network/api_client.dart';
import '../features/movie/data/datasources/movie_remote_data_source.dart';
import '../features/movie/data/datasources/person_remote_data_source.dart';
import '../models/movie.dart';

/// Facade Service providing access to TMDB & Wikidata API endpoints.
/// Maintains 100% backward compatibility while delegating data operations
/// to specialized [MovieRemoteDataSource] and [PersonRemoteDataSource] implementations.
class ApiService {
  final MovieRemoteDataSource _movieRemoteDataSource;
  final PersonRemoteDataSource _personRemoteDataSource;

  ApiService({
    ApiClient? apiClient,
    MovieRemoteDataSource? movieRemoteDataSource,
    PersonRemoteDataSource? personRemoteDataSource,
  }) : _movieRemoteDataSource =
           movieRemoteDataSource ??
           MovieRemoteDataSourceImpl(apiClient ?? ApiClient()),
       _personRemoteDataSource =
           personRemoteDataSource ??
           PersonRemoteDataSourceImpl(apiClient ?? ApiClient());

  Future<List<Movie>> getNowPlayingMovies() =>
      _movieRemoteDataSource.getNowPlayingMovies();

  Future<List<Movie>> getTvSeries({int page = 1, String? originCountry}) =>
      _movieRemoteDataSource.getTvSeries(
        page: page,
        originCountry: originCountry,
      );

  Future<List<Movie>> getMoviesByCategory(String category, {int page = 1}) =>
      _movieRemoteDataSource.getMoviesByCategory(category, page: page);

  Future<List<Movie>> discoverMovies({
    int page = 1,
    String? releaseDateGte,
    String? releaseDateLte,
    String? withGenres,
  }) => _movieRemoteDataSource.discoverMovies(
    page: page,
    releaseDateGte: releaseDateGte,
    releaseDateLte: releaseDateLte,
    withGenres: withGenres,
  );

  Future<List<Movie>> getRecommendations(int movieId, {bool isTv = false}) =>
      _movieRemoteDataSource.getRecommendations(movieId, isTv: isTv);

  Future<List<Movie>> getDetails(int movieId, {bool isTv = false}) =>
      _movieRemoteDataSource.getDetails(movieId, isTv: isTv);

  Future<List<Movie>> searchMovies(
    String query, {
    String? withGenres,
    bool isTv = false,
    int page = 1,
  }) => _movieRemoteDataSource.searchMovies(
    query,
    withGenres: withGenres,
    isTv: isTv,
    page: page,
  );

  Future<List<Cast>> getMovieCast(int movieId, {bool isTv = false}) =>
      _movieRemoteDataSource.getMovieCast(movieId, isTv: isTv);

  Future<String?> getMovieTrailer(int movieId, {bool isTv = false}) =>
      _movieRemoteDataSource.getMovieTrailer(movieId, isTv: isTv);

  Future<String?> getMovieCertification(int movieId, {bool isTv = false}) =>
      _movieRemoteDataSource.getMovieCertification(movieId, isTv: isTv);

  Future<List<Cast>> searchActors(String query) =>
      _personRemoteDataSource.searchActors(query);

  Future<List<Cast>> searchWikidataActors(String query) =>
      _personRemoteDataSource.searchWikidataActors(query);

  Future<Map<String, String?>> getPersonExternalIds(int personId) =>
      _personRemoteDataSource.getPersonExternalIds(personId);

  Future<Cast?> getPersonDetails(int personId) =>
      _personRemoteDataSource.getPersonDetails(personId);

  Future<Map<String, List<Movie>>> getVerifiedFilmography(int personId) =>
      _personRemoteDataSource.getVerifiedFilmography(personId);
}
