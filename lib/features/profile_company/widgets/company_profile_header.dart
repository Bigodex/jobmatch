// =======================================================
// COMPANY PROFILE HEADER
// -------------------------------------------------------
// Cabeçalho da página empresarial seguindo o layout visual
// do perfil, com edição inline no mesmo padrão do perfil
// de usuário.
// =======================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/services/cloudinary_service.dart';
import 'package:jobmatch/features/profile_company/models/company_profile_model.dart';
import 'package:jobmatch/features/profile_company/providers/company_profile_provider.dart';
import 'package:jobmatch/features/profile_company/widgets/company_category_icon.dart';
import 'package:jobmatch/shared/widgets/app_edit_button.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class CompanyProfileHeader extends ConsumerStatefulWidget {
  final CompanyProfileModel company;

  const CompanyProfileHeader({
    super.key,
    required this.company,
  });

  @override
  ConsumerState<CompanyProfileHeader> createState() =>
      _CompanyProfileHeaderState();
}

class _CompanyProfileHeaderState extends ConsumerState<CompanyProfileHeader> {
  final _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _sloganController;

  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploadingCover = false;
  bool _isUploadingLogo = false;

  String _coverUrl = '';
  String _logoUrl = '';
  String _category = '';

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _sloganController = TextEditingController();
    _hydrate(widget.company);
  }

  @override
  void didUpdateWidget(covariant CompanyProfileHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.company.id != widget.company.id && !_isEditing) {
      _hydrate(widget.company);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sloganController.dispose();
    super.dispose();
  }

  void _hydrate(CompanyProfileModel company) {
    _coverUrl = company.coverUrl;
    _logoUrl = company.logoUrl;
    _category = company.companyCategory;
    _nameController.text = company.companyName;
    _sloganController.text = company.slogan;
  }

  Future<void> _pickImage({required bool isCover}) async {
    if (!_isEditing || _isSaving || _isUploadingCover || _isUploadingLogo) {
      return;
    }

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
    );

    if (picked == null) return;

    setState(() {
      if (isCover) {
        _isUploadingCover = true;
      } else {
        _isUploadingLogo = true;
      }
    });

    try {
      final url = await CloudinaryService.uploadImage(File(picked.path));

      if (!mounted) return;

      if (url != null && url.trim().isNotEmpty) {
        setState(() {
          if (isCover) {
            _coverUrl = url.trim();
          } else {
            _logoUrl = url.trim();
          }
        });
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível enviar a imagem. Tente novamente.'),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        if (isCover) {
          _isUploadingCover = false;
        } else {
          _isUploadingLogo = false;
        }
      });
    }
  }

  Future<void> _selectCategory() async {
    if (!_isEditing || _isSaving) return;

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            itemCount: companyCategoryOptions.length,
            separatorBuilder: (_, __) => Divider(
              color: Colors.white.withOpacity(0.06),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final option = companyCategoryOptions[index];
              final isSelected = option == _category;

              return ListTile(
                onTap: () => Navigator.of(context).pop(option),
                leading: SvgPicture.asset(
                  getCompanyCategoryIcon(option),
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                title: Text(
                  option,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              );
            },
          ),
        );
      },
    );

    if (selected == null) return;

    setState(() {
      _category = selected;
    });
  }

  Future<void> _save() async {
    if (_isSaving || _isUploadingCover || _isUploadingLogo) return;

    final name = _nameController.text.trim();
    final category = _category.trim();

    if (name.length < 2 || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha nome e área da empresa para salvar.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final updated = widget.company.copyWith(
      coverUrl: _coverUrl.trim(),
      logoUrl: _logoUrl.trim(),
      companyName: name,
      companyCategory: category,
      slogan: _sloganController.text.trim(),
    );

    try {
      await ref
          .read(companyProfileProvider.notifier)
          .updateCompanyProfile(updated)
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              throw Exception('Tempo limite ao salvar.');
            },
          );

      ref.invalidate(companyProfilesProvider);

      if (updated.id.trim().isNotEmpty) {
        ref.invalidate(companyProfileByIdProvider(updated.id.trim()));
      }

      if (!mounted) return;

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível salvar o perfil empresarial. Verifique sua conexão e tente novamente.',
          ),
        ),
      );
    }
  }

  void _toggleEditing() {
    if (_isSaving || _isUploadingCover || _isUploadingLogo) return;

    if (_isEditing) {
      _save();
      return;
    }

    _hydrate(widget.company);
    setState(() => _isEditing = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final companyName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Página empresarial';

    final companyCategory = _category.trim().isNotEmpty
        ? _category.trim()
        : 'Empresa';

    final slogan = _sloganController.text.trim();

    return AppSectionCard(
      child: Column(
        children: [
          // ===================================================
          // COVER + LOGO
          // ===================================================
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              _CompanyCover(
                imageUrl: _coverUrl,
                isEditable: _isEditing,
                isUploading: _isUploadingCover,
                onTap: () => _pickImage(isCover: true),
              ),
              Positioned(
                bottom: -44,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _CompanyLogo(
                      imageUrl: _logoUrl,
                      isEditable: _isEditing,
                      isUploading: _isUploadingLogo,
                      onTap: () => _pickImage(isCover: false),
                    ),
                    const Positioned(
                      top: -4,
                      left: -12,
                      child: _VerifiedBadge(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 58),

          // ===================================================
          // COMPANY INFO
          // ===================================================
          _isEditing
              ? Column(
                  children: [
                    _HeaderTextField(
                      controller: _nameController,
                      label: 'Nome da empresa',
                    ),
                    const SizedBox(height: 12),
                    _CategorySelectorField(
                      value: companyCategory,
                      iconPath: getCompanyCategoryIcon(companyCategory),
                      onTap: _selectCategory,
                    ),
                    const SizedBox(height: 12),
                    _HeaderTextField(
                      controller: _sloganController,
                      label: 'Slogan',
                      hintText: 'Opcional',
                      maxLines: 2,
                    ),
                  ],
                )
              : Column(
                  children: [
                    Text(
                      companyName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _CompanyCategoryLabel(
                      label: companyCategory,
                      icon: getCompanyCategoryIcon(companyCategory),
                    ),
                    if (slogan.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '“$slogan”',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

          const SizedBox(height: 24),

          // ===================================================
          // QUICK ACTIONS / STATS
          // ===================================================
          Row(
            children: [
              Expanded(
                child: _CircleHeaderAction(
                  icon: AppIcons.group,
                  value: widget.company.employeesCount > 0
                      ? widget.company.employeesCount.toString()
                      : '0',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CircleHeaderAction(
                  icon: AppIcons.chart,
                  value: widget.company.jobs.length.toString(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          AppEditButton(
            label: _isEditing
                ? (_isSaving ? 'Salvando...' : 'Salvar')
                : 'Editar perfil empresarial',
            icon: Icon(
              _isEditing ? Icons.check_rounded : Icons.edit,
              size: 18,
            ),
            color: _isEditing ? theme.colorScheme.primary : null,
            onPressed: _toggleEditing,
          ),
        ],
      ),
    );
  }
}

class _CompanyCategoryLabel extends StatelessWidget {
  final String label;
  final String icon;

  const _CompanyCategoryLabel({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          icon,
          width: 15,
          height: 15,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompanyCover extends StatelessWidget {
  final String? imageUrl;
  final bool isEditable;
  final bool isUploading;
  final VoidCallback? onTap;

  const _CompanyCover({
    this.imageUrl,
    this.isEditable = false,
    this.isUploading = false,
    this.onTap,
  });

  bool get _hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;

    return GestureDetector(
      onTap: isEditable ? onTap : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 190,
              color: colors.cardTertiary,
              child: _hasImage
                  ? Image.network(
                      imageUrl!.trim(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _DefaultCoverContent(color: colors.cardSecondary);
                      },
                    )
                  : _DefaultCoverContent(color: colors.cardSecondary),
            ),
            if (isEditable)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.34),
                  child: Center(
                    child: isUploading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DefaultCoverContent extends StatelessWidget {
  final Color color;

  const _DefaultCoverContent({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: SvgPicture.asset(
          AppIcons.buildingfull,
          width: 52,
          height: 52,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.18),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  final String? imageUrl;
  final bool isEditable;
  final bool isUploading;
  final VoidCallback? onTap;

  const _CompanyLogo({
    this.imageUrl,
    this.isEditable = false,
    this.isUploading = false,
    this.onTap,
  });

  bool get _hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return GestureDetector(
      onTap: isEditable ? onTap : null,
      child: Container(
        width: 96,
        height: 96,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Container(
                color: colors.cardTertiary,
                child: _hasImage
                    ? Image.network(
                        imageUrl!.trim(),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const _DefaultLogoIcon();
                        },
                      )
                    : const _DefaultLogoIcon(),
              ),
              if (isEditable)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Center(
                      child: isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.2),
                            )
                          : const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultLogoIcon extends StatelessWidget {
  const _DefaultLogoIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        AppIcons.buildingfull,
        width: 34,
        height: 34,
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary,
        border: Border.all(
          color: theme.colorScheme.surface,
          width: 4,
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          AppIcons.verify,
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _CircleHeaderAction extends StatelessWidget {
  final String icon;
  final String value;

  const _CircleHeaderAction({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final int maxLines;

  const _HeaderTextField({
    required this.controller,
    required this.label,
    this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}

class _CategorySelectorField extends StatelessWidget {
  final String value;
  final String iconPath;
  final VoidCallback onTap;

  const _CategorySelectorField({
    required this.value,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = value.trim().isNotEmpty && value.trim() != 'Empresa';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.colorScheme.primary),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                iconPath,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasValue ? value : 'Selecione a área da empresa',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: hasValue ? Colors.white : Colors.white54,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withOpacity(0.76),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
