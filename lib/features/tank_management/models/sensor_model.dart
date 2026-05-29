class SensorData {
  final bool online;
  final String deviceName;
  final int? ratio;
  final int? depth;
  final int height;
  final String state;
  
  // Store all raw DP codes for debugging
  final Map<String, dynamic> rawData;

  SensorData({
    required this.online,
    required this.deviceName,
    this.ratio,
    this.depth,
    required this.height,
    required this.state,
    required this.rawData,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    print("🔍 SensorData.fromJson received: $json");
    
    bool online = json['online'] ?? false;
    String deviceName = json['name'] ?? json['device_name'] ?? "Unknown";
    
    // EXACT DP codes from Tuya Device Debugging tab
    int? ratio = json['liquid_level_percent'];  // ✅ Correct field name
    int? depth = json['liquid_depth'];          // ✅ Correct field name
    int height = json['installation_height'] ?? 3000;
    String state = json['liquid_state']?.toString() ?? "normal";
    
    print("✅ Parsed: online=$online, name=$deviceName, ratio=$ratio%, depth=$depth, height=$height, state=$state");
    
    return SensorData(
      online: online,
      deviceName: deviceName,
      ratio: ratio,
      depth: depth,
      height: height,
      state: state,
      rawData: json,
    );
  }
  
  // Helper to display available DP codes
  String getAvailableDPs() {
    return rawData.entries
        .where((e) => e.key != 'online' && e.key != 'name')
        .map((e) => "${e.key}: ${e.value}")
        .join("\n");
  }
}