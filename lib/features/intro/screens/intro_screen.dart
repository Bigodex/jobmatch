// =======================================================
// INTRO SCREEN COM VIDEO
// -------------------------------------------------------
// - Reproduz vídeo automaticamente
// - Navega ao finalizar
// =======================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    // ===================================================
    // INICIALIZA VIDEO
    // ===================================================
    _controller = VideoPlayerController.asset('assets/video/jobu_intro.mp4')
      ..initialize().then((_) {
        setState(() {});

        // ▶️ PLAY AUTOMÁTICO
        _controller.play();

        // ⚡ VELOCIDADE (1.0 = normal)
        _controller.setPlaybackSpeed(2.0);

        // 🔁 LISTENER
        _controller.addListener(_videoListener);
      });
  }

  // ===================================================
  // LISTENER PARA FINAL DO VIDEO
  // ===================================================
  void _videoListener() {
    if (_controller.value.position >= _controller.value.duration &&
        !_controller.value.isPlaying) {
      // 🔥 NAVEGA PARA WELCOME
      context.go('/welcome');
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller.value.isInitialized
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
