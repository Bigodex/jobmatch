// =======================================================
// STEP CHECKLIST
// -------------------------------------------------------
// Tela final do onboarding com resumo do que foi concluído
// e do que ainda está pendente antes de criar a conta
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class StepChecklist extends ConsumerWidget {
  final VoidCallback onCreateAccount;

  const StepChecklist({
    super.key,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;
    final onboarding = ref.watch(onboardingProvider);

    final requiredItems = [
      _ChecklistItemData(
        title: 'Nome completo',
        subtitle: onboarding.fullName.isNotEmpty
            ? onboarding.fullName
            : 'Não preenchido',
        completed:
            (onboarding.name?.trim().isNotEmpty ?? false) &&
            (onboarding.lastName?.trim().isNotEmpty ?? false),
      ),
      _ChecklistItemData(
        title: 'Data de nascimento',
        subtitle: onboarding.birthDate != null
            ? _formatDate(onboarding.birthDate!)
            : 'Não preenchido',
        completed: onboarding.birthDate != null,
      ),
      _ChecklistItemData(
        title: 'Especialidades',
        subtitle: onboarding.specialties.isNotEmpty
            ? onboarding.specialties.join(', ')
            : 'Não preenchido',
        completed: onboarding.specialties.isNotEmpty,
      ),
      _ChecklistItemData(
        title: 'Idiomas',
        subtitle: onboarding.languages.isNotEmpty
            ? onboarding.languages.map((e) => e.name).join(', ')
            : 'Não preenchido',
        completed: onboarding.languages.isNotEmpty,
      ),
      _ChecklistItemData(
        title: 'Conta',
        subtitle: onboarding.email?.trim().isNotEmpty == true
            ? onboarding.email!
            : 'Não preenchido',
        completed:
            (onboarding.email?.trim().isNotEmpty ?? false) &&
            (onboarding.password?.trim().isNotEmpty ?? false),
      ),
    ];

    final optionalItems = [
      _ChecklistItemData(
        title: 'Resumo',
        subtitle: onboarding.resumeDescription?.trim().isNotEmpty == true
            ? 'Preenchido'
            : 'Pendente',
        completed: onboarding.resumeDescription?.trim().isNotEmpty == true,
      ),
      _ChecklistItemData(
        title: 'Soft skills',
        subtitle: onboarding.softSkills.isNotEmpty
            ? '${onboarding.softSkills.length} adicionada(s)'
            : 'Pendente',
        completed: onboarding.softSkills.isNotEmpty,
      ),
      _ChecklistItemData(
        title: 'Hard skills',
        subtitle: onboarding.techSkills.isNotEmpty
            ? '${onboarding.techSkills.length} adicionada(s)'
            : 'Pendente',
        completed: onboarding.techSkills.isNotEmpty,
      ),
      _ChecklistItemData(
        title: 'Experiência',
        subtitle: onboarding.experiences.isNotEmpty
            ? '${onboarding.experiences.length} adicionada(s)'
            : 'Pendente',
        completed: onboarding.experiences.isNotEmpty,
      ),
      _ChecklistItemData(
        title: 'Formação',
        subtitle: onboarding.education.isNotEmpty
            ? '${onboarding.education.length} adicionada(s)'
            : 'Pendente',
        completed: onboarding.education.isNotEmpty,
      ),
      _ChecklistItemData(
        title: 'Links',
        subtitle: onboarding.links.isNotEmpty
            ? '${onboarding.links.length} adicionado(s)'
            : 'Pendente',
        completed: onboarding.links.isNotEmpty,
      ),
    ];

    final pendingOptionalItems =
        optionalItems.where((item) => !item.completed).toList();

    final completedOptionalItems =
        optionalItems.where((item) => item.completed).toList();

    final allRequiredCompleted = requiredItems.every((item) => item.completed);

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
                    const Text(
                      'Revisão do cadastro',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Seus dados obrigatórios já estão prontos. Você pode criar sua conta agora, e depois completar o que ainda estiver pendente no perfil.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _sectionTitle(
                      context,
                      'Obrigatórios concluídos',
                    ),

                    const SizedBox(height: 12),

                    ...requiredItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ChecklistTile(item: item),
                      ),
                    ),

                    if (completedOptionalItems.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _sectionTitle(
                        context,
                        'Opcionais concluídos',
                      ),
                      const SizedBox(height: 12),
                      ...completedOptionalItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ChecklistTile(item: item),
                        ),
                      ),
                    ],

                    if (pendingOptionalItems.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _sectionTitle(
                        context,
                        'Pendentes',
                      ),
                      const SizedBox(height: 12),
                      ...pendingOptionalItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ChecklistTile(item: item),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: allRequiredCompleted ? onCreateAccount : null,
                        child: const Text('Criar conta'),
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

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _ChecklistItemData {
  final String title;
  final String subtitle;
  final bool completed;

  const _ChecklistItemData({
    required this.title,
    required this.subtitle,
    required this.completed,
  });
}

class _ChecklistTile extends StatelessWidget {
  final _ChecklistItemData item;

  const _ChecklistTile({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.completed
              ? theme.colorScheme.primary.withOpacity(0.35)
              : Colors.white24,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.completed ? Icons.check_circle : Icons.schedule,
            size: 18,
            color: item.completed
                ? theme.colorScheme.primary
                : Colors.white54,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: item.completed
                        ? Colors.white
                        : Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.white.withOpacity(0.68),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}