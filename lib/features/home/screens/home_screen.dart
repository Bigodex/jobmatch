// =======================================================
// HOME SCREEN
// -------------------------------------------------------
// Tela principal do app
// =======================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

import '../../../core/constants/app_icons.dart';
import '../../../shared/widgets/app_header.dart';

import '../widgets/home_header.dart';
import '../widgets/home_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ===================================================
    // TROQUE PARA false QUANDO TERMINAR DE VALIDAR O VISUAL
    // ===================================================
    const bool previewSkeleton = false;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ===================================================
            // HEADER FIXO (APP)
            // ===================================================
            const AppHeader(title: 'Início'),

            // ===================================================
            // CONTEÚDO SCROLLÁVEL
            // ===================================================
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===================================================
                    // HOME HEADER
                    // ===================================================
                    const HomeHeader(forceLoading: previewSkeleton),

                    const SizedBox(height: 24),

                    // ===================================================
                    // CARDS
                    // ===================================================
                    AppSectionCard(
                      child: Column(
                        children: [
                          previewSkeleton
                              ? const HomeCardSkeleton(imageSize: 80)
                              : HomeCard(
                                  title: 'Ver vagas',
                                  subtitle:
                                      'Procurar por vagas de empregos e oportunidades',
                                  image: AppIcons.purse,
                                  imageSize: 80,
                                  onTap: () {},
                                ),

                          const SizedBox(height: 12),

                          previewSkeleton
                              ? const HomeCardSkeleton(imageSize: 80)
                              : HomeCard(
                                  title: 'Ver rede',
                                  subtitle:
                                      'Procurar por pessoas, empresas e eventos, para se conectar',
                                  image: AppIcons.jobuShadows,
                                  imageSize: 80,
                                  onTap: () {
                                    // HOME -> abre na aba Explorar
                                    context.push('/network');
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}