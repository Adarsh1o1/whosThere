import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  late WebSocketChannel channel;
  bool isConnected = false;

  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal();

  Future<void> connect(String userId) async {
    if (!isConnected) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("token");
      channel = WebSocketChannel.connect(Uri.parse(
          'ws://loved-seemingly-cod.ngrok-free.app/ws/chat/$userId/?token=$token'));
      isConnected = true;
    }
  }

  void disconnect() {
    if (isConnected) {
      channel.sink.close(1000); // Normal closure
      isConnected = false;
    }
  }

  WebSocketChannel getChannel() {
    return channel;
  }
}
