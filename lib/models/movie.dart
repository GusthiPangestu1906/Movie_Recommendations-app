class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;
  List<Cast>? cast;
  String? trailerKey;
  String? certification;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    this.cast,
    this.trailerKey,
    this.certification,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] ?? '',
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

  Cast({required this.id, required this.name, this.profilePath});

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'],
      name: json['name'],
      profilePath: json['profile_path'],
    );
  }

  String get fullProfilePath => profilePath != null 
      ? 'https://image.tmdb.org/t/p/w185$profilePath' 
      : 'https://via.placeholder.com/185x278?text=No+Image';
}
