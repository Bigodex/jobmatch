// =======================================================
// SUCCESS SCREEN (VERSÃO PREMIUM)
// =======================================================

import 'dart:async';
import 'package:flutter/material.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {

  @override
  void initState() {
    super.initState();

    // 🔥 AUTO REDIRECT (REATIVADO)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: Center(
        child: SizedBox(
          height: 240,

          child: Center(
            child: PremiumAnimatedCheck(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// =======================================================
// PREMIUM ANIMATED CHECK
// =======================================================

class PremiumAnimatedCheck extends StatefulWidget {
  final Color color;

  const PremiumAnimatedCheck({
    super.key,
    required this.color,
  });

  @override
  State<PremiumAnimatedCheck> createState() => _PremiumAnimatedCheckState();
}

class _PremiumAnimatedCheckState extends State<PremiumAnimatedCheck>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate( // 🔥 corrigi aqui (era 2)
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _pulse = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: Stack(
              alignment: Alignment.center,
              children: [

                Transform.scale(
                  scale: _pulse.value,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.color.withOpacity(0.35),
                          widget.color.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.15),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    size: 70,
                    color: widget.color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}