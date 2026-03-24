// =======================================================
// HOME SCREEN
// -------------------------------------------------------
// Tela principal do app
// =======================================================

import 'package:flutter/material.dart';
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
                      const HomeHeader(),

                      const SizedBox(height: 24),

                      // ===================================================
                      // CARDS (GRUDADOS NO BOTTOM)
                      // ===================================================
                      AppSectionCard(
                        child: Column(
                          children: [
                            HomeCard(
                              title: 'Ver vagas',
                              subtitle:
                                  'Procurar por vagas de empregos e oportunidades',
                              image: AppIcons.purse,
                              imageSize: 80,
                              onTap: () {},
                            ),

                            const SizedBox(height: 12),

                            HomeCard(
                              title: 'Ver rede',
                              subtitle:
                                  'Procurar por pessoas, empresas e eventos, para se conectar',
                              image: AppIcons.jobuShadows,
                              imageSize: 80,
                              onTap: () {},
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