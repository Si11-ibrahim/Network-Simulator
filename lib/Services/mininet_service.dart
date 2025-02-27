import 'package:web_socket_channel/web_socket_channel.dart';

class MininetService {
  String mininetUrl = "ws://localhost:8000/ws";

  final WebSocketChannel channel =
      WebSocketChannel.connect(Uri.parse("ws://localhost:8000/ws"));

  void startMininet(int hosts, int switches, String topology) {
    channel.sink.add("start:$hosts:$switches:$topology");
  }

  void stopMininet() {
    channel.sink.add("stop");
  }

  void executeCommand(String command) {
    channel.sink.add("exec:$command");
  }

  void listenToResponses(Function(dynamic) callback) {
    channel.stream.listen((message) {
      callback(message); // Update UI with response
    });
  }

  void closeConnection() {
    channel.sink.close();
  }
}
