import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TopoUtils {
  static const Map<String, Map<String, int>> topologyLimits = {
    "star": {"maxSwitches": 1, "maxHosts": 100},
    "ring": {"maxSwitches": 50, "maxHosts": 20},
    "mesh": {"maxSwitches": 6, "maxHosts": 50},
    "tree": {"maxSwitches": 9, "maxHosts": 48},
    "bus": {"maxSwitches": 1, "maxHosts": 20},
    "custom": {"maxSwitches": 20, "maxHosts": 100},
    "fattree": {"maxSwitches": 24, "maxHosts": 48},
  };

  static Future<int> sendDeviceCounts(BuildContext context, int switches,
      int routers, int hosts, String topo) async {
    final url = Uri.parse("http://127.0.0.1:5000/get_device_counts");
    int statusCode = 0;
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "switches": switches,
          "routers": routers,
          "hosts": hosts,
          "topology": topo,
        }),
      );
      statusCode = response.statusCode;
      if (response.statusCode == 200) {
        log("Device counts sent successfully!");
      } else {
        log("Failed to send device counts: ${response.body}");
      }
      log(response.body);
      return response.statusCode;
    } catch (e) {
      log(e.toString());
    }
    return statusCode;
  }
}
