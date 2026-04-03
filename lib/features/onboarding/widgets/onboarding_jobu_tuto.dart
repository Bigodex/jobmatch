// =======================================================
// JOBU TUTORIAL (REFINADO FINAL)
// =======================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// =======================================================
// THEME
// =======================================================
import 'package:jobmatch/core/constants/app_theme.dart';

class JobuTuto extends StatefulWidget {
  final String text;

  const JobuTuto({
    super.key,
    required this.text,
  });

  @override
  State<JobuTuto> createState() => _JobuTutoState();
}

class _JobuTutoState extends State<JobuTuto> {
  String _displayedText = '';
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (_index < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_index];
          _index++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void didUpdateWidget(covariant JobuTuto oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text) {
      _displayedText = '';
      _index = 0;
      _startTyping();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Container(
      width: double.infinity,
      height: 140,
      color: appColors.header,
      child: Stack(
        children: [

          // ===================================================
          // SVG
          // ===================================================
          Align(
            alignment: Alignment.bottomLeft,
            child: SvgPicture.asset(
              'assets/images/jobu_tuto.svg',
              height: 110,
              fit: BoxFit.contain,
            ),
          ),

          // ===================================================
          // BALÃO
          // ===================================================
          Positioned(
            left: 160,
            bottom: 60,
            child: IntrinsicWidth(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(0),
                  ),
                  border: Border.all(color: Colors.white12),
                ),

                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                    children: _buildStyledText(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // TEXTO COM HIGHLIGHT (NOME + NASCEU)
  // =======================================================
  List<TextSpan> _buildStyledText() {
    final words = _displayedText.split(' ');

    return words.map((word) {
      final lower = word.toLowerCase();

      final isHighlight =
          lower.contains('nome') || lower.contains('nasceu') || lower.contains('especialidade') || lower.contains('idiomas');

      return TextSpan(
        text: '$word ',
        style: TextStyle(
          color: isHighlight ? const Color(0xFF68E3FF) : Colors.white,
          fontWeight: FontWeight.w700,
        ),
      );
    }).toList();
  }
}