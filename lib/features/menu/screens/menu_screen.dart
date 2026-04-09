// =======================================================
// MENU SCREEN
// -------------------------------------------------------
// Tela de menu / configurações com logout funcional
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/auth/providers/auth_provider.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).logout();

      if (!mounted) return;
      context.go('/welcome');
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível sair da conta.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;
    final profileState = ref.watch(profileProvider);

    String name = 'Configurações da conta';
    String subtitle =
        'Email · Senha · Número de telefone · Privacidade da conta...';
    String avatarUrl = '';

    profileState.whenOrNull(
      data: (profile) {
        name = profile.user.name.trim().isEmpty
            ? 'Configurações da conta'
            : profile.user.name;
        avatarUrl = profile.user.avatarUrl;
      },
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Opacity(
                    opacity: 0.05,
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            colors.cardTertiary,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===================================================
                  // HEADER
                  // ===================================================
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(0.18),
                        ),
                        child: Icon(
                          Icons.menu,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Menu',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ===================================================
                  // ACCOUNT CARD
                  // ===================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.cardTertiary.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _AvatarCircle(avatarUrl: avatarUrl),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    subtitle,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withOpacity(0.45),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Divider(
                          color: Colors.white.withOpacity(0.07),
                          height: 1,
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.verified_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Conta Verificada',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _MenuTile(
                    icon: Icons.business_center_outlined,
                    title: 'Pagina empresarial',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),

                  _MenuTile(
                    icon: Icons.bookmark_border,
                    title: 'Salvos',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),

                  _MenuTile(
                    icon: Icons.settings_outlined,
                    title: 'Configurações gerais',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),

                  _MenuTile(
                    icon: Icons.headset_mic_outlined,
                    title: 'Suporte',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),

                  _MenuTile(
                    icon: Icons.logout_rounded,
                    title: _isLoggingOut ? 'Saindo...' : 'Logout',
                    danger: true,
                    trailing: _isLoggingOut
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : null,
                    onTap: _isLoggingOut ? null : _handleLogout,
                  ),

                  const SizedBox(height: 18),

                  // ===================================================
                  // PREMIUM CARD
                  // ===================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF5C50FF),
                          Color(0xFF5B62FF),
                          Color(0xFF5A86FF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5C50FF).withOpacity(0.20),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Premium 🔒',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Transforme sua experiência.\nAssine o Premium e aproveite o melhor!',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.88),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: const [
                            Icon(
                              Icons.more_horiz,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String avatarUrl;

  const _AvatarCircle({
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (avatarUrl.trim().isNotEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.35),
          ),
          image: DecorationImage(
            image: NetworkImage(avatarUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.08),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.25),
        ),
      ),
      child: Icon(
        Icons.person,
        color: Colors.white.withOpacity(0.75),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool danger;
  final Widget? trailing;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: colors.cardTertiary.withOpacity(0.82),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: danger
                    ? Colors.redAccent.withOpacity(0.90)
                    : Colors.white.withOpacity(0.72),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: danger
                        ? Colors.redAccent.withOpacity(0.95)
                        : Colors.white.withOpacity(0.82),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withOpacity(0.55),
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}