// =======================================================
// JOBU TUTORIAL (REFINADO FINAL)
// -------------------------------------------------------
// ✔ SVG mantido como está
// ✔ Balão acompanha o tamanho da frase
// ✔ Sem tamanho fixo
// ✔ Sem overflow nas bordas
// ✔ Suporte a palavras azuis em lower e CAPSLOCK
// =======================================================

import 'dart:async';
import 'dart:math' as math;
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
  Timer? _typingTimer;

  // =======================================================
  // PALAVRAS AZUIS EM LOWERCASE
  // =======================================================
  static const Set<String> _highlightLowerWords = {
    'nome',
    'nasceu',
    'especialidade',
    'idioma',
    'e-mail',
    'email',
    'senha',
    'perfil',
    'dados',
    'pessoais',
    'mora',
    'sobre',
    'habilidades',
    'comportamentais',
    'cidade',
    'resumo',
    'habilidade',
    'técnicas',
    'tecnicas',
    'data',
    'nascimento',
    'experiências',
    'experiencias',
    'formado',
    'orientar',
    'experiência',
    'experiencia',
    'formação',
    'formacao',
    'links',
    'link',
    'estado',
    'tag',
    'descrição',
    'empresa',
    'atuação',
  };

  // =======================================================
  // PALAVRAS AZUIS EM CAPSLOCK
  // =======================================================
  static const Set<String> _highlightCapsWords = {
    'CPF',
  };

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  void _startTyping() {
    _typingTimer?.cancel();

    _typingTimer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

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
      _typingTimer?.cancel();

      setState(() {
        _displayedText = '';
        _index = 0;
      });

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          // mantém o SVG como está
          // ajusta apenas o balão para caber melhor em telas menores
          final bubbleLeft = math.min(160.0, width * 0.46);
          final safeRight = width < 360 ? 8.0 : 12.0;

          // largura máxima disponível antes de bater na borda
          final maxBubbleWidth = math.max(
            120.0,
            width - bubbleLeft - safeRight,
          );

          return Stack(
            clipBehavior: Clip.hardEdge,
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
              // ---------------------------------------------------
              // acompanha o texto e só cresce até o limite da tela
              // ===================================================
              Positioned(
                left: bubbleLeft,
                bottom: 60,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxBubbleWidth,
                  ),
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
                        softWrap: true,
                        overflow: TextOverflow.visible,
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
              ),
            ],
          );
        },
      ),
    );
  }

  // =======================================================
  // TEXTO COM HIGHLIGHT
  // =======================================================
  List<TextSpan> _buildStyledText() {
    final tokens = RegExp(r'\S+|\s+')
        .allMatches(_displayedText)
        .map((match) => match.group(0)!)
        .toList();

    return tokens.map((token) {
      if (token.trim().isEmpty) {
        return TextSpan(text: token);
      }

      final cleaned = token.replaceAll(RegExp(r'[^\wÀ-ÿ\-@]'), '');
      final lower = cleaned.toLowerCase();
      final upper = cleaned.toUpperCase();

      final isLowerHighlight = _highlightLowerWords.any(
        (word) => lower.contains(word),
      );

      final isCapsHighlight = _highlightCapsWords.any(
        (word) => upper.contains(word),
      );

      final isHighlight = isLowerHighlight || isCapsHighlight;

      return TextSpan(
        text: token,
        style: TextStyle(
          color: isHighlight ? const Color(0xFF68E3FF) : Colors.white,
          fontWeight: FontWeight.w700,
        ),
      );
    }).toList();
  }
}