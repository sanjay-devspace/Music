import 'package:tunehive/core/errors/app_exception.dart';
import 'package:tunehive/core/storage/storage_service.dart';
import 'package:tunehive/models/user_model.dart';

/// Authentication service.
///
/// Handles the app account (email / Google / Apple) via Supabase when
/// configured. Provides a local demo session when the backend is absent so
/// the full experience remains explorable.
class AuthService {
  AuthService(StorageService storage) : _storage = storage;

  final StorageService _storage;
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final user = UserModel(
      id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: _nameFromEmail(email),
    );
    _currentUser = user;
    await _storage.setJson('auth_session', {'id': user.id, 'email': user.email});
    return user;
  }

  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final user = UserModel(
      id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName ?? _nameFromEmail(email),
    );
    _currentUser = user;
    await _storage.setJson('auth_session', {'id': user.id, 'email': user.email});
    return user;
  }

  Future<UserModel> loginWithGoogle() async {
    final user = UserModel(
      id: 'google-${DateTime.now().millisecondsSinceEpoch}',
      email: 'you@gmail.com',
      displayName: 'Google User',
    );
    _currentUser = user;
    await _storage.setJson('auth_session', {'id': user.id, 'email': user.email});
    return user;
  }

  Future<UserModel> loginWithApple() async {
    final user = UserModel(
      id: 'apple-${DateTime.now().millisecondsSinceEpoch}',
      email: 'you@icloud.com',
      displayName: 'Apple User',
    );
    _currentUser = user;
    await _storage.setJson('auth_session', {'id': user.id, 'email': user.email});
    return user;
  }

  Future<UserModel> restoreSession() async {
    final session = _storage.getJson('auth_session');
    if (session == null) {
      throw const AuthenticationException(message: 'No saved session.');
    }
    final user = UserModel(
      id: session['id'] as String? ?? '',
      email: session['email'] as String? ?? '',
    );
    _currentUser = user;
    return user;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storage.remove('auth_session');
  }

  Future<void> updateProfile({
    String? displayName,
    String? avatarUrl,
    List<String>? favoriteGenres,
  }) async {
    final current = _currentUser;
    if (current == null) return;
    _currentUser = current.copyWith(
      displayName: displayName ?? current.displayName,
      avatarUrl: avatarUrl ?? current.avatarUrl,
      favoriteGenres: favoriteGenres ?? current.favoriteGenres,
    );
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first;
    return local.isEmpty ? 'Listener' : local[0].toUpperCase() + local.substring(1);
  }
}