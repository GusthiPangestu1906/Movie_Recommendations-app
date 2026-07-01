class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;
  final bool isTv;
  final List<String> originCountry;
  List<Cast>? cast;
  String? trailerKey;
  String? certification;
  DateTime? watchDate;
  String? character;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    this.isTv = false,
    required this.originCountry,
    this.cast,
    this.trailerKey,
    this.certification,
    this.watchDate,
    this.character,
  });

  factory Movie.fromJson(Map<String, dynamic> json, {bool isTv = false}) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      isTv: isTv,
      character: json['character'],
      originCountry: List<String>.from(json['origin_country'] ?? []),
    );
  }

  String get fullPosterPath => posterPath.isNotEmpty 
      ? 'https://image.tmdb.org/t/p/w500$posterPath' 
      : 'https://via.placeholder.com/500x750?text=No+Image';
      
  String get fullBackdropPath => backdropPath.isNotEmpty 
      ? 'https://image.tmdb.org/t/p/w780$backdropPath' 
      : 'https://via.placeholder.com/780x440?text=No+Image';
}

class Cast {
  final int id;
  final String name;
  final String? profilePath;
  String? character;
  String? biography;
  String? birthday;
  String? placeOfBirth;
  String? instagramId;
  String? twitterId;
  String? facebookId;
  double? popularity;
  List<Movie>? filmography;
  List<Movie>? tvCredits;

  Cast({
    required this.id, 
    required this.name, 
    this.profilePath,
    this.character,
    this.biography,
    this.birthday,
    this.placeOfBirth,
    this.instagramId,
    this.twitterId,
    this.facebookId,
    this.popularity,
    this.filmography,
    this.tvCredits,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'],
      name: json['name'],
      profilePath: json['profile_path'],
      character: json['character'],
      biography: json['biography'],
      birthday: json['birthday'],
      placeOfBirth: json['place_of_birth'],
      popularity: (json['popularity'] as num?)?.toDouble(),
    );
  }

  String get fullProfilePath {
    if (profilePath == null) return 'https://via.placeholder.com/185x278?text=No+Image';
    if (profilePath!.startsWith('http')) return profilePath!;
    return 'https://image.tmdb.org/t/p/w185$profilePath';
  }

  String get fullProfilePathHD {
    if (profilePath == null) return 'https://via.placeholder.com/600x900?text=No+Image';
    if (profilePath!.startsWith('http')) return profilePath!;
    return 'https://image.tmdb.org/t/p/h632$profilePath';
  }
}
