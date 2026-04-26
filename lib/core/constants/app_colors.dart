// =======================================================
// APP COLORS
// -------------------------------------------------------
// Centraliza os principais tokens de cor do JobMatch.
//
// Objetivo:
// - evitar cores hardcoded espalhadas pelo app
// - padronizar estados visuais como erro, sucesso e aviso
// - facilitar manutenção futura do tema
// - preparar o app para componentes visuais consistentes
// =======================================================

import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // ===================================================
  // BASE COLORS
  // ---------------------------------------------------
  // Cores principais da identidade visual do app.
  // ===================================================
  static const Color primary = Color(0xFF68E3FF);
  static const Color secondary = Color(0xFF7C5CFF);

  // ===================================================
  // BACKGROUND COLORS
  // ---------------------------------------------------
  // Cores usadas em fundos principais, headers e cards.
  // ===================================================
  static const Color background = Color(0xFF17181C);
  static const Color header = Color(0xFF1D1F27);
  static const Color card = Color(0xFF2D2B34);
  static const Color cardSecondary = Color(0xFF242631);
  static const Color cardTertiary = Color(0xFF20222B);

  // ===================================================
  // TEXT COLORS
  // ---------------------------------------------------
  // Cores usadas para hierarquia textual.
  // ===================================================
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8BAC7);
  static const Color textMuted = Color(0xFF8A8D99);
  static const Color textDisabled = Color(0xFF5F6270);

  // ===================================================
  // STATE COLORS
  // ---------------------------------------------------
  // Cores para estados de interface.
  //
  // success usa a primary porque o app já trabalha com o
  // check azul como estado positivo/validado.
  // ===================================================
  static const Color success = primary;
  static const Color warning = Color(0xFFFFC857);
  static const Color error = Color(0xFFFF5C7A);
  static const Color info = primary;

  // ===================================================
  // BORDER COLORS
  // ---------------------------------------------------
  // Cores usadas em bordas, divisores e contornos.
  // ===================================================
  static const Color border = Color(0xFF3A3D46);
  static const Color borderSoft = Color(0xFF30323C);
  static const Color divider = Color(0xFF343642);

  // ===================================================
  // NEUTRAL COLORS
  // ---------------------------------------------------
  // Cores neutras utilizadas em ícones, overlays e bases.
  // ===================================================
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // ===================================================
  // OVERLAY HELPERS
  // ---------------------------------------------------
  // Helpers para gerar cores com transparência usando a
  // API nova do Flutter, evitando withOpacity deprecated.
  // ===================================================
  static Color overlay(Color color, double alpha) {
    return color.withValues(alpha: alpha);
  }

  static Color primaryOverlay(double alpha) {
    return primary.withValues(alpha: alpha);
  }

  static Color errorOverlay(double alpha) {
    return error.withValues(alpha: alpha);
  }

  static Color warningOverlay(double alpha) {
    return warning.withValues(alpha: alpha);
  }

  static Color whiteOverlay(double alpha) {
    return white.withValues(alpha: alpha);
  }

  static Color blackOverlay(double alpha) {
    return black.withValues(alpha: alpha);
  }
}
