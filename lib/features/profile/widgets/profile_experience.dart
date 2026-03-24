// =======================================================
// PROFILE EXPERIENCE
// -------------------------------------------------------
// Card de experiências profissionais
//
// Estrutura:
// - Header
// - Lista de experiências
// - Timeline vertical
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

class ProfileExperience extends StatelessWidget {
  const ProfileExperience({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Padding(
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

            // ===================================================
            // HEADER
            // ===================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Experiência',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 18),
                ),
              ],
            ),

            const Divider(),

            const SizedBox(height: 8),

            // ===================================================
            // EXPERIÊNCIAS
            // ===================================================
            const _ExperienceItem(
              company: 'Agende tecnologias LTDA',
              period: '1 ano - Até o momento',
              role: 'Analista',
              description:
                  'Analista com experiência em análise de dados e otimização de processos. Habilidade em ferramentas como [principais ferramentas] e foco em soluções estratégicas que gerem impacto positivo.',
              logoColor: Colors.grey,
              isFirst: true,
            ),

            const SizedBox(height: 24),

            const _ExperienceItem(
              company: 'IDS - SOFTWARE',
              period: '12/02/2024 - 12/05/2024 - 7 Meses',
              role: 'UI/UX Designer',
              description:
                  'Aprendi a criar interfaces intuitivas, protótipos interativos e aplicar testes de usabilidade. Desenvolvi habilidades em ferramentas como Figma e aprimorei a capacidade de resolver problemas com foco no usuário.',
              logoColor: Colors.blue,
              isFirst: false,
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// EXPERIENCE ITEM
// =======================================================

class _ExperienceItem extends StatelessWidget {
  final String company;
  final String period;
  final String role;
  final String description;
  final Color logoColor;
  final bool isFirst;

  const _ExperienceItem({
    required this.company,
    required this.period,
    required this.role,
    required this.description,
    required this.logoColor,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ===================================================
        // COLUNA ESQUERDA (LOGO + TIMELINE)
        // ===================================================
        Column(
          children: [

            // LOGO
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: logoColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            const SizedBox(height: 8),

            // LINHA
            Container(
              width: 2,
              height: 140,
              color: Colors.white
            ),
          ],
        ),

        const SizedBox(width: 12),

        // ===================================================
        // CONTEÚDO
        // ===================================================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // EMPRESA
              Text(
                company,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 2),

              // PERÍODO
              Text(
                period,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 12),

              // CARGO
              Text(
                role,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              // DESCRIÇÃO
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}