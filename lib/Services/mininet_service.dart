import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:network_simulator/Constants/Templates.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class MininetService {
  final BuildContext context;
  MininetService(this.context) {
    _connect();
  }

  final String mininetUrl = "ws://192.168.1.17:8000/ws";
  IOWebSocketChannel? channel;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  Function(dynamic)? _responseCallback;
  bool isScheduledConnectionRunning = false;

  void _connect() {
    try {
      channel = IOWebSocketChannel.connect(Uri.parse(mininetUrl));

      // Listen for messages
      channel!.stream.listen(
        (message) {
          _isConnected = true;
          isScheduledConnectionRunning = false;
          String msg = message.toString().toLowerCase();
          log("Message received: $msg");
          if (msg.split(' ')[0] == 'pingall') {
            log('Pingall result received...');
            String result = msg.split(':')[1].trim();
            double? dropped = double.tryParse(result);
            if (dropped != null) {
              log("Pingall Result: $dropped% packets dropped");
              if (dropped != 0.0) {
                Navigator.pop(context);
                MyDialogs.showErrorSnackbar(
                    context, '$dropped% packets dropped');
              } else {
                Navigator.pop(context);
                MyDialogs.showSuccessSnackbar(
                    context, 'Pingall success. No packets dropped.');
              }
            }
          }
          if (msg.split(' ')[0] == 'ping') {
            log('Pingall result received...');
            List data = msg.split(' ');
            String result = data[data.length - 1];
            String host1 = data[2];
            String host2 = data[4];

            log("Ping from $host1 to $host2 success");
            if (result == 'failure') {
              Navigator.pop(context);
              MyDialogs.showErrorSnackbar(
                  context, 'Ping from $host1 to $host2 failed');
            } else {
              Navigator.pop(context);
              MyDialogs.showSuccessSnackbar(
                  context, 'Ping from $host1 to $host2 success');
            }
          }
          if (_responseCallback != null) {
            _responseCallback!(message); // Forward message to callback
          }
        },
        onDone: () {
          log("WebSocket closed, attempting to reconnect...");
          _isConnected = false;
          if (!isScheduledConnectionRunning) {
            _scheduleReconnect();
            isScheduledConnectionRunning = true;
          }
        },
        onError: (error) {
          log("WebSocket error: $error");
          _isConnected = false;
          if (!isScheduledConnectionRunning) {
            _scheduleReconnect();
            isScheduledConnectionRunning = true;
          }
        },
      );
    } catch (e) {
      log("WebSocket connection error: $e");
      _isConnected = false;
      if (!isScheduledConnectionRunning) {
        _scheduleReconnect();
        isScheduledConnectionRunning = true;
      }
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
      return 'disconnected';
    }
  }

  void stopMininet() {
    if (_isConnected) channel?.sink.add("stop");
  }

  void executeCommand(String command) {
    if (_isConnected) {
      channel?.sink.add("exec:$command");
    } else {
      MyDialogs.showErrorSnackbar(context, 'Server disconnected...');
    }
  }

  void listenToResponses(Function(dynamic) callback) {
    _responseCallback = callback; // Store the callback function
  }

  void closeConnection() {
    channel?.sink.close(status.goingAway);
    _isConnected = false;
  }
}
