/// An artist / creator.
class ArtistModel {
  const ArtistModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.genres = const [],
    this.followers,
    this.popularity,
    this.isFollowing = false,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final List<String> genres;
  final int? followers;
  final int? popularity;
  final bool isFollowing;

  String get followersText {
    final count = followers;
    if (count == null) return '';
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M followers';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K followers';
    }
    return '$count followers';
  }

  ArtistModel copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    List<String>? genres,
    int? followers,
    int? popularity,
    bool? isFollowing,
  }) {
    return ArtistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      genres: genres ?? this.genres,
      followers: followers ?? this.followers,
      popularity: popularity ?? this.popularity,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtistModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}