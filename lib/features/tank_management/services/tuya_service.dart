import '../models/sensor_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class TuyaService {
  // ── CONFIGURATION ──
  //actual credentials Tuya IoT Platform
  static const String clientId = "994tkfy83w3xsqvesrsg";
  static const String clientSecret = "6f8097cd2a7d4f28a32b02f4e6dd699d";
  static const String deviceId = "bf988873171b24f1bc7jrg";
  // Modify this line in tuya_service.dart for quick web prototyping
//static const String baseUrl = "https://cors-anywhere.herokuapp.com/https://openapi.tuyaeu.com";
 
  static const String baseUrl = "https://openapi.tuyaeu.com";

  String? _accessToken;

  // ── HELPER METHODS ──

  String _sha256Hex(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }

  /// Generates the complex Tuya HMAC-SHA256 signature
  String _generateSign(String method, String path, String t, {String body = "", String token = ""}) {
    String contentHash = _sha256Hex(body);
    // Format: HTTPMethod + "\n" + Content-SHA256 + "\n" + Headers + "\n" + URL
    String stringToSign = "$method\n$contentHash\n\n$path";
    String message = clientId + token + t + stringToSign;
    
    var key = utf8.encode(clientSecret);
    var bytes = utf8.encode(message);
    var hmacSha256 = Hmac(sha256, key);
    return hmacSha256.convert(bytes).toString().toUpperCase();
  }

  // ── CORE API CALLS ──

  /// Fetches a fresh access token from Tuya
  Future<String?> getAccessToken() async {
    String t = DateTime.now().millisecondsSinceEpoch.toString();
    String path = "/v1.0/token?grant_type=1";
    String sign = _generateSign("GET", path, t);

    try {
      final response = await http.get(
        Uri.parse(baseUrl + path),
        headers: {
          "client_id": clientId,
          "sign": sign,
          "t": t,
          "sign_method": "HMAC-SHA256",
        },
      );

      var data = jsonDecode(response.body);
      if (data['success'] == true) {
        _accessToken = data['result']['access_token'];
        return _accessToken;
      }
    } catch (e) {
      debugPrint("Token Error: $e");
    }
    return null;
  }

  /// Retrieves device status and general info
  Future<Map<String, dynamic>?> getDeviceData() async {
    String? token = await getAccessToken();
    if (token == null) {
      debugPrint("❌ Failed to get access token");
      return null;
    }

    // First, get device info (name, online status)
    String t1 = DateTime.now().millisecondsSinceEpoch.toString();
    String infoPath = "/v1.0/devices/$deviceId";
    String infoSign = _generateSign("GET", infoPath, t1, token: token);

    Map<String, dynamic>? deviceInfo;
    
    try {
      final infoResponse = await http.get(
        Uri.parse(baseUrl + infoPath),
        headers: {
          "client_id": clientId,
          "access_token": token,
          "sign": infoSign,
          "t": t1,
          "sign_method": "HMAC-SHA256",
        },
      );
      
      debugPrint("📡 Device Info Response Status: ${infoResponse.statusCode}");
      debugPrint("📡 Device Info Response Body: ${infoResponse.body}");
      
      deviceInfo = jsonDecode(infoResponse.body);
      
      if (deviceInfo?['success'] != true) {
        debugPrint("❌ Device Info API returned success=false: ${deviceInfo?['msg']}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Device Info Error: $e");
      return null;
    }

    // Second, get device status (DP values)
    String t2 = DateTime.now().millisecondsSinceEpoch.toString();
    String statusPath = "/v1.0/devices/$deviceId/status";
    String statusSign = _generateSign("GET", statusPath, t2, token: token);

    try {
      final statusResponse = await http.get(
        Uri.parse(baseUrl + statusPath),
        headers: {
          "client_id": clientId,
          "access_token": token,
          "sign": statusSign,
          "t": t2,
          "sign_method": "HMAC-SHA256",
        },
      );
      
      debugPrint("📡 Device Status Response Status: ${statusResponse.statusCode}");
      debugPrint("📡 Device Status Response Body: ${statusResponse.body}");
      
      var statusData = jsonDecode(statusResponse.body);
      
      if (statusData['success'] != true) {
        debugPrint("❌ Status API returned success=false: ${statusData['msg']}");
        return null;
      }

      // Merge device info and status
      final result = deviceInfo?['result'] ?? {};
      final statusList = statusData['result'] as List<dynamic>? ?? [];
      
      // Convert status array to map for easier access
      Map<String, dynamic> statusMap = {};
      for (var item in statusList) {
        if (item is Map<String, dynamic>) {
          statusMap[item['code']] = item['value'];
        }
      }
      
      debugPrint("📊 Parsed Status Map: $statusMap");
      
      // Build combined result
      return {
        'result': {
          'online': result['online'] ?? false,
          'name': result['name'] ?? 'Unknown Device',
          ...statusMap, // Merge all DP values
        }
      };
      
    } catch (e) {
      debugPrint("❌ Device Status Error: $e");
      return null;
    }
  }

  /// Sends a command to change device properties (e.g., installation_height)
  Future<bool> sendDeviceCommand(String code, dynamic value) async {
    String? token = await getAccessToken();
    if (token == null) return false;

    String t = DateTime.now().millisecondsSinceEpoch.toString();
    String path = "/v1.0/devices/$deviceId/commands";
    
    // Command payload format
    String body = jsonEncode({
      "commands": [
        {"code": code, "value": value}
      ]
    });

    String sign = _generateSign("POST", path, t, body: body, token: token);

    try {
      final response = await http.post(
        Uri.parse(baseUrl + path),
        headers: {
          "client_id": clientId,
          "access_token": token,
          "sign": sign,
          "t": t,
          "sign_method": "HMAC-SHA256",
          "Content-Type": "application/json",
        },
        body: body,
      );

      var data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      debugPrint("Command Error: $e");
      return false;
    }
  }

  /// Renames the device in the Tuya Cloud
  Future<bool> renameDevice(String newName) async {
    String? token = await getAccessToken();
    if (token == null) return false;

    String t = DateTime.now().millisecondsSinceEpoch.toString();
    String path = "/v1.0/devices/$deviceId";
    String body = jsonEncode({"name": newName});
    
    String sign = _generateSign("PUT", path, t, body: body, token: token);

    try {
      final response = await http.put(
        Uri.parse(baseUrl + path),
        headers: {
          "client_id": clientId,
          "access_token": token,
          "sign": sign,
          "t": t,
          "sign_method": "HMAC-SHA256",
          "Content-Type": "application/json",
        },
        body: body,
      );

      var data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      debugPrint("Rename Error: $e");
      return false;
    }
  }
}