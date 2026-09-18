import 'package:get/get.dart';
import 'package:tunehive/models/user_model.dart';
import 'package:tunehive/services/auth/auth_service.dart';

class AuthController extends GetxController {
  AuthController(this._authService);

  final AuthService _authService;

  final Rx<UserModel?> user = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  bool get isAuthenticated => user.value != null;

  // Mock notifications for the notification center
  final RxList<Map<String, String>> notifications = <Map<String, String>>[
    {'title': 'Welcome to TuneHive', 'body': 'Discover millions of songs across your connected providers.', 'time': '2 min ago'},
    {'title': 'New Release', 'body': 'Solstice just dropped "Golden Hour" - check it out!', 'time': '1 hour ago'},
    {'title': 'Weekly Mix Ready', 'body': 'Your personalized Daily Mix is ready to play.', 'time': '3 hours ago'},
    {'title': 'Artist Update', 'body': 'Nova Rae posted a new story. Listen to the latest.', 'time': '1 day ago'},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _tryRestoreSession();
  }

  Future<void> _tryRestoreSession() async {
    try {
      final restored = await _authService.restoreSession();
      user.value = restored;
    } catch (_) {
      // No saved session — user stays unauthenticated.
    }
  }

  Future<void> login({required String email, required String password}) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final u = await _authService.loginWithEmail(email: email, password: password);
      user.value = u;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({required String email, required String password, String? name}) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final u = await _authService.registerWithEmail(email: email, password: password, displayName: name);
      user.value = u;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final u = await _authService.loginWithGoogle();
      user.value = u;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithApple() async {
    isLoading.value = true;
    try {
      final u = await _authService.loginWithApple();
      user.value = u;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  final RxBool isLoggingOut = false.obs;

  Future<void> triggerLogoutTransition() async {
    isLoggingOut.value = true;
    // Wait for the animation to complete
    await Future.delayed(const Duration(milliseconds: 700));
    await logout();
    isLoggingOut.value = false;
  }

  Future<void> logout() async {
    await _authService.logout();
    user.value = null;
  }

  Future<void> updateProfile({String? name, String? avatar}) async {
    await _authService.updateProfile(displayName: name, avatarUrl: avatar);
    if (user.value != null) {
      user.value = user.value!.copyWith(displayName: name, avatarUrl: avatar);
    }
  }
}
