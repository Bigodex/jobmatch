// =======================================================
// EDIT COMPANY PROFILE SCREEN
// -------------------------------------------------------
// Edição principal do perfil empresarial.
// - capa
// - logo
// - nome
// - área/categoria
// - slogan
// - dados simples dos cards
// =======================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/services/cloudinary_service.dart';
import 'package:jobmatch/features/profile_company/models/company_profile_model.dart';
import 'package:jobmatch/features/profile_company/providers/company_profile_provider.dart';
import 'package:jobmatch/features/profile_company/widgets/company_category_icon.dart';
import 'package:jobmatch/shared/widgets/app_header.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class EditCompanyProfileScreen extends ConsumerStatefulWidget {
  final String? companyId;

  const EditCompanyProfileScreen({
    super.key,
    this.companyId,
  });

  @override
  ConsumerState<EditCompanyProfileScreen> createState() =>
      _EditCompanyProfileScreenState();
}

class _EditCompanyProfileScreenState
    extends ConsumerState<EditCompanyProfileScreen> {
  final _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _sloganController;
  late final TextEditingController _companyTypeController;
  late final TextEditingController _sectorController;
  late final TextEditingController _websiteController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _employeesController;
  late final TextEditingController _companySizeController;

  CompanyProfileModel? _company;
  String _coverUrl = '';
  String _logoUrl = '';
  String _category = '';
  bool _isHiring = false;
  bool _isUploadingCover = false;
  bool _isUploadingLogo = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _sloganController = TextEditingController();
    _companyTypeController = TextEditingController();
    _sectorController = TextEditingController();
    _websiteController = TextEditingController();
    _descriptionController = TextEditingController();
    _employeesController = TextEditingController();
    _companySizeController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sloganController.dispose();
    _companyTypeController.dispose();
    _sectorController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    _employeesController.dispose();
    _companySizeController.dispose();
    super.dispose();
  }

  void _hydrate(CompanyProfileModel company) {
    if (_company?.id == company.id) return;

    _company = company;
    _coverUrl = company.coverUrl;
    _logoUrl = company.logoUrl;
    _category = company.companyCategory;
    _isHiring = company.isHiring;
    _nameController.text = company.companyName;
    _sloganController.text = company.slogan;
    _companyTypeController.text = company.companyType;
    _sectorController.text = company.sector;
    _websiteController.text = company.website;
    _descriptionController.text = company.description;
    _employeesController.text = company.employeesCount > 0
        ? company.employeesCount.toString()
        : '';
    _companySizeController.text = company.companySize;
  }

  Future<void> _pickImage({required bool isCover}) async {
    if (_isUploadingCover || _isUploadingLogo || _isSaving) return;

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
    } finally {
      if (mounted) {
        setState(() {
          if (isCover) {
            _isUploadingCover = false;
          } else {
            _isUploadingLogo = false;
          }
        });
      }
    }
  }

  Future<void> _selectCategory() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
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
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                title: Text(
                  option,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
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
    final company = _company;
    if (company == null || _isSaving) return;

    final name = _nameController.text.trim();
    final category = _category.trim();

    if (name.length < 2 || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha nome da empresa e área antes de salvar.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updated = company.copyWith(
        coverUrl: _coverUrl.trim(),
        logoUrl: _logoUrl.trim(),
        companyName: name,
        companyCategory: category,
        slogan: _sloganController.text.trim(),
        companyType: _companyTypeController.text.trim(),
        sector: _sectorController.text.trim(),
        website: _websiteController.text.trim(),
        description: _descriptionController.text.trim(),
        isHiring: _isHiring,
        employeesCount: int.tryParse(_employeesController.text.trim()) ?? 0,
        companySize: _companySizeController.text.trim(),
      );

      await ref
          .read(companyProfileProvider.notifier)
          .updateCompanyProfile(updated);

      ref.invalidate(companyProfilesProvider);
      ref.invalidate(companyProfileByIdProvider(updated.id));

      if (!mounted) return;
      context.pop();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não consegui salvar agora. Tente novamente.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeCompanyId = widget.companyId?.trim() ?? '';
    final companyAsync = safeCompanyId.isNotEmpty
        ? ref.watch(companyProfileByIdProvider(safeCompanyId))
        : ref.watch(companyProfileProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Editar Perfil Empresarial',
              backFallbackRoute: safeCompanyId.isNotEmpty
                  ? '/company/profile/$safeCompanyId'
                  : '/company/profile',
            ),
            Expanded(
              child: companyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Erro ao carregar página empresarial: $error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (company) {
                  if (company == null) {
                    return const Center(
                      child: Text('Página empresarial não encontrada.'),
                    );
                  }

                  _hydrate(company);

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      _buildImagesCard(),
                      const SizedBox(height: 10),
                      _buildMainInfoCard(),
                      const SizedBox(height: 10),
                      _buildExtraInfoCard(),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _isSaving ? 'Salvando...' : 'Salvar alterações',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesCard() {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _EditSectionTitle(
            icon: AppIcons.image,
            title: 'Fotos da empresa',
          ),
          const SizedBox(height: 14),
          _ImageActionTile(
            title: 'Capa da empresa',
            imageUrl: _coverUrl,
            isLoading: _isUploadingCover,
            onTap: () => _pickImage(isCover: true),
            onRemove: () => setState(() => _coverUrl = ''),
          ),
          const SizedBox(height: 12),
          _ImageActionTile(
            title: 'Logo de perfil',
            imageUrl: _logoUrl,
            isLoading: _isUploadingLogo,
            onTap: () => _pickImage(isCover: false),
            onRemove: () => setState(() => _logoUrl = ''),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfoCard() {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _EditSectionTitle(
            icon: AppIcons.buildingfull,
            title: 'Dados principais',
          ),
          const SizedBox(height: 14),
          _EditField(
            controller: _nameController,
            label: 'Nome da empresa',
            icon: AppIcons.buildingfull,
          ),
          const SizedBox(height: 12),
          _CategoryField(
            value: _category,
            onTap: _selectCategory,
          ),
          const SizedBox(height: 12),
          _EditField(
            controller: _sloganController,
            label: 'Slogan',
            icon: AppIcons.chat,
          ),
        ],
      ),
    );
  }

  Widget _buildExtraInfoCard() {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _EditSectionTitle(
            icon: AppIcons.infofull,
            title: 'Informações dos cards',
          ),
          const SizedBox(height: 14),
          _EditField(
            controller: _companyTypeController,
            label: 'Tipo da empresa',
            icon: AppIcons.buildingbriefcase,
          ),
          const SizedBox(height: 12),
          _EditField(
            controller: _sectorController,
            label: 'Setor',
            icon: AppIcons.industry,
          ),
          const SizedBox(height: 12),
          _EditField(
            controller: _websiteController,
            label: 'Site oficial',
            icon: AppIcons.links,
          ),
          const SizedBox(height: 12),
          _EditField(
            controller: _descriptionController,
            label: 'Descrição',
            icon: AppIcons.resume,
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            value: _isHiring,
            onChanged: (value) => setState(() => _isHiring = value),
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Empresa contratando no momento',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _EditField(
            controller: _employeesController,
            label: 'Quantidade de colaboradores',
            icon: AppIcons.hashtag,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _EditField(
            controller: _companySizeController,
            label: 'Porte empresarial',
            icon: AppIcons.skyscraper,
          ),
        ],
      ),
    );
  }
}

class _EditSectionTitle extends StatelessWidget {
  final String icon;
  final String title;

  const _EditSectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageActionTile extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _ImageActionTile({
    required this.title,
    required this.imageUrl,
    required this.isLoading,
    required this.onTap,
    required this.onRemove,
  });

  bool get _hasImage => imageUrl.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardTertiary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 54,
              height: 54,
              color: colors.cardSecondary,
              child: _hasImage
                  ? Image.network(imageUrl.trim(), fit: BoxFit.cover)
                  : Center(
                      child: SvgPicture.asset(
                        AppIcons.image,
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          if (_hasImage)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, color: Colors.white),
            ),
          TextButton(
            onPressed: isLoading ? null : onTap,
            child: Text(isLoading ? 'Enviando...' : 'Alterar'),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String icon;
  final int maxLines;
  final TextInputType? keyboardType;

  const _EditField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: SvgPicture.asset(
            icon,
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
        filled: true,
        fillColor: colors.cardTertiary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _CategoryField({
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final safeValue = value.trim().isNotEmpty ? value.trim() : 'Selecionar área';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: colors.cardTertiary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              getCompanyCategoryIcon(value),
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                safeValue,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white.withOpacity(0.75),
            ),
          ],
        ),
      ),
    );
  }
}
