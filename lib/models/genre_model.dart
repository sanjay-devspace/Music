/// A musical genre / moods / category.
class GenreModel {
  const GenreModel({
    required this.id,
    required this.name,
    this.icon,
    this.imageUrls = const [],
    this.songCount = 0,
  });

  final String id;
  final String name;
  final String? icon;
  final List<String> imageUrls;
  final int songCount;

  GenreModel copyWith({
    String? id,
    String? name,
    String? icon,
    List<String>? imageUrls,
    int? songCount,
  }) {
    return GenreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      imageUrls: imageUrls ?? this.imageUrls,
      songCount: songCount ?? this.songCount,
    );
  }
}