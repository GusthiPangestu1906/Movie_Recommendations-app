import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../models/movie.dart';

abstract class PersonRemoteDataSource {
  Future<List<Cast>> searchActors(String query);
  Future<List<Cast>> searchWikidataActors(String query);
  Future<Map<String, String?>> getPersonExternalIds(int personId);
  Future<Cast?> getPersonDetails(int personId);
  Future<Map<String, List<Movie>>> getVerifiedFilmography(int personId);
}

class PersonRemoteDataSourceImpl implements PersonRemoteDataSource {
  final ApiClient apiClient;

  PersonRemoteDataSourceImpl(this.apiClient);

  void _verifyApiKey() {
    if (!apiClient.isApiKeyAvailable) {
      throw Exception('API Key is missing');
    }
  }

  @override
  Future<List<Cast>> searchActors(String query) async {
    _verifyApiKey();
    final params = {'query': query};
    final url = apiClient.buildTmdbUrl('/search/person', params: params);

    final data = await apiClient.makeGetRequest(url);

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

  @override
  Future<List<Cast>> searchWikidataActors(String query) async {
    final searchUri = Uri.https('www.wikidata.org', '/w/api.php', {
      'origin': '*',
      'action': 'wbsearchentities',
      'search': query,
      'language': 'id',
      'format': 'json',
    });

    try {
      final data = await apiClient.makeGetRequest(
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

          final detailData = await apiClient.makeGetRequest(
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

  @override
  Future<Map<String, String?>> getPersonExternalIds(int personId) async {
    _verifyApiKey();
    final url = apiClient.buildTmdbUrl('/person/$personId/external_ids');
    final data = await apiClient.makeGetRequest(url);
    if (data != null) {
      return {
        'instagram': data['instagram_id'],
        'twitter': data['twitter_id'],
        'facebook': data['facebook_id'],
      };
    }
    return {};
  }

  @override
  Future<Cast?> getPersonDetails(int personId) async {
    _verifyApiKey();
    final params = {'append_to_response': 'combined_credits'};
    final url = apiClient.buildTmdbUrl('/person/$personId', params: params);
    final data = await apiClient.makeGetRequest(url);

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

  @override
  Future<Map<String, List<Movie>>> getVerifiedFilmography(int personId) async {
    _verifyApiKey();
    final url = apiClient.buildTmdbUrl('/person/$personId/combined_credits');
    final data = await apiClient.makeGetRequest(url);

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
