import 'dart:async';

/// Debounces rapid invocations of a callback.
class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 350)});

  final Duration delay;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => cancel();
}

/// Throttles calls to at most one per interval.
class Throttler {
  Throttler({this.interval = const Duration(seconds: 2)});

  final Duration interval;
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);

  bool tryRun() {
    final now = DateTime.now();
    if (now.difference(_last) >= interval) {
      _last = now;
      return true;
    }
    return false;
  }
}