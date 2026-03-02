import 'dart:async';

class AppRefreshBus {
  static final _controller = StreamController<String>.broadcast();

  static Stream<String> get stream => _controller.stream;

  /// Notify specific part OR whole app
  static void notify(String key) {
    _controller.add(key);
  }

  /// Common keys (optional)
  static const user = "USER_UPDATED";
  static const profile = "PROFILE_UPDATED";
  static const settings = "SETTINGS_UPDATED";
  static const channel = "CHANNEL_UPDATED";

  static void dispose() {
    _controller.close();
  }
}