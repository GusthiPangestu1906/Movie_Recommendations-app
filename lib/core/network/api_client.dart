import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _proxyUrl =
      'https://delicate-dew-e24d.gusthipangestu1906.workers.dev';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  static String get _appProxySecret {
    return const String.fromEnvironment('APP_PROXY_SECRET');
  }

  static String get _apiKey {
    const keyFromEnv = String.fromEnvironment('TMDB_API_KEY');
    if (keyFromEnv.isNotEmpty) return keyFromEnv;
    return dotenv.env['TMDB_API_KEY'] ?? '';
  }

  static bool get _useProxy {
    if (kDebugMode) return false;
    return _proxyUrl.contains('workers.dev');
  }

  bool get isApiKeyAvailable => _useProxy || _apiKey.isNotEmpty;

  final Map<String, dynamic> _cache = {};

  String buildTmdbUrl(String endpoint, {Map<String, String>? params}) {
    if (_useProxy) {
      final uri = Uri.parse(_proxyUrl + endpoint);
      return uri.replace(queryParameters: params).toString();
    }

    final queryParams = {...?params, 'api_key': _apiKey};
    final uri = Uri.parse(_baseUrl + endpoint);
    return uri.replace(queryParameters: queryParams).toString();
  }

  Future<dynamic> makeGetRequest(
    String url, {
    bool isWikidata = false,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final uri = Uri.parse(url);

      Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (_useProxy && !uri.host.contains('wikidata.org') && !isWikidata) {
        headers['X-App-Proxy-Secret'] = _appProxySecret;
      }

      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('API Request Error: $e');
      return null;
    }
  }

  Future<dynamic> getWithCache(String url) async {
    if (_cache.containsKey(url)) {
      return _cache[url];
    }
    final data = await makeGetRequest(url);
    if (data != null) {
      _cache[url] = data;
    }
    return data;
  }
}
