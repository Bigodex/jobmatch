// =======================================================
// LOGIN SCREEN (COM APP ICONS + VOLTAR)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

// =======================================================
// CORE
// =======================================================
import 'package:jobmatch/core/constants/app_icons.dart';

// =======================================================
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final authState = ref.watch(authControllerProvider);

    // ===================================================
    // LISTENER
    // ===================================================
    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        },
        data: (_) {
          context.go('/home');
        },
      );
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [

                // ===================================================
                // BACK BUTTON (GO ROUTER)
                // ===================================================
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go('/welcome'),
                    icon: Icon(
                      Icons.arrow_back,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),

                const Spacer(),

                Stack(
                  alignment: Alignment.center,
                  children: [

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

                    SvgPicture.asset(
                      'assets/images/jobu_desk.svg',
                      height: 180,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  'JobMatch',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                // ===================================================
                // INPUT USER / EMAIL
                // ===================================================
                _input(
                  context,
                  iconPath: AppIcons.user,
                  hint: 'Digite seu nome de usuário ou email...',
                  controller: email,
                ),

                const SizedBox(height: 12),

                // ===================================================
                // INPUT SENHA
                // ===================================================
                _input(
                  context,
                  iconPath: AppIcons.lock,
                  hint: 'Digite sua senha...',
                  controller: password,
                  isPassword: true,
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Esqueci minha senha!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ===================================================
                // BOTÃO ENTRAR
                // ===================================================
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            ref
                                .read(authControllerProvider.notifier)
                                .login(
                                  email.text.trim(),
                                  password.text.trim(),
                                );
                          },
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Acessar'),
                  ),
                ),

                const SizedBox(height: 16),

                _socialButton(
                  context,
                  icon: Icons.g_mobiledata,
                  text: 'Entrar com Google',
                ),

                const SizedBox(height: 10),

                _socialButton(
                  context,
                  icon: Icons.apple,
                  text: 'Entrar com Apple',
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Não tem conta? ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/onboarding'),
                      child: Text(
                        'Criar conta',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =======================================================
  // INPUT CUSTOM (SVG ICONS)
  // =======================================================
  Widget _input(
    BuildContext context, {
    required String iconPath,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [

          SvgPicture.asset(
            iconPath,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.onSurface.withOpacity(0.6),
              BlendMode.srcIn,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword ? _obscure : false,
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),

          if (isPassword)
            GestureDetector(
              onTap: () {
                setState(() {
                  _obscure = !_obscure;
                });
              },
              child: SvgPicture.asset(
                AppIcons.eye,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.onSurface.withOpacity(0.6),
                  BlendMode.srcIn,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =======================================================
  // SOCIAL BUTTON
  // =======================================================
  Widget _socialButton(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: theme.colorScheme.onSurface),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}