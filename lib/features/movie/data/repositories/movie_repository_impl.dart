import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../models/movie.dart';
import '../../../../services/api_service.dart';
import '../../domain/repositories/movie_repository.dart';

class MovieRepositoryImpl implements MovieRepository {
  final ApiService _apiService;
  final FirebaseFirestore _firestore;

  MovieRepositoryImpl({
    required ApiService apiService,
    required FirebaseFirestore firestore,
  }) : _apiService = apiService,
       _firestore = firestore;

  @override
  Future<List<Movie>> getTvSeries({String? originCountry, int page = 1}) {
    return _apiService.getTvSeries(page: page, originCountry: originCountry);
  }

  @override
  Future<List<Movie>> searchMovies(String query, {bool isTv = false, int page = 1, String? withGenres}) {
    return _apiService.searchMovies(query, isTv: isTv, page: page, withGenres: withGenres);
  }

  @override
  Future<List<Movie>> getNowPlayingMovies() {
    return _apiService.getNowPlayingMovies();
  }

  @override
  Future<List<Movie>> getMoviesByCategory(String category, {int page = 1}) {
    return _apiService.getMoviesByCategory(category, page: page);
  }

  @override
  Future<List<Movie>> getRecommendations(int id, {required bool isTv}) {
    return _apiService.getRecommendations(id, isTv: isTv);
  }

  @override
  Future<List<Movie>> discoverMovies({required String withGenres, int page = 1}) {
    return _apiService.discoverMovies(withGenres: withGenres, page: page);
  }

  @override
  Future<List<Cast>> getMovieCast(int id, {required bool isTv}) {
    return _apiService.getMovieCast(id, isTv: isTv);
  }

  @override
  Future<String?> getMovieTrailer(int id, {required bool isTv}) {
    return _apiService.getMovieTrailer(id, isTv: isTv);
  }

  @override
  Future<String?> getMovieCertification(int id, {required bool isTv}) {
    return _apiService.getMovieCertification(id, isTv: isTv);
  }

  @override
  Future<Cast?> getPersonDetails(int personId) {
    return _apiService.getPersonDetails(personId);
  }

  @override
  Future<Map<String, List<Movie>>> getVerifiedFilmography(int personId) {
    return _apiService.getVerifiedFilmography(personId);
  }

  @override
  Future<List<Cast>> searchActors(String query) {
    return _apiService.searchActors(query);
  }

  @override
  Future<void> syncFavoriteToFirestore(String userId, Movie movie, bool isFavorite) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(movie.id.toString());
    if (isFavorite) {
      await docRef.set(movie.toJson());
    } else {
      await docRef.delete();
    }
  }

  @override
  Future<void> syncActorToFirestore(String userId, Cast actor, bool isFavorite) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorite_actors')
        .doc(actor.id.toString());
    if (isFavorite) {
      await docRef.set(actor.toJson());
    } else {
      await docRef.delete();
    }
  }

  @override
  Future<List<Movie>> loadFavoritesFromFirestore(String userId) async {
    final favSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();
    return favSnapshot.docs
        .map((doc) => Movie.fromJson(doc.data(), isTv: doc.data()['isTv'] ?? false))
        .toList();
  }

  @override
  Future<List<Cast>> loadFavoriteActorsFromFirestore(String userId) async {
    final actorSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorite_actors')
        .get();
    return actorSnapshot.docs
        .map((doc) => Cast.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> saveFavorites(List<Movie> favorites, {required bool isTv}) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = isTv ? 'favorites_tv' : 'favorites';
    final String encodedData = json.encode(favorites.map((m) => m.toJson()).toList());
    await prefs.setString(key, encodedData);
  }

  @override
  Future<List<Movie>> loadFavorites({required bool isTv}) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = isTv ? 'favorites_tv' : 'favorites';
    final String? encodedData = prefs.getString(key);
    if (encodedData != null) {
      final List decodedData = json.decode(encodedData);
      return decodedData.map((m) => Movie.fromJson(m, isTv: isTv)).toList();
    }
    return [];
  }

  @override
  Future<void> saveFavoriteActors(List<Cast> actors) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(actors.map((a) => a.toJson()).toList());
    await prefs.setString('favorite_actors', encodedData);
  }

  @override
  Future<List<Cast>> loadFavoriteActors() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('favorite_actors');
    if (encodedData != null) {
      final List decodedData = json.decode(encodedData);
      return decodedData.map((a) => Cast.fromJson(a)).toList();
    }
    return [];
  }
}
