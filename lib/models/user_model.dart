/// The authenticated user's profile.
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.createdAt,
    this.favoriteGenres = const [],
    this.connectedProviders = const [],
    this.subscription,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? createdAt;
  final List<String> favoriteGenres;
  final List<String> connectedProviders;
  final SubscriptionTier? subscription;

  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      return parts.length >= 2
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : displayName!.substring(0, 1).toUpperCase();
    }
    return email.substring(0, 1).toUpperCase();
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    DateTime? createdAt,
    List<String>? favoriteGenres,
    List<String>? connectedProviders,
    SubscriptionTier? subscription,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      connectedProviders: connectedProviders ?? this.connectedProviders,
      subscription: subscription ?? this.subscription,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum SubscriptionTier { free, premium, family, student }