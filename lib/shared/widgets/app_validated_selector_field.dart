// =======================================================
// APP VALIDATED SELECTOR FIELD
// -------------------------------------------------------
// Campo reutilizável para seleção com estados:
// - normal
// - erro   -> borda vermelha + exclamação
// - válido -> borda primary + check
//
// Suporta:
// - ícone selecionado via SVG
// - loading no lugar da seta
// - estado disabled
// - validação visual consistente com AppValidatedInputField
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_colors.dart';

class AppValidatedSelectorField extends StatelessWidget {
  final String hint;
  final String? value;
  final String? selectedIcon;
  final VoidCallback onTap;
  final bool hasError;
  final bool isValid;
  final bool enabled;
  final bool isLoading;

  const AppValidatedSelectorField({
    super.key,
    required this.hint,
    required this.value,
    required this.onTap,
    required this.hasError,
    required this.isValid,
    this.selectedIcon,
    this.enabled = true,
    this.isLoading = false,
  });

  // ===================================================
  // BUILD
  // ---------------------------------------------------
  // Monta o seletor visual com borda dinâmica, ícone de
  // validação, ícone selecionado e indicador de loading.
  // ===================================================
  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.trim().isNotEmpty;
    final shouldShowSelectedIcon =
        hasValue && selectedIcon != null && selectedIcon!.trim().isNotEmpty;

    final borderColor = _borderColor();
    final iconColor = _iconColor();
    final validationIcon = _buildValidationIcon();

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: AppColors.whiteOverlay(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: isValid || hasError ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              if (shouldShowSelectedIcon) ...[
                SvgPicture.asset(
                  selectedIcon!,
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    iconColor,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  hasValue ? value!.trim() : hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: _textColor(hasValue: hasValue),
                    fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildActionIcon(),
              if (validationIcon != null) validationIcon,
            ],
          ),
        ),
      ),
    );
  }

  // ===================================================
  // BORDER COLOR
  // ---------------------------------------------------
  // Define a cor da borda conforme o estado do seletor.
  // ===================================================
  Color _borderColor() {
    if (hasError) {
      return AppColors.error;
    }

    if (isValid) {
      return AppColors.primary;
    }

    return AppColors.whiteOverlay(0.24);
  }

  // ===================================================
  // ICON COLOR
  // ---------------------------------------------------
  // Define a cor do ícone selecionado conforme o estado.
  // ===================================================
  Color _iconColor() {
    if (hasError) {
      return AppColors.error;
    }

    if (isValid) {
      return AppColors.primary;
    }

    return AppColors.whiteOverlay(0.7);
  }

  // ===================================================
  // TEXT COLOR
  // ---------------------------------------------------
  // Define a cor do texto conforme valor e estado enabled.
  // ===================================================
  Color _textColor({
    required bool hasValue,
  }) {
    if (!enabled) {
      return AppColors.whiteOverlay(0.38);
    }

    if (hasValue) {
      return AppColors.textPrimary;
    }

    return AppColors.whiteOverlay(0.54);
  }

  // ===================================================
  // BUILD VALIDATION ICON
  // ---------------------------------------------------
  // Retorna o ícone de erro ou sucesso.
  // Caso o campo esteja neutro, retorna null.
  // ===================================================
  Widget? _buildValidationIcon() {
    if (hasError) {
      return const Padding(
        padding: EdgeInsets.only(left: 8),
        child: Icon(
          Icons.error_outline_rounded,
          color: AppColors.error,
          size: 20,
        ),
      );
    }

    if (isValid) {
      return const Padding(
        padding: EdgeInsets.only(left: 8),
        child: Icon(
          Icons.check_circle_rounded,
          color: AppColors.primary,
          size: 20,
        ),
      );
    }

    return null;
  }

  // ===================================================
  // BUILD ACTION ICON
  // ---------------------------------------------------
  // Exibe loading quando necessário. Caso contrário,
  // mostra a seta de expansão do seletor.
  // ===================================================
  Widget _buildActionIcon() {
    if (isLoading) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      );
    }

    return Icon(
      Icons.expand_more_rounded,
      color: enabled ? AppColors.whiteOverlay(0.7) : AppColors.whiteOverlay(0.3),
      size: 22,
    );
  }
}
