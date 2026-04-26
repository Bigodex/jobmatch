// =======================================================
// APP FEEDBACK MESSAGE
// -------------------------------------------------------
// Componente visual padrão para mensagens de feedback.
//
// Objetivo:
// - substituir SnackBars genéricos em erros importantes
// - manter mensagens dentro do design do JobMatch
// - suportar estados de erro, sucesso, aviso e informação
// - permitir uso de ícones SVG vindos do AppIcons
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_colors.dart';

// =======================================================
// APP FEEDBACK TYPE
// -------------------------------------------------------
// Define os tipos visuais suportados pelo componente.
// =======================================================
enum AppFeedbackType {
  error,
  success,
  warning,
  info,
}

// =======================================================
// APP FEEDBACK MESSAGE
// -------------------------------------------------------
// Card compacto para exibir mensagens visuais ao usuário.
//
// Pode ser usado em formulários, telas de edição, etapas de
// onboarding e qualquer fluxo que precise mostrar erro ou
// status sem recorrer a SnackBar genérico.
// =======================================================
class AppFeedbackMessage extends StatelessWidget {
  final String message;
  final AppFeedbackType type;
  final String? title;
  final String? iconAsset;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onClose;

  const AppFeedbackMessage({
    super.key,
    required this.message,
    required this.type,
    this.title,
    this.iconAsset,
    this.margin = EdgeInsets.zero,
    this.onClose,
  });

  // ===================================================
  // ERROR
  // ---------------------------------------------------
  // Feedback visual para falhas de validação, persistência
  // ou ações que não puderam ser concluídas.
  // ===================================================
  const AppFeedbackMessage.error({
    super.key,
    required this.message,
    this.title,
    this.iconAsset,
    this.margin = EdgeInsets.zero,
    this.onClose,
  }) : type = AppFeedbackType.error;

  // ===================================================
  // SUCCESS
  // ---------------------------------------------------
  // Feedback visual para ações concluídas com sucesso.
  // ===================================================
  const AppFeedbackMessage.success({
    super.key,
    required this.message,
    this.title,
    this.iconAsset,
    this.margin = EdgeInsets.zero,
    this.onClose,
  }) : type = AppFeedbackType.success;

  // ===================================================
  // WARNING
  // ---------------------------------------------------
  // Feedback visual para avisos e situações que exigem
  // atenção, mas não impedem totalmente o fluxo.
  // ===================================================
  const AppFeedbackMessage.warning({
    super.key,
    required this.message,
    this.title,
    this.iconAsset,
    this.margin = EdgeInsets.zero,
    this.onClose,
  }) : type = AppFeedbackType.warning;

  // ===================================================
  // INFO
  // ---------------------------------------------------
  // Feedback visual para mensagens informativas.
  // ===================================================
  const AppFeedbackMessage.info({
    super.key,
    required this.message,
    this.title,
    this.iconAsset,
    this.margin = EdgeInsets.zero,
    this.onClose,
  }) : type = AppFeedbackType.info;

  // ===================================================
  // BUILD
  // ---------------------------------------------------
  // Monta o card visual com cor, borda, ícone e conteúdo
  // de acordo com o tipo informado.
  // ===================================================
  @override
  Widget build(BuildContext context) {
    final color = _colorByType();
    final fallbackIcon = _fallbackIconByType();

    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.overlay(color, 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.overlay(color, 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FeedbackIcon(
            color: color,
            iconAsset: iconAsset,
            fallbackIcon: fallbackIcon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _FeedbackContent(
              title: title,
              message: message,
              color: color,
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: 8),
            _FeedbackCloseButton(
              color: color,
              onClose: onClose!,
            ),
          ],
        ],
      ),
    );
  }

  Color _colorByType() {
    return switch (type) {
      AppFeedbackType.error => AppColors.error,
      AppFeedbackType.success => AppColors.success,
      AppFeedbackType.warning => AppColors.warning,
      AppFeedbackType.info => AppColors.info,
    };
  }

  IconData _fallbackIconByType() {
    return switch (type) {
      AppFeedbackType.error => Icons.error_outline_rounded,
      AppFeedbackType.success => Icons.check_circle_outline_rounded,
      AppFeedbackType.warning => Icons.warning_amber_rounded,
      AppFeedbackType.info => Icons.info_outline_rounded,
    };
  }
}

// =======================================================
// FEEDBACK ICON
// -------------------------------------------------------
// Renderiza o ícone do feedback.
//
// Se iconAsset for informado, usa SVG com colorFilter.
// Caso contrário, usa ícone Material como fallback seguro.
// =======================================================
class _FeedbackIcon extends StatelessWidget {
  final Color color;
  final String? iconAsset;
  final IconData fallbackIcon;

  const _FeedbackIcon({
    required this.color,
    required this.iconAsset,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final asset = iconAsset;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.overlay(color, 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: asset != null
            ? SvgPicture.asset(
                asset,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  color,
                  BlendMode.srcIn,
                ),
              )
            : Icon(
                fallbackIcon,
                size: 20,
                color: color,
              ),
      ),
    );
  }
}

// =======================================================
// FEEDBACK CONTENT
// -------------------------------------------------------
// Renderiza título opcional e mensagem principal.
// =======================================================
class _FeedbackContent extends StatelessWidget {
  final String? title;
  final String message;
  final Color color;

  const _FeedbackContent({
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final hasTitle = title != null && title!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasTitle) ...[
          Text(
            title!.trim(),
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          message,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

// =======================================================
// FEEDBACK CLOSE BUTTON
// -------------------------------------------------------
// Botão opcional para fechar/remover a mensagem.
// =======================================================
class _FeedbackCloseButton extends StatelessWidget {
  final Color color;
  final VoidCallback onClose;

  const _FeedbackCloseButton({
    required this.color,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(
          Icons.close_rounded,
          size: 18,
          color: AppColors.overlay(color, 0.9),
        ),
      ),
    );
  }
}
