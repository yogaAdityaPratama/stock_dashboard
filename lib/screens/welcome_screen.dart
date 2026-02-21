import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

/// Welcome Screen v1.0.1
/// Menampilkan animasi/video dari asset/welcome.mp4
class WelcomeScreen extends StatefulWidget {
  final VoidCallback? onFinish;

  const WelcomeScreen({super.key, this.onFinish});

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
    _autoNavigateTimer = Timer(const Duration(milliseconds: 6500), () {
      if (mounted) {
        _controller.pause();
        widget.onFinish?.call();
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

            // Bottom-center: version tag only
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'V.1.0.1',
                      style: GoogleFonts.robotoMono(
                        color: Colors.white70,
                        fontSize: 13,
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
