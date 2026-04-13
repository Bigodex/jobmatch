// =======================================================
// STEP SPECIALTY (COM PERSISTÊNCIA REAL)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// CORE
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';

// SHARED
import 'package:jobmatch/shared/widgets/app_section_card.dart';
import 'package:jobmatch/shared/widgets/app_validated_selector_field.dart';

class StepSpecialty extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final Function(String?) onJobuMessageChange;

  const StepSpecialty({
    super.key,
    required this.onNext,
    required this.onJobuMessageChange,
  });

  @override
  ConsumerState<StepSpecialty> createState() => _StepSpecialtyState();
}

class _StepSpecialtyState extends ConsumerState<StepSpecialty> {
  final List<String> _selected = [];
  bool _hasSelectionError = false;

  final List<String> _options = [
    'UI/UX Designer',
    'Frontend Developer',
    'Backend Developer',
    'QA Engineer',
    'Product Manager',
    'Data Analyst',
    'Mobile Developer',
    'DevOps Engineer',
  ];

  @override
  void initState() {
    super.initState();

    final data = ref.read(onboardingProvider);
    if (data.specialties.isNotEmpty) {
      _selected.add(data.specialties.first);
    }
  }

  String _getIcon(String option) {
    switch (option) {
      case 'UI/UX Designer':
        return AppIcons.paint;
      case 'Frontend Developer':
        return AppIcons.code;
      case 'Backend Developer':
        return AppIcons.database;
      case 'QA Engineer':
        return AppIcons.shield;
      case 'Product Manager':
        return AppIcons.box;
      case 'Data Analyst':
        return AppIcons.data;
      case 'Mobile Developer':
        return AppIcons.mobile;
      case 'DevOps Engineer':
        return AppIcons.devops;
      default:
        return AppIcons.briefcase;
    }
  }

  void _sync() {
    ref.read(onboardingProvider.notifier).setSpecialties(
          List<String>.from(_selected),
        );
  }

  void _removeSelection(String option) {
    setState(() {
      _selected.remove(option);
    });

    _sync();
  }

  void _continue() {
    final isValid = _selected.isNotEmpty;

    setState(() {
      _hasSelectionError = !isValid;
    });

    if (!isValid) {
      widget.onJobuMessageChange(
        'Selecione sua especialidade para continuar!',
      );
      return;
    }

    widget.onJobuMessageChange(null);
    widget.onNext();
  }

  Future<void> _openSpecialtyModal() async {
    final result = await _showSpecialtySelectionModal(
      title: 'Selecionar especialidade',
      searchHint: 'Buscar especialidade',
      options: _options,
      currentSelected: List<String>.from(_selected),
    );

    if (result == null) return;

    setState(() {
      _selected
        ..clear()
        ..addAll(result);

      if (_selected.isNotEmpty) {
        _hasSelectionError = false;
      }
    });

    widget.onJobuMessageChange(null);
    _sync();
  }

  Future<List<String>?> _showSpecialtySelectionModal({
    required String title,
    required String searchHint,
    required List<String> options,
    required List<String> currentSelected,
  }) async {
    return showDialog<List<String>>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colors = theme.extension<AppColorsExtension>()!;
        final searchController = TextEditingController();
        final tempSelected = List<String>.from(currentSelected);
        List<String> filtered = List<String>.from(options);

        return StatefulBuilder(
          builder: (context, setModalState) {
            void applyFilter(String value) {
              final query = value.trim().toLowerCase();

              setModalState(() {
                if (query.isEmpty) {
                  filtered = List<String>.from(options);
                } else {
                  filtered = options.where((item) {
                    return item.toLowerCase().contains(query);
                  }).toList();
                }
              });
            }

            void toggleOption(String option) {
              setModalState(() {
                if (tempSelected.contains(option)) {
                  tempSelected.remove(option);
                  return;
                }

                tempSelected
                  ..clear()
                  ..add(option);
              });
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 460,
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.74,
                ),
                decoration: BoxDecoration(
                  color: colors.cardTertiary,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.28),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 14, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.of(dialogContext).pop(),
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                      child: TextField(
                        controller: searchController,
                        onChanged: applyFilter,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: searchHint,
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Colors.white54,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${tempSelected.length}/1 selecionada',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.white.withOpacity(0.06),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Nenhuma especialidade encontrada.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.70),
                                  ),
                                ),
                              ),
                            )
                          : Scrollbar(
                              thumbVisibility: true,
                              radius: const Radius.circular(999),
                              child: ListView.separated(
                                padding: const EdgeInsets.all(14),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final option = filtered[index];
                                  final isSelected =
                                      tempSelected.contains(option);

                                  return InkWell(
                                    onTap: () => toggleOption(option),
                                    borderRadius: BorderRadius.circular(18),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                                .withOpacity(0.12)
                                            : Colors.white.withOpacity(0.035),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                                  .withOpacity(0.50)
                                              : Colors.white.withOpacity(0.06),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? theme.colorScheme.primary
                                                      .withOpacity(0.18)
                                                  : Colors.white
                                                      .withOpacity(0.05),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                _getIcon(option),
                                                width: 18,
                                                height: 18,
                                                color: isSelected
                                                    ? theme.colorScheme.primary
                                                    : Colors.white70,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              option,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            isSelected
                                                ? Icons.check_circle_rounded
                                                : Icons.add_circle_outline_rounded,
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : Colors.white.withOpacity(0.35),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.10),
                                ),
                                foregroundColor: Colors.white70,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop(tempSelected);
                              },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Concluir'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool get _isValid => _selected.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
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

                    // HEADER
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.nodes,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Especialidade',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
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

                    // LABEL DO CAMPO
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.role,
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Selecione Sua Especialidade',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    AppValidatedSelectorField(
                      hint: 'Selecionar especialidade',
                      value: _selected.isEmpty ? null : _selected.first,
                      selectedIcon:
                          _selected.isEmpty ? null : _getIcon(_selected.first),
                      hasError: _hasSelectionError,
                      isValid: _isValid,
                      onTap: _openSpecialtyModal,
                    ),

                    if (_selected.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selected.map((option) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.24),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  _getIcon(option),
                                  width: 14,
                                  height: 14,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => _removeSelection(option),
                                  borderRadius: BorderRadius.circular(999),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _continue,
                        child: const Text('Continuar'),
                      ),
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