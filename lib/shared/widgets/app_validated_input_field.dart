// =======================================================
// APP VALIDATED INPUT FIELD
// -------------------------------------------------------
// Campo reutilizável com estados:
// - normal
// - erro   -> borda vermelha + exclamação
// - válido -> borda primary + check
// Suporta trailing customizado, como botão de olho da senha
// -------------------------------------------------------
// Ajuste:
// - aceita focusNode
// - aceita onEditingComplete
// - aceita onTapOutside
// - textarea: validação no topo superior direito
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final errorColor = theme.colorScheme.error;

    final isMultilineField =
        !obscureText && ((maxLines ?? 1) > 1 || (minLines ?? 1) > 1);

    OutlineInputBorder border(
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

    final Widget? validationIcon = hasError
        ? Icon(
            Icons.error_outline_rounded,
            color: errorColor,
            size: 20,
          )
        : isValid
            ? Icon(
                Icons.check_circle_rounded,
                color: primaryColor,
                size: 20,
              )
            : null;

    Widget? suffixIcon;

    if (isMultilineField) {
      if (validationIcon != null) {
        suffixIcon = Padding(
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
    } else {
      if (validationIcon != null || trailing != null) {
        suffixIcon = Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailing != null) trailing!,
              if (trailing != null && validationIcon != null)
                const SizedBox(width: 6),
              if (validationIcon != null) validationIcon,
            ],
          ),
        );
      }
    }

    final OutlineInputBorder enabledBorder = hasError
        ? border(errorColor)
        : isValid
            ? border(primaryColor)
            : border(Colors.white24);

    final OutlineInputBorder focusedBorder = hasError
        ? border(errorColor, width: 1.5)
        : border(primaryColor, width: 1.5);

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
      style: const TextStyle(fontSize: 13),
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onTapOutside: onTapOutside,
      decoration: InputDecoration(
        hintText: hint,
        counterText: maxLength != null ? '' : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
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
}