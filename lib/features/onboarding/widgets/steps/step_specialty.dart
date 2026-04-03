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

  // ===================================================
  // INIT (🔥 REHIDRATA DO PROVIDER)
  // ===================================================
  @override
  void initState() {
    super.initState();

    final data = ref.read(onboardingProvider);

    _selected.addAll(data.specialties);
  }

  // ===================================================
  // ICONS
  // ===================================================
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
        return AppIcons.briefcase;
      case 'Data Analyst':
        return AppIcons.data;
      case 'Mobile Developer':
        return AppIcons.laptop;
      case 'DevOps Engineer':
        return AppIcons.devops;
      default:
        return AppIcons.briefcase;
    }
  }

  // ===================================================
  // SELECT
  // ===================================================
  void _toggleSelection(String option) {
    setState(() {
      if (_selected.contains(option)) {
        _selected.remove(option);
      } else {

        if (_selected.length >= 3) {
          widget.onJobuMessageChange(
            'Ei 😅 você só pode escolher \naté 3 especialidades.',
          );

          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              widget.onJobuMessageChange(null);
            }
          });

          return;
        }

        _selected.add(option);
      }
    });

    // 🔥 SALVA NO PROVIDER
    ref.read(onboardingProvider.notifier).setSpecialties(
      List.from(_selected),
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

                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.briefcase,
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Especialidade (até 3)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Column(
                      children: _options.map((option) {
                        final isSelected = _selected.contains(option);

                        return GestureDetector(
                          onTap: () => _toggleSelection(option),

                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.white24,
                                width: 1.2,
                              ),
                            ),

                            child: Row(
                              children: [

                                SvgPicture.asset(
                                  _getIcon(option),
                                  width: 18,
                                  height: 18,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : AppTheme.textSecondary,
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : AppTheme.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),

                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isValid
                            ? () {
                                widget.onNext();
                              }
                            : null,
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