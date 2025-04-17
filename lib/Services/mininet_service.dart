import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:network_simulator/Constants/Templates.dart';
import 'package:network_simulator/Services/Provider/server_provider.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';

class MininetService {
  final BuildContext context;
  static MininetService? _instance;

  factory MininetService(BuildContext context) {
    return _instance ??= MininetService._internal(context);
  }
  MininetService._internal(this.context) {
    _connect();
  }

  final String mininetUrl = "ws://192.168.56.102:8000/ws";
  IOWebSocketChannel? channel;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  Function(dynamic)? _responseCallback;
  bool isScheduledConnectionRunning = false;

  void _connect() {
    try {
      _closeExistingConnection(); // Close old connection before making a new one
      channel = IOWebSocketChannel.connect(Uri.parse(mininetUrl));

      channel!.stream.listen(
        (message) {
          _isConnected = true;
          Provider.of<ServerProvider>(context, listen: false)
              .updateConnection(true);
          isScheduledConnectionRunning = false;
          if (_responseCallback != null) {
            _responseCallback!(message);
          }
        },
        onDone: _handleDisconnect,
        onError: (error) {
          log("WebSocket error: $error");
          if (!error.toString().contains(
              'The remote computer refused the network connection.')) {
            // Show error to user for non-connection errors
          }
          _handleDisconnect();
        },
      );
    } catch (e) {
      log("WebSocket connection error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    Provider.of<ServerProvider>(context, listen: false).updateConnection(false);
    _scheduleReconnect();
  }

  void _closeExistingConnection() {
    if (channel != null) {
      try {
        channel!.sink.close();
      } catch (e) {
        log("Error closing existing WebSocket connection: $e");
      }
      channel = null;
    }
  }

  void _scheduleReconnect() {
    if (_reconnectTimer == null || !_reconnectTimer!.isActive) {
      log("Scheduling reconnect in 5 seconds...");
      isScheduledConnectionRunning = true; // Set flag to prevent multiple runs
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        log("Attempting to reconnect...");
        isScheduledConnectionRunning = false;
        _connect();
      });
    }
  }

  String startMininet(int hosts, String topology, String? topoType) {
    if (_isConnected) {
      try {
        channel?.sink.add("start:$hosts:$topology:$topoType");
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
    if (channel != null) {
      try {
        channel!.sink.close(1000, 'Connection closed by client');
      } catch (e) {
        log("Error closing WebSocket connection: $e");
      }
      channel = null;
    }
  }
}
