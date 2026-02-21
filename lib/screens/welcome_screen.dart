import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

/// Welcome Screen v1.0.1
/// Menampilkan animasi/video dari asset/welcome.mp4
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isReady = false;
  Timer? _autoNavigateTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('asset/welcome.mp4')
      ..initialize().then((_) {
        // Play muted and loop
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        _controller.play();
        if (mounted) setState(() => _isReady = true);
      });

    // Optional: auto-navigate after 4.5 seconds (short splash)
    _autoNavigateTimer = Timer(const Duration(milliseconds: 4500), () {
      if (mounted) {
        // Close welcome or navigate to home — here we just pop if possible
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _autoNavigateTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video background
            if (_isReady)
              FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.center,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              // Placeholder while initializing
              Container(color: Colors.black),

            // Overlay: center logo / title
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Small badge or logo
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Center(
                      child: Image.asset(
                        'asset/logo.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => Text(
                          'StockID',
                          style: GoogleFonts.outfit(
                              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Selamat Datang',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),

            // Top-left: skip
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black45,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // stop video and close welcome
                      _controller.pause();
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    child: Text('Skip', style: GoogleFonts.outfit()),
                  ),
                ),
              ),
            ),

            // Bottom-right: version tag
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      'V.1.0.1',
                      style: GoogleFonts.robotoMono(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
