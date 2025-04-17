import 'dart:developer';

import 'package:flutter/material.dart';

class PingVisualization extends StatefulWidget {
  final Map<String, dynamic> pingData;
  final Function(String, String, List<dynamic>) onPacketPathUpdate;

  const PingVisualization({
    super.key,
    required this.pingData,
    required this.onPacketPathUpdate,
  });

  @override
  State<PingVisualization> createState() => _PingVisualizationState();
}

class _PingVisualizationState extends State<PingVisualization>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<Map<String, dynamic>> _pingHistory = [];
  bool _isAnimating = false;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    log('PingVisualization initState called');
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        log('PingVisualization post-frame callback, calling _updatePingData');
        _updatePingData();
      }
    });
  }

  @override
  void didUpdateWidget(PingVisualization oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('PingVisualization didUpdateWidget called');
    if (oldWidget.pingData != widget.pingData) {
      log('PingVisualization data changed, calling _updatePingData');
      _updatePingData();
    }
  }

  void _updatePingData() {
    if (!_mounted) {
      log('PingVisualization not mounted, skipping _updatePingData');
      return;
    }
    log('PingVisualization _updatePingData called with data: ${widget.pingData}');
    if (widget.pingData['type'] == 'path_data') {
      log('Processing path_data in PingVisualization');
      setState(() {
        _pingHistory.add({
          'src': widget.pingData['src'],
          'dst': widget.pingData['dst'],
          'time': widget.pingData['time'] ?? 0.0,
          'ttl': widget.pingData['ttl'] ?? 64,
        });
        log('Updated ping history: $_pingHistory');
        if (_pingHistory.length > 5) {
          _pingHistory.removeAt(0);
        }
        _isAnimating = true;
        log('Starting animation controller');
        _controller.reset();
        _controller.forward().then((_) {
          if (_mounted) {
            setState(() {
              _isAnimating = false;
              log('Animation completed, _isAnimating set to false');
            });
          } else {
            log('Widget not mounted during animation completion');
          }
        }).catchError((error) {
          log('Error during animation: $error');
        });
      });
      log('Calling onPacketPathUpdate with path: ${widget.pingData['path']}');
      try {
        widget.onPacketPathUpdate(
          widget.pingData['src'],
          widget.pingData['dst'],
          widget.pingData['path'],
        );
        log('onPacketPathUpdate called successfully');
      } catch (e) {
        log('Error in onPacketPathUpdate: $e');
      }
    } else {
      log('Received non-path_data type: ${widget.pingData['type']}');
    }
  }

  @override
  void dispose() {
    log('PingVisualization dispose called');
    _mounted = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('PingVisualization build called, _pingHistory length: ${_pingHistory.length}');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ping Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 16),
          _buildPingHistory(),
          const SizedBox(height: 16),
          _buildStatistics(),
        ],
      ),
    );
  }

  Widget _buildPingHistory() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _pingHistory.length,
        itemBuilder: (context, index) {
          final ping = _pingHistory[_pingHistory.length - 1 - index];
          final isLatest = index == 0;
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isLatest ? Colors.blue[50] : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isLatest ? Colors.blue : Colors.grey,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${ping['src']} → ${ping['dst']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isLatest ? Colors.blue[700] : Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${ping['time']}ms',
                  style: TextStyle(
                    color: isLatest ? Colors.blue[700] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatistics() {
    if (_pingHistory.isEmpty) return const SizedBox.shrink();

    final latestPing = _pingHistory.last;
    final avgTime =
        _pingHistory.map((p) => p['time'] as double).reduce((a, b) => a + b) /
            _pingHistory.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latest Ping',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatItem('Time', '${latestPing['time']}ms'),
            _buildStatItem('TTL', '${latestPing['ttl']}'),
            _buildStatItem('Avg Time', '${avgTime.toStringAsFixed(1)}ms'),
          ],
        ),
        if (_isAnimating) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _animation.value,
            backgroundColor: Colors.blue[100],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }
}
