import 'dart:async';
import 'dart:developer';

import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

class MininetService {
  final String mininetUrl = "ws://localhost:8000/ws";
  WebSocketChannel? channel;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  Function(dynamic)? _responseCallback;
  MininetService() {
    _connect(); // Initialize connection
  }

  void _connect() {
    try {
      channel = WebSocketChannel.connect(Uri.parse(mininetUrl));
      _isConnected = true;

      // Listen for messages
      channel!.stream.listen(
        (message) {
          String msg = message.toString().toLowerCase();
          log("Message received: $msg");
          if (msg.contains('pingall')) {
            String result = msg.split(':')[1].trim();
            double? dropped = double.tryParse(result);
            if (dropped != 0 && dropped != null) {
              log("result: $dropped% packets dropped");
            }
          }
          if (_responseCallback != null) {
            _responseCallback!(message); // Forward message to callback
          }
        },
        onDone: () {
          log("WebSocket closed, attempting to reconnect...");
          _isConnected = false;
          _scheduleReconnect();
        },
        onError: (error) {
          log("WebSocket error: $error");
          _isConnected = false;
          _scheduleReconnect();
        },
      );
    } catch (e) {
      log("WebSocket connection error: $e");
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectTimer == null || !_reconnectTimer!.isActive) {
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        log("Attempting to reconnect...");
        _connect();
      });
    }
  }

  String startMininet(
      int hosts, int switches, String topology, String? topoType) {
    if (_isConnected) {
      try {
        channel?.sink.add("start:$hosts:$switches:$topology:$topoType");
        return 'success';
      } catch (e) {
        log('Error starting Mininet: $e');
        return 'error';
      }
    } else {
      log("WebSocket not connected, cannot send data.");
      return 'disconnected';
    }
  }

  void stopMininet() {
    channel?.sink.add("stop");
  }

  void executeCommand(String command) {
    channel?.sink.add("exec:$command");
  }

  void listenToResponses(Function(dynamic) callback) {
    _responseCallback = callback; // Store the callback function
  }

  void closeConnection() {
    channel?.sink.close(status.goingAway);
    _isConnected = false;
  }
}
