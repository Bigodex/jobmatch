// =======================================================
// APP VALIDATED INPUT FIELD
// -------------------------------------------------------
// Campo reutilizável com estados:
// - normal
// - erro   -> borda vermelha + exclamação
// - válido -> borda primary + check
//
// Suporta:
// - trailing customizado, como botão de olho da senha
// - focusNode
// - onEditingComplete
// - onTapOutside
// - textarea com validação no topo superior direito
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';

class AppValidatedInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final bool hasError;
  final bool isValid;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final Widget? trailing;
  final Iterable<String>? autofillHints;
  final TextAlign textAlign;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final void Function(PointerDownEvent)? onTapOutside;

  const AppValidatedInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.hasError,
    required this.isValid,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.inputFormatters,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.trailing,
    this.autofillHints,
    this.textAlign = TextAlign.start,
    this.focusNode,
    this.onEditingComplete,
    this.onTapOutside,
  });

  // ===================================================
  // BUILD
  // ---------------------------------------------------
  // Monta o TextField com borda dinâmica, ícone de
  // validação e suporte a trailing customizado.
  // ===================================================
  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primary;
    final errorColor = AppColors.error;

    final isMultilineField =
        !obscureText && ((maxLines ?? 1) > 1 || (minLines ?? 1) > 1);

    final validationIcon = _buildValidationIcon(
      primaryColor: primaryColor,
      errorColor: errorColor,
    );

    final suffixIcon = _buildSuffixIcon(
      isMultilineField: isMultilineField,
      validationIcon: validationIcon,
    );

    final enabledBorder = _buildEnabledBorder(
      primaryColor: primaryColor,
      errorColor: errorColor,
    );

    final focusedBorder = _buildFocusedBorder(
      primaryColor: primaryColor,
      errorColor: errorColor,
    );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLength: maxLength,
      minLines: obscureText ? 1 : minLines,
      maxLines: obscureText ? 1 : maxLines,
      enabled: enabled,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textAlign: textAlign,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
      ),
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onTapOutside: onTapOutside,
      decoration: InputDecoration(
        hintText: hint,
        counterText: maxLength != null ? '' : null,
        filled: true,
        fillColor: AppColors.whiteOverlay(0.04),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        suffixIcon: suffixIcon,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        disabledBorder: enabledBorder,
      ),
    );
  }

  // ===================================================
  // BUILD VALIDATION ICON
  // ---------------------------------------------------
  // Retorna o ícone de erro ou sucesso conforme o estado
  // do campo. Caso o campo esteja neutro, retorna null.
  // ===================================================
  Widget? _buildValidationIcon({
    required Color primaryColor,
    required Color errorColor,
  }) {
    if (hasError) {
      return Icon(
        Icons.error_outline_rounded,
        color: errorColor,
        size: 20,
      );
    }

    if (isValid) {
      return Icon(
        Icons.check_circle_rounded,
        color: primaryColor,
        size: 20,
      );
    }

    return null;
  }

  // ===================================================
  // BUILD SUFFIX ICON
  // ---------------------------------------------------
  // Monta o espaço final do campo:
  // - textarea: ícone no topo superior direito
  // - campo comum: trailing + ícone de validação lado a lado
  // ===================================================
  Widget? _buildSuffixIcon({
    required bool isMultilineField,
    required Widget? validationIcon,
  }) {
    if (isMultilineField) {
      if (validationIcon == null) {
        return null;
      }

      return Padding(
        padding: const EdgeInsets.only(top: 10, right: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            validationIcon,
          ],
        ),
      );
    }

    if (validationIcon == null && trailing == null) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?trailing,
          if (trailing != null && validationIcon != null)
            const SizedBox(width: 6),
          ?validationIcon,
        ],
      ),
    );
  }

  // ===================================================
  // BUILD ENABLED BORDER
  // ---------------------------------------------------
  // Define a borda do campo quando ele não está focado.
  // ===================================================
  OutlineInputBorder _buildEnabledBorder({
    required Color primaryColor,
    required Color errorColor,
  }) {
    if (hasError) {
      return _border(errorColor);
    }

    if (isValid) {
      return _border(primaryColor);
    }

    return _border(AppColors.whiteOverlay(0.24));
  }

  // ===================================================
  // BUILD FOCUSED BORDER
  // ---------------------------------------------------
  // Define a borda do campo quando ele está focado.
  // ===================================================
  OutlineInputBorder _buildFocusedBorder({
    required Color primaryColor,
    required Color errorColor,
  }) {
    if (hasError) {
      return _border(errorColor, width: 1.5);
    }

    return _border(primaryColor, width: 1.5);
  }

  // ===================================================
  // BORDER
  // ---------------------------------------------------
  // Helper para manter o padrão visual das bordas.
  // ===================================================
  OutlineInputBorder _border(
    Color color, {
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}
