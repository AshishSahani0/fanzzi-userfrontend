import 'dart:async';

class ChannelInfoRefreshBus {
  static final _controller = StreamController<String>.broadcast();

  static Stream<String> get stream => _controller.stream;

  static void notify(String channelId) {
    _controller.add(channelId);
  }

  static void dispose() {
    _controller.close();
  }
}