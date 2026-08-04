import '../../../../models/movie.dart';

abstract class MovieRepository {
  // Remote API methods
  Future<List<Movie>> getTvSeries({String? originCountry, int page = 1});
  Future<List<Movie>> searchMovies(String query, {bool isTv = false, int page = 1, String? withGenres});
  Future<List<Movie>> getNowPlayingMovies();
  Future<List<Movie>> getMoviesByCategory(String category, {int page = 1});
  Future<List<Movie>> getRecommendations(int id, {required bool isTv});
  Future<List<Movie>> discoverMovies({required String withGenres, int page = 1});
  Future<List<Cast>> getMovieCast(int id, {required bool isTv});
  Future<String?> getMovieTrailer(int id, {required bool isTv});
  Future<String?> getMovieCertification(int id, {required bool isTv});
  Future<Cast?> getPersonDetails(int personId);
  Future<Map<String, List<Movie>>> getVerifiedFilmography(int personId);
  Future<List<Cast>> searchActors(String query);

  // Firestore methods
  Future<void> syncFavoriteToFirestore(String userId, Movie movie, bool isFavorite);
  Future<void> syncActorToFirestore(String userId, Cast actor, bool isFavorite);
  Future<List<Movie>> loadFavoritesFromFirestore(String userId);
  Future<List<Cast>> loadFavoriteActorsFromFirestore(String userId);

  // Local Storage (SharedPreferences) methods
  Future<void> saveFavorites(List<Movie> favorites, {required bool isTv});
  Future<List<Movie>> loadFavorites({required bool isTv});
  Future<void> saveFavoriteActors(List<Cast> actors);
  Future<List<Cast>> loadFavoriteActors();
}
