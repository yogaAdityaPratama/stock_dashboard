import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/trading_view_chart.dart';

class FullscreenChartScreen extends StatefulWidget {
  final String stockCode;

  const FullscreenChartScreen({super.key, required this.stockCode});

  @override
  State<FullscreenChartScreen> createState() => _FullscreenChartScreenState();
}

class _FullscreenChartScreenState extends State<FullscreenChartScreen> {
  @override
  void initState() {
    super.initState();
    // Force landscape mode for better technical analysis view
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Hide status bar and bottom navigation for "true" fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Reset to portrait mode when leaving
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A2E),
      body: Stack(
        children: [
          // Fullscreen Chart
          SizedBox.expand(
            child: TradingViewChart(
              symbol: widget.stockCode,
              height: double.infinity,
              interval: 'D',
            ),
          ),

          // Return Button (Back to Analysis)
          Positioned(
            top: 20,
            left: 20,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          // Floating Badge for Context
          Positioned(
            top: 20,
            right: 20,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.cyanAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${widget.stockCode} FULL HUD',
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
