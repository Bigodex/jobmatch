// =======================================================
// STEP COMPANY HEADER
// -------------------------------------------------------
// Etapa de capa e logo da página empresarial
// - ambos opcionais
// - visual no tema do JobMatch
// - upload via galeria
// - salva no companyOnboardingProvider
// - permite excluir capa e logo
// - conteúdo interno envolto por card
// =======================================================

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/services/cloudinary_service.dart';
import 'package:jobmatch/features/company/providers/company_onboarding_provider.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class StepCompanyHeader extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final Function(String?) onJobuMessageChange;

  const StepCompanyHeader({
    super.key,
    required this.onNext,
    required this.onJobuMessageChange,
  });

  @override
  ConsumerState<StepCompanyHeader> createState() => _StepCompanyHeaderState();
}

class _StepCompanyHeaderState extends ConsumerState<StepCompanyHeader> {
  final ImagePicker _picker = ImagePicker();

  bool _isUploadingCover = false;
  bool _isUploadingLogo = false;
  bool _isNavigating = false;

  bool get _isUploading => _isUploadingCover || _isUploadingLogo;
  bool get _isBusy => _isUploading || _isNavigating;

  Future<void> _showJobuMessageAndWait(
    String message, {
    int minMilliseconds = 1600,
  }) async {
    widget.onJobuMessageChange(message);

    final estimated =
        (message.replaceAll('\n', ' ').trim().length * 42).clamp(1200, 2400);

    await Future.delayed(
      Duration(
        milliseconds: estimated > minMilliseconds ? estimated : minMilliseconds,
      ),
    );
  }

  Future<T> _withMinimumLoading<T>(
    Future<T> Function() action, {
    int minimumMilliseconds = 1800,
  }) async {
    final stopwatch = Stopwatch()..start();

    final result = await action();

    stopwatch.stop();

    final remaining = minimumMilliseconds - stopwatch.elapsedMilliseconds;

    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }

    return result;
  }

  Future<void> _pickCover() async {
    if (_isBusy) return;

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    await _showJobuMessageAndWait(
      'Boa. Vou preparar a capa da empresa.',
    );

    if (!mounted) return;

    setState(() {
      _isUploadingCover = true;
    });

    try {
      final url = await _withMinimumLoading(
        () => CloudinaryService.uploadImage(File(picked.path)),
      );

      if (!mounted) return;

      if (url != null) {
        ref.read(companyOnboardingProvider.notifier).setCoverUrl(url);

        await _showJobuMessageAndWait(
          'Perfeito. Capa adicionada com sucesso.',
        );
      } else {
        await _showJobuMessageAndWait(
          'Não consegui enviar a capa agora.',
        );
      }
    } catch (_) {
      if (!mounted) return;

      await _showJobuMessageAndWait(
        'Deu erro ao enviar a capa.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingCover = false;
        });
      }
    }
  }

  Future<void> _pickLogo() async {
    if (_isBusy) return;

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    await _showJobuMessageAndWait(
      'Show. Vou preparar o logo da empresa.',
    );

    if (!mounted) return;

    setState(() {
      _isUploadingLogo = true;
    });

    try {
      final url = await _withMinimumLoading(
        () => CloudinaryService.uploadImage(File(picked.path)),
      );

      if (!mounted) return;

      if (url != null) {
        ref.read(companyOnboardingProvider.notifier).setLogoUrl(url);

        await _showJobuMessageAndWait(
          'Ótimo. Logo adicionado com sucesso.',
        );
      } else {
        await _showJobuMessageAndWait(
          'Não consegui enviar o logo agora.',
        );
      }
    } catch (_) {
      if (!mounted) return;

      await _showJobuMessageAndWait(
        'Deu erro ao enviar o logo.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingLogo = false;
        });
      }
    }
  }

  Future<void> _removeCover() async {
    if (_isBusy) return;

    ref.read(companyOnboardingProvider.notifier).setCoverUrl(null);

    await _showJobuMessageAndWait(
      'Capa removida da página.',
      minMilliseconds: 1200,
    );
  }

  Future<void> _removeLogo() async {
    if (_isBusy) return;

    ref.read(companyOnboardingProvider.notifier).setLogoUrl(null);

    await _showJobuMessageAndWait(
      'Logo removido da página.',
      minMilliseconds: 1200,
    );
  }

  Future<void> _handleSkip() async {
    if (_isBusy) return;

    setState(() {
      _isNavigating = true;
    });

    await _showJobuMessageAndWait(
      'Sem problemas. Vamos seguir.',
      minMilliseconds: 1200,
    );

    if (!mounted) return;

    setState(() {
      _isNavigating = false;
    });

    widget.onJobuMessageChange(null);
    widget.onNext();
  }

  Future<void> _handleContinue() async {
    if (_isBusy) return;

    setState(() {
      _isNavigating = true;
    });

    await _showJobuMessageAndWait(
      'Boa. Vamos para a próxima etapa.',
      minMilliseconds: 1200,
    );

    if (!mounted) return;

    setState(() {
      _isNavigating = false;
    });

    widget.onJobuMessageChange(null);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;
    final company = ref.watch(companyOnboardingProvider);

    final coverUrl = (company.coverUrl ?? '').trim();
    final logoUrl = (company.logoUrl ?? '').trim();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  bottom: 16,
                  top: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.cardTertiary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ===================================================
                    // HEADER
                    // ===================================================
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.image,
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Visual da Página',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Divider(
                      color: Colors.white.withOpacity(0.08),
                      height: 1,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Adicione a capa e o logo da empresa para deixar a página mais forte e mais confiável. Ambos são opcionais.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.68),
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ===================================================
                    // COVER
                    // ===================================================
                    const _SectionLabel(
                      label: 'Capa da Empresa',
                    ),
                    const SizedBox(height: 10),
                    _CompanyCoverUpload(
                      imageUrl: coverUrl,
                      isLoading: _isUploadingCover,
                      onTap: _pickCover,
                      onDelete: _removeCover,
                    ),

                    const SizedBox(height: 20),

                    // ===================================================
                    // LOGO
                    // ===================================================
                    const _SectionLabel(
                      label: 'Logo / Foto de Perfil',
                    ),
                    const SizedBox(height: 10),
                    _CompanyLogoUpload(
                      imageUrl: logoUrl,
                      isLoading: _isUploadingLogo,
                      onTap: _pickLogo,
                      onDelete: _removeLogo,
                    ),

                    const SizedBox(height: 24),

                    // ===================================================
                    // ACTIONS
                    // ===================================================
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isBusy ? null : _handleSkip,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: theme.colorScheme.primary,
                              ),
                              foregroundColor: theme.colorScheme.primary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isNavigating
                                ? const _LoadingDots()
                                : const Text('Pular'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isBusy ? null : _handleContinue,
                            child: _isNavigating
                                ? const _LoadingDots(
                                    color: Colors.black,
                                  )
                                : const Text('Continuar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// SECTION LABEL
// =======================================================
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          AppIcons.image,
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// =======================================================
// COVER UPLOAD
// =======================================================
class _CompanyCoverUpload extends StatelessWidget {
  final String imageUrl;
  final bool isLoading;
  final VoidCallback onTap;
  final Future<void> Function() onDelete;

  const _CompanyCoverUpload({
    required this.imageUrl,
    required this.isLoading,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    final hasImage = imageUrl.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: double.infinity,
          height: 158,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: colors.cardTertiary,
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(1.0),
            ),
            image: hasImage
                ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: hasImage
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.34),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Row(
                        children: [
                          _ActionBadge(
                            iconPath: AppIcons.trash,
                            backgroundColor: Colors.redAccent.withOpacity(0.92),
                            iconColor: Colors.white,
                            isLoading: false,
                            onTap: onDelete,
                          ),
                          const SizedBox(width: 8),
                          _ActionBadge(
                            iconPath: AppIcons.pencil,
                            backgroundColor: theme.colorScheme.primary,
                            iconColor: Colors.white,
                            isLoading: isLoading,
                            onTap: () async => onTap(),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: Text(
                        'Toque para trocar a capa',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isLoading
                            ? _LoadingDots(
                                color: theme.colorScheme.primary,
                              )
                            : SvgPicture.asset(
                                AppIcons.cameraplus,
                                width: 28,
                                height: 28,
                                colorFilter: ColorFilter.mode(
                                  theme.colorScheme.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                        const SizedBox(height: 12),
                        Text(
                          'Adicionar capa',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Use uma imagem horizontal que represente a empresa.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.62),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

// =======================================================
// LOGO UPLOAD
// =======================================================
class _CompanyLogoUpload extends StatelessWidget {
  final String imageUrl;
  final bool isLoading;
  final VoidCallback onTap;
  final Future<void> Function() onDelete;

  const _CompanyLogoUpload({
    required this.imageUrl,
    required this.isLoading,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    final hasImage = imageUrl.isNotEmpty;

    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.cardTertiary,
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(1.0),
                  width: 2,
                ),
                image: hasImage
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: hasImage
                  ? Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 0, bottom: 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ActionBadge(
                              iconPath: AppIcons.trash,
                              backgroundColor:
                                  Colors.redAccent.withOpacity(0.92),
                              iconColor: Colors.white,
                              isLoading: false,
                              onTap: onDelete,
                              size: 28,
                              iconSize: 12,
                            ),
                            const SizedBox(width: 6),
                            _ActionBadge(
                              iconPath: AppIcons.pencil,
                              backgroundColor: theme.colorScheme.primary,
                              iconColor: Colors.white,
                              isLoading: isLoading,
                              onTap: () async => onTap(),
                              size: 28,
                              iconSize: 12,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: isLoading
                          ? _LoadingDots(
                              color: theme.colorScheme.primary,
                            )
                          : SvgPicture.asset(
                              AppIcons.image,
                              width: 26,
                              height: 26,
                              colorFilter: ColorFilter.mode(
                                theme.colorScheme.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasImage ? 'Logo adicionado' : 'Adicionar logo',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hasImage
                    ? 'Você pode trocar ou excluir o logo a qualquer momento.'
                    : 'Pode ser o logo oficial ou uma foto de perfil institucional da empresa.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.62),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =======================================================
// ACTION BADGE
// =======================================================
class _ActionBadge extends StatelessWidget {
  final String iconPath;
  final Color backgroundColor;
  final Color iconColor;
  final bool isLoading;
  final Future<void> Function() onTap;
  final double size;
  final double iconSize;

  const _ActionBadge({
    required this.iconPath,
    required this.backgroundColor,
    required this.iconColor,
    required this.isLoading,
    required this.onTap,
    this.size = 28,
    this.iconSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : () => onTap(),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isLoading
                ? _LoadingDots(
                    color: iconColor,
                    dotSize: 3,
                    spacing: 2,
                  )
                : SvgPicture.asset(
                    iconPath,
                    width: iconSize,
                    height: iconSize,
                    colorFilter: ColorFilter.mode(
                      iconColor,
                      BlendMode.srcIn,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// =======================================================
// LOADING DOTS
// -------------------------------------------------------
// 3 pontinhos da esquerda para a direita
// =======================================================
class _LoadingDots extends StatefulWidget {
  final Color color;
  final double dotSize;
  final double spacing;

  const _LoadingDots({
    this.color = Colors.white,
    this.dotSize = 5,
    this.spacing = 4,
  });

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _opacityForDot(int index) {
    final value = _controller.value;
    final phase = (value * 3);

    if (phase >= index && phase < index + 1) {
      return 1.0;
    }

    return 0.28;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index == 2 ? 0 : widget.spacing,
              ),
              child: Opacity(
                opacity: _opacityForDot(index),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}