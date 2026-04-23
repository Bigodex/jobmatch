// =======================================================
// PUBLIC PROFILE SCREEN
// -------------------------------------------------------
// Tela pública do perfil de outro usuário.
// Mesmo esqueleto da ProfileScreen, usando widgets atuais.
// - atualiza ao entrar
// - suporta pull-to-refresh
// - botão de conexão funcional
// - registra visualização de perfil
// - abre conexões públicas do usuário
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/auth/providers/auth_provider.dart';
import 'package:jobmatch/features/network/providers/network_provider.dart';
import 'package:jobmatch/features/network/services/profile_views_service.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';
import 'package:jobmatch/features/profile/providers/public_profile_provider.dart';

import 'package:jobmatch/features/profile/widgets/profile_education.dart';
import 'package:jobmatch/features/profile/widgets/profile_experience.dart';
import 'package:jobmatch/features/profile/widgets/profile_hard_skills.dart';
import 'package:jobmatch/features/profile/widgets/profile_languages.dart';
import 'package:jobmatch/features/profile/widgets/profile_links.dart';
import 'package:jobmatch/features/profile/widgets/profile_soft_skills.dart';
import 'package:jobmatch/features/profile/widgets/profile_screen_skeleton.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

import '../../../shared/widgets/app_header.dart';

import '../widgets/profile_header.dart';
import '../widgets/profile_resume.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<PublicProfileScreen> createState() =>
      _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen> {
  bool _hasRegisteredView = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(publicProfileProvider(widget.userId));
      ref.invalidate(networkConnectionStatusProvider(widget.userId));
    });
  }

  @override
  void didUpdateWidget(covariant PublicProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId) {
      _hasRegisteredView = false;
    }
  }

  Future<void> _refreshPublicProfile() async {
    ref.invalidate(publicProfileProvider(widget.userId));
    ref.invalidate(networkConnectionStatusProvider(widget.userId));

    await Future.wait([
      ref.read(publicProfileProvider(widget.userId).future),
      ref.read(networkConnectionStatusProvider(widget.userId).future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    final profileAsync = ref.watch(publicProfileProvider(widget.userId));
    final myProfileAsync = ref.watch(profileProvider);
    final authUser = ref.watch(authStateProvider).value;

    final connectionStatusAsync = ref.watch(
      networkConnectionStatusProvider(widget.userId),
    );
    final connectionActionState = ref.watch(
      networkConnectionControllerProvider,
    );
    final connectionController = ref.read(
      networkConnectionControllerProvider.notifier,
    );

    const bool previewSkeleton = false;

    final headerTitle = profileAsync.maybeWhen(
      data: (profile) => profile.user.name,
      orElse: () => 'Perfil público',
    );

    final isConnected = connectionStatusAsync.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );

    final isLoadingConnection =
        connectionStatusAsync.isLoading || connectionActionState.isLoading;

    final publicButtonLabel = isLoadingConnection
        ? 'Atualizando...'
        : isConnected
        ? 'Desconectar'
        : 'Conectar';

    final publicButtonColor = isConnected
        ? appColors.cardTertiary
        : theme.colorScheme.primary;

    final publicButtonIcon = SvgPicture.asset(
      isConnected ? AppIcons.group : AppIcons.connections,
      width: 18,
      height: 18,
      colorFilter: ColorFilter.mode(
        isConnected ? Colors.white : Colors.black,
        BlendMode.srcIn,
      ),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: headerTitle, showBackButton: true),
            Expanded(
              child: previewSkeleton
                  ? const ProfileScreenSkeleton()
                  : RefreshIndicator(
                      onRefresh: _refreshPublicProfile,
                      displacement: 24,
                      child: profileAsync.when(
                        data: (profile) {
                          final myProfile = myProfileAsync.maybeWhen(
                            data: (profile) => profile,
                            orElse: () => null,
                          );

                          if (!_hasRegisteredView &&
                              authUser != null &&
                              myProfile != null &&
                              authUser.uid.isNotEmpty &&
                              authUser.uid != widget.userId) {
                            WidgetsBinding.instance.addPostFrameCallback((
                              _,
                            ) async {
                              if (!mounted || _hasRegisteredView) return;

                              _hasRegisteredView = true;

                              await ref
                                  .read(profileViewsServiceProvider)
                                  .registerProfileView(
                                    viewedUserId: widget.userId,
                                    viewerId: authUser.uid,
                                    viewerName: myProfile.user.name,
                                    viewerRole: myProfile.user.role,
                                    viewerCity: myProfile.resume.city ?? '',
                                    viewerAvatarUrl: myProfile.user.avatarUrl,
                                  );
                            });
                          }

                          final sections = <Widget>[];

                          void addSection(Widget child) {
                            if (sections.isNotEmpty) {
                              sections.add(const SizedBox(height: 16));
                            }

                            sections.add(AppSectionCard(child: child));
                          }

                          if (ProfileResume.hasPublicContent(
                            resume: profile.resume,
                            email: profile.user.email,
                          )) {
                            addSection(
                              ProfileResume(
                                resume: profile.resume,
                                email: profile.user.email,
                                isPublic: true,
                              ),
                            );
                          }

                          if (ProfileLanguages.hasPublicContent(
                            languages: profile.languages,
                          )) {
                            addSection(
                              ProfileLanguages(
                                languages: profile.languages,
                                isPublic: true,
                              ),
                            );
                          }

                          if (ProfileSoftSkills.hasPublicContent(
                            skills: profile.softSkills,
                          )) {
                            addSection(
                              ProfileSoftSkills(
                                skills: profile.softSkills,
                                isPublic: true,
                              ),
                            );
                          }

                          if (ProfileHardSkills.hasPublicContent(
                            skills: profile.techSkills,
                          )) {
                            addSection(
                              ProfileHardSkills(
                                skills: profile.techSkills,
                                isPublic: true,
                              ),
                            );
                          }

                          if (ProfileExperience.hasPublicContent(
                            experiences: profile.experiences,
                          )) {
                            addSection(
                              ProfileExperience(
                                experiences: profile.experiences,
                                isPublic: true,
                              ),
                            );
                          }

                          if (ProfileEducation.hasPublicContent(
                            educations: profile.education,
                          )) {
                            addSection(
                              ProfileEducation(
                                educations: profile.education,
                                isPublic: true,
                              ),
                            );
                          }

                          if (ProfileLinks.hasPublicContent(
                            links: profile.links,
                          )) {
                            addSection(
                              ProfileLinks(
                                links: profile.links,
                                isPublic: true,
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            child: Column(
                              children: [
                                ProfileHeader(
                                  user: profile.user,
                                  isPublic: true,
                                  publicButtonLabel: publicButtonLabel,
                                  publicButtonIcon: publicButtonIcon,
                                  publicButtonColor: publicButtonColor,
                                  publicSecondaryStatLabel: 'Chat',
                                  publicSecondaryStatIconPath: AppIcons.chat,
                                  onConnectionsTap: () {
                                    final encodedName = Uri.encodeComponent(
                                      profile.user.name,
                                    );

                                    context.push(
                                      '/network/user/${widget.userId}/public-connections?name=$encodedName'
                                    );
                                  },
                                  onPublicSecondaryTap: () {
                                    context.push(
                                      '/chat/conversation/${widget.userId}',
                                    );
                                  },
                                  onConnect: () {
                                    if (isLoadingConnection) {
                                      return;
                                    }

                                    if (isConnected) {
                                      connectionController.disconnect(
                                        widget.userId,
                                      );
                                      return;
                                    }

                                    connectionController.connect(widget.userId);
                                  },
                                ),
                                if (sections.isNotEmpty)
                                  const SizedBox(height: 16),
                                ...sections,
                                const SizedBox(height: 32),
                              ],
                            ),
                          );
                        },
                        loading: () => SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          child: const ProfileScreenSkeleton(),
                        ),
                        error: (e, _) => SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: Text('Erro ao carregar perfil: $e'),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
