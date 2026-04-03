// =======================================================
// STEP BIRTHDATE (FINAL FUNCIONAL - SEM ERRO RIVERPOD)
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

class StepBirthDate extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const StepBirthDate({
    super.key,
    required this.onNext,
  });

  @override
  ConsumerState<StepBirthDate> createState() => _StepBirthDateState();
}

class _StepBirthDateState extends ConsumerState<StepBirthDate> {

  DateTime? _selectedDate;

  bool get _isValid => _selectedDate != null;

  // ===================================================
  // INIT (SEM MEXER NO PROVIDER)
  // ===================================================
  @override
  void initState() {
    super.initState();

    final data = ref.read(onboardingProvider);

    // 🔥 rehidrata se já existir, senão usa default visual
    _selectedDate = data.birthDate ?? DateTime(2000, 1, 1);
  }

  // ===================================================
  // DATE PICKER
  // ===================================================
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });

      // 🔥 SALVA AQUI (CORRETO)
      ref.read(onboardingProvider.notifier).setBirthDate(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;

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
                        SvgPicture.asset(AppIcons.calendar, width: 16, height: 16),
                        const SizedBox(width: 10),
                        const Text(
                          'Data de nascimento',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'Selecionar data'
                              : _formatDate(_selectedDate!),
                          style: TextStyle(
                            fontSize: 13,
                            color: _selectedDate == null
                                ? Colors.white54
                                : Colors.white,
                          ),
                        ),
                      ),
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