import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  late WebSocketChannel channel;

  factory WebSocketManager() {
    return _instance;
  }

  WebSocketManager._internal();

  void initialize(String wsUrl) {
    channel = WebSocketChannel.connect(Uri.parse(wsUrl));
  }

  void sendMessage(message) {
    channel.sink.add(message);
  }

  void closeConnection() {
    channel.sink.close();
  }
}
