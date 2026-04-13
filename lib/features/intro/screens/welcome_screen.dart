import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: Column(
          children: [

            // ===================================================
            // CONTEÚDO CENTRAL
            // ===================================================
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // 🔥 GLOW + SVG
                  Stack(
                    alignment: Alignment.center,
                    children: [

                      // GLOW BRANCO (SUAVE)
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.white.withOpacity(0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // SVG DO MASCOTE
                      SvgPicture.asset(
                        'assets/images/jobu_desk.svg',
                        height: 180,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ===================================================
                  // TEXTO
                  // ===================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Bem vindo ao '),

                          TextSpan(
                            text: 'JobMatch',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const TextSpan(
                            text: '\nA sua plataforma de empregos!',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===================================================
            // BOTTOM ACTIONS
            // ===================================================
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  Divider(
                    color: theme.dividerColor,
                    thickness: 1,
                  ),

                  const SizedBox(height: 20),

                  // BOTÃO ENTRAR
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: const Text('Entrar'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // BOTÃO CRIAR CONTA
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        context.go('/onboarding');
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: theme.colorScheme.primary.withOpacity(1.0),
                        ),
                        foregroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Criar conta'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}