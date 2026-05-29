// lib/features/dashboard/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:soqia1/core/supabase_client.dart';
import 'package:soqia1/features/auth/services/auth_service.dart';
import 'package:soqia1/features/auth/screens/login_screen.dart';

// 💡 Fixed: Exact absolute imports using your project name
import 'package:soqia1/features/tank_management/services/tuya_service.dart';
import 'package:soqia1/features/tank_management/models/sensor_model.dart';
import 'package:soqia1/features/tank_management/screens/modification_screen.dart';
import 'dart:math' as math;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final TuyaService _tuyaService = TuyaService();

  late Future<SensorData?> _sensorDataFuture;

  @override
  void initState() {
    super.initState();
    _sensorDataFuture = _tuyaService.getDeviceData().then((data) {
      print('🚨 RAW TUYA RESPONSE: $data');
      if (data == null) return null;
      final Map<String, dynamic> payload = data['result'] ?? data;
      try {
        return SensorData.fromJson(payload);
      } catch (e) {
        print('🚨 ERROR PARSING SENSOR DATA: $e');
        return null;
      }
    });
  }

  void _refreshData() {
    setState(() {
      _sensorDataFuture = _tuyaService.getDeviceData().then((data) {
        if (data == null) return null;
        final Map<String, dynamic> payload = data['result'] ?? data;
        try {
          return SensorData.fromJson(payload);
        } catch (_) {
          return null;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      body: Container(
        // Consistent thematic background gradient
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F5FF),
              Color(0xFFF1F9FF),
              Color(0xFFE5F6FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: const Text(
                    'Soqia Monitor',
                    style: TextStyle(
                      color: Color(0xFF2B70D6),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  centerTitle: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF2B70D6)),
                      onPressed: _refreshData,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Color(0xFF2B70D6)),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ModificationPage()),
                        );
                        _refreshData();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Color(0xFF2B70D6)),
                      onPressed: () async {
                        await _authService.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ];
            },
            body: FutureBuilder<SensorData?>(
              future: _sensorDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF3883FF)));
                } else if (snapshot.hasError || snapshot.data == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Failed to load real-time tank metrics',
                            style: TextStyle(color: Color(0xFF718096), fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3883FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _refreshData,
                            child: const Text('Retry Connection'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final sensor = snapshot.data!;
                final double currentPercentage = sensor.ratio?.toDouble() ?? 0.0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Welcome Floating Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE3F5FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.account_circle_outlined, size: 28, color: Color(0xFF3883FF)),
                          ),
                          title: const Text('Welcome to Soqia!', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                          subtitle: Text('User: ${user?.email ?? "Unknown Status"}', style: const TextStyle(color: Color(0xFF718096))),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Show warning if no real-time data
                      if (sensor.ratio == null || sensor.depth == null) ...[
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9E6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFEAA7)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'Sensor Not Reporting Data',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFD63031)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text('The sensor is online but not sending water level readings.', style: TextStyle(color: Color(0xFF2D3748))),
                              const SizedBox(height: 8),
                              const Text('Available Data Points:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                              const SizedBox(height: 4),
                              Text(
                                sensor.getAvailableDPs(),
                                style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Color(0xFF718096)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 🌊 Animated Water Level Tank Widget Layout
                      Center(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Animated Container Custom Tank Graphic Instance
                              AnimatedTankVisual(percentage: currentPercentage, isDataAvailable: sensor.ratio != null),
                              const SizedBox(height: 24),
                              Text(
                                sensor.ratio != null ? 'Current Level: ${sensor.ratio}%' : 'Current Level: No Data',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: sensor.state.toLowerCase().contains('low') 
                                      ? const Color(0xFFFFF5F5) 
                                      : const Color(0xFFE6FFFA),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Tank Status: ${sensor.state}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: sensor.state.toLowerCase().contains('low') ? Colors.red.shade600 : Colors.green.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Technical Specification Information Layout Card
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: Text(
                                'Tank Technical Metrics',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                              ),
                            ),
                            const Divider(color: Color(0xFFEDF2F7), thickness: 1.5),
                            ListTile(
                              leading: const Icon(Icons.height, color: Color(0xFF3883FF)),
                              title: const Text('Installation Height', style: TextStyle(color: Color(0xFF4A5568))),
                              trailing: Text('${sensor.height} mm', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                            ),
                            ListTile(
                              leading: const Icon(Icons.devices, color: Color(0xFF3883FF)),
                              title: const Text('Device Name', style: TextStyle(color: Color(0xFF4A5568))),
                              trailing: Text(sensor.deviceName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                            ),
                            ListTile(
                              leading: Icon(
                                sensor.online ? Icons.cloud_done : Icons.cloud_off,
                                color: sensor.online ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
                              ),
                              title: const Text('Connection Status', style: TextStyle(color: Color(0xFF4A5568))),
                              trailing: Text(
                                sensor.online ? 'Online' : 'Offline',
                                style: TextStyle(fontWeight: FontWeight.bold, color: sensor.online ? const Color(0xFF38A169) : const Color(0xFFE53E3E)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// 🌊 A custom stateful layout component that models a real-time fluid liquid fill level.
class AnimatedTankVisual extends StatefulWidget {
  final double percentage;
  final bool isDataAvailable;

  const AnimatedTankVisual({
    super.key,
    required this.percentage,
    required this.isDataAvailable,
  });

  @override
  State<AnimatedTankVisual> createState() => _AnimatedTankVisualState();
}

class _AnimatedTankVisualState extends State<AnimatedTankVisual> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(140, 200),
          painter: TankFluidPainter(
            waveValue: _waveController.value,
            fillPercentage: widget.isDataAvailable ? widget.percentage : 0.0,
            hasData: widget.isDataAvailable,
          ),
        );
      },
    );
  }
}

/// Custom Canvas Painter rendering structural cylinder container wall properties alongside sine wave logic models.
class TankFluidPainter extends CustomPainter {
  final double waveValue;
  final double fillPercentage;
  final bool hasData;

  TankFluidPainter({
    required this.waveValue,
    required this.fillPercentage,
    required this.hasData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = 16.0;
    final Rect tankRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final RRect clipRRect = RRect.fromRectAndRadius(tankRect, Radius.circular(radius));

    // 1. Draw outer tank wall structure
    final Paint outlinePaint = Paint()
      ..color = const Color(0xFFCBD5E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawRRect(clipRRect, outlinePaint);

    // Save layer to avoid spilling fluid color maps outside boundaries
    canvas.save();
    canvas.clipRRect(clipRRect);

    if (hasData) {
      // Calculate depth fill baseline transformations
      final double normalizedFill = fillPercentage / 100.0;
      final double targetFluidHeight = size.height - (size.height * normalizedFill);

      final Path wavePath = Path();
      wavePath.moveTo(0, targetFluidHeight);

      // Model dynamic shifting wave frequencies using Sine maps across bounds
      for (double i = 0; i <= size.width; i++) {
        final double relativeWave = (i / size.width) * 2 * math.pi + (waveValue * 2 * math.pi);
        final double sineOffset = math.sin(relativeWave) * 6.0; // 6px amplitude wave size
        wavePath.lineTo(i, targetFluidHeight + sineOffset);
      }

      wavePath.lineTo(size.width, size.height);
      wavePath.lineTo(0, size.height);
      wavePath.close();

      // Fluid fill paint definition configurations
      final Paint fluidPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = const LinearGradient(
          colors: [Color(0xFF00B4DB), Color(0xFF3883FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(wavePath, fluidPaint);
    } else {
      // Render static missing metrics design representation when sensor fails
      final Paint offlineFill = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, size.height - 15, size.width, 15), offlineFill);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TankFluidPainter oldDelegate) {
    return oldDelegate.waveValue != waveValue || oldDelegate.fillPercentage != fillPercentage || oldDelegate.hasData != hasData;
  }
}