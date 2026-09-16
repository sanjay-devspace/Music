import 'package:get/get.dart';

/// Manages the current bottom-navigation index for the shell layout.
///
/// Kept tiny on purpose — it only coordinates navigation state. The shell
/// widget reads [currentIndex] and [onIndexChanged] to render the correct
/// tab without pushing new routes.
class ShellController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void onIndexChanged(int index) {
    currentIndex.value = index;
  }
}