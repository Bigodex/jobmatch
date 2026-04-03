// =======================================================
// STEP NAME (FINAL COM PERSISTÊNCIA CORRETA)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class StepName extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const StepName({
    super.key,
    required this.onNext,
  });

  @override
  ConsumerState<StepName> createState() => _StepNameState();
}

class _StepNameState extends ConsumerState<StepName> {
  late final TextEditingController name;
  late final TextEditingController lastName;

  bool get isValid =>
      name.text.trim().isNotEmpty &&
      lastName.text.trim().isNotEmpty;

  // ===================================================
  // INIT (🔥 REHIDRATAÇÃO)
  // ===================================================
  @override
  void initState() {
    super.initState();

    final data = ref.read(onboardingProvider);

    name = TextEditingController(text: data.name ?? '');
    lastName = TextEditingController(text: data.lastName ?? '');
  }

  @override
  void dispose() {
    name.dispose();
    lastName.dispose();
    super.dispose();
  }

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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.cardTertiary,
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 12),

                    // ===================================================
                    // NOME
                    // ===================================================
                    _editItem(
                      icon: AppIcons.user,
                      title: 'Nome',
                      child: _inputField(
                        controller: name,
                        hint: 'Digite seu nome',
                        maxLength: 30,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ===================================================
                    // SOBRENOME
                    // ===================================================
                    _editItem(
                      icon: AppIcons.user,
                      title: 'Sobrenome',
                      child: _inputField(
                        controller: lastName,
                        hint: 'Digite seu sobrenome',
                        maxLength: 40,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ===================================================
                    // BOTÃO
                    // ===================================================
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isValid
                            ? () {
                                ref.read(onboardingProvider.notifier).setName(
                                      name.text.trim(),
                                      lastName.text.trim(),
                                    );

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

  // =======================================================
  // INPUT
  // =======================================================
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required int maxLength,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 13),
      onChanged: (_) => setState(() {}),

      decoration: InputDecoration(
        hintText: hint,
        counterText: '${controller.text.length}/$maxLength',
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // =======================================================
  // ITEM
  // =======================================================
  Widget _editItem({
    required String icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(icon, width: 16, height: 16),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: child),
      ],
    );
  }
}