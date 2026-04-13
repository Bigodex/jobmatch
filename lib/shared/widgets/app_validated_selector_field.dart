// =======================================================
// APP VALIDATED SELECTOR FIELD
// -------------------------------------------------------
// Campo reutilizável para seleção com estados:
// - normal
// - erro   -> borda vermelha + exclamação
// - válido -> borda primary + check
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final errorColor = theme.colorScheme.error;

    final borderColor = hasError
        ? errorColor
        : isValid
            ? primaryColor
            : Colors.white24;

    final iconColor = hasError
        ? errorColor
        : isValid
            ? primaryColor
            : Colors.white70;

    final hasValue = value != null && value!.isNotEmpty;
    final shouldShowSelectedIcon =
        hasValue && selectedIcon != null && selectedIcon!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
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
                  color: iconColor,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  hasValue ? value! : hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: enabled
                        ? (hasValue ? Colors.white : Colors.white54)
                        : Colors.white38,
                    fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (hasError) ...[
                Icon(
                  Icons.error_outline_rounded,
                  color: errorColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ] else if (isValid) ...[
                Icon(
                  Icons.check_circle_rounded,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryColor,
                  ),
                )
              else
                Icon(
                  Icons.expand_more_rounded,
                  color: enabled ? Colors.white70 : Colors.white30,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}