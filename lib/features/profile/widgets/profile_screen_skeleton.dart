// =======================================================
// PROFILE SCREEN SKELETON
// -------------------------------------------------------
// Skeleton geral da tela de profile
// - sem precisar adaptar cada widget individual agora
// - reutiliza AppSkeleton do shared
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';
import 'package:jobmatch/shared/widgets/app_skeleton.dart';

class ProfileScreenSkeleton extends StatelessWidget {
  const ProfileScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: const [
          _ProfileHeaderSkeleton(),
          SizedBox(height: 16),
          _ProfileResumeSkeleton(),
          SizedBox(height: 16),
          _ProfileLanguagesSkeleton(),
          SizedBox(height: 16),
          _ProfileSoftSkillsSkeleton(),
          SizedBox(height: 16),
          _ProfileHardSkillsSkeleton(),
          SizedBox(height: 16),
          _ProfileExperienceSkeleton(),
          SizedBox(height: 16),
          _ProfileEducationSkeleton(),
          SizedBox(height: 16),
          _ProfileLinksSkeleton(),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

// =======================================================
// PROFILE HEADER SKELETON
// =======================================================

class _ProfileHeaderSkeleton extends StatelessWidget {
  const _ProfileHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        children: [
          SizedBox(
            height: 185,
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: const [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppSkeleton(
                    width: double.infinity,
                    height: 140,
                    borderRadius: 16,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: AppSkeleton(
                    width: 90,
                    height: 90,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const AppSkeleton(
            width: 170,
            height: 20,
            borderRadius: 8,
          ),
          const SizedBox(height: 10),
          const AppSkeleton(
            width: 130,
            height: 16,
            borderRadius: 8,
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(child: _StatSkeleton()),
              SizedBox(width: 12),
              Expanded(child: _StatSkeleton()),
            ],
          ),
          const SizedBox(height: 16),
          const AppSkeleton(
            width: double.infinity,
            height: 46,
            borderRadius: 14,
          ),
        ],
      ),
    );
  }
}

class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          AppSkeleton(
            width: 18,
            height: 18,
            borderRadius: 6,
          ),
          SizedBox(width: 8),
          AppSkeleton(
            width: 32,
            height: 14,
            borderRadius: 6,
          ),
        ],
      ),
    );
  }
}

// =======================================================
// SECTION SHELL
// =======================================================

class _SectionShell extends StatelessWidget {
  final double titleWidth;
  final Widget child;

  const _SectionShell({
    required this.titleWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return AppSectionCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.cardTertiary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const AppSkeleton(
                        width: 18,
                        height: 18,
                        borderRadius: 6,
                      ),
                      const SizedBox(width: 8),
                      AppSkeleton(
                        width: titleWidth,
                        height: 16,
                        borderRadius: 8,
                      ),
                    ],
                  ),
                  const AppSkeleton(
                    width: 18,
                    height: 18,
                    borderRadius: 6,
                  ),
                ],
              ),
              Divider(color: theme.dividerColor.withOpacity(0.2)),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================
// RESUME SKELETON
// =======================================================

class _ProfileResumeSkeleton extends StatelessWidget {
  const _ProfileResumeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _SectionShell(
      titleWidth: 130,
      child: Column(
        children: [
          _ResumeInfoSkeleton(),
          SizedBox(height: 12),
          _ResumeInfoSkeleton(),
          SizedBox(height: 12),
          _ResumeInfoSkeleton(),
          SizedBox(height: 12),
          _ResumeInfoSkeleton(),
          SizedBox(height: 12),
          _ResumeDescriptionSkeleton(),
        ],
      ),
    );
  }
}

class _ResumeInfoSkeleton extends StatelessWidget {
  const _ResumeInfoSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        AppSkeleton(
          width: 18,
          height: 18,
          borderRadius: 6,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(
                width: 80,
                height: 12,
                borderRadius: 6,
              ),
              SizedBox(height: 6),
              AppSkeleton(
                width: 170,
                height: 12,
                borderRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResumeDescriptionSkeleton extends StatelessWidget {
  const _ResumeDescriptionSkeleton();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 18,
            child: Column(
              children: [
                const AppSkeleton(
                  width: 18,
                  height: 18,
                  borderRadius: 6,
                ),
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.only(top: 8),
                    color: Colors.white24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(
                  width: 100,
                  height: 12,
                  borderRadius: 6,
                ),
                SizedBox(height: 6),
                AppSkeleton(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 6,
                ),
                SizedBox(height: 6),
                AppSkeleton(
                  width: 220,
                  height: 12,
                  borderRadius: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// LANGUAGES SKELETON
// =======================================================

class _ProfileLanguagesSkeleton extends StatelessWidget {
  const _ProfileLanguagesSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _SectionShell(
      titleWidth: 70,
      child: Column(
        children: [
          _LanguageItemSkeleton(),
          SizedBox(height: 18),
          _LanguageItemSkeleton(),
          SizedBox(height: 18),
          _LanguageItemSkeleton(),
        ],
      ),
    );
  }
}

class _LanguageItemSkeleton extends StatelessWidget {
  const _LanguageItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        AppSkeleton(
          width: 30,
          height: 24,
          borderRadius: 8,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(
                width: 90,
                height: 14,
                borderRadius: 6,
              ),
              SizedBox(height: 6),
              AppSkeleton(
                width: 70,
                height: 12,
                borderRadius: 6,
              ),
            ],
          ),
        ),
        AppSkeleton(
          width: 34,
          height: 12,
          borderRadius: 6,
        ),
      ],
    );
  }
}

// =======================================================
// SOFT SKILLS SKELETON
// =======================================================

class _ProfileSoftSkillsSkeleton extends StatelessWidget {
  const _ProfileSoftSkillsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _SectionShell(
      titleWidth: 180,
      child: Column(
        children: [
          _SoftSkillItemSkeleton(),
          SizedBox(height: 20),
          _SoftSkillItemSkeleton(),
        ],
      ),
    );
  }
}

class _SoftSkillItemSkeleton extends StatelessWidget {
  const _SoftSkillItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        AppSkeleton(
          width: 18,
          height: 18,
          borderRadius: 6,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(
                width: 140,
                height: 14,
                borderRadius: 6,
              ),
              SizedBox(height: 8),
              AppSkeleton(
                width: double.infinity,
                height: 12,
                borderRadius: 6,
              ),
              SizedBox(height: 6),
              AppSkeleton(
                width: 210,
                height: 12,
                borderRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =======================================================
// HARD SKILLS SKELETON
// =======================================================

class _ProfileHardSkillsSkeleton extends StatelessWidget {
  const _ProfileHardSkillsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _SectionShell(
      titleWidth: 150,
      child: Column(
        children: [
          _HardSkillItemSkeleton(),
          SizedBox(height: 20),
          _HardSkillItemSkeleton(),
        ],
      ),
    );
  }
}

class _HardSkillItemSkeleton extends StatelessWidget {
  const _HardSkillItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        AppSkeleton(
          width: 18,
          height: 18,
          borderRadius: 6,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(
                width: 120,
                height: 14,
                borderRadius: 6,
              ),
              SizedBox(height: 6),
              AppSkeleton(
                width: 90,
                height: 12,
                borderRadius: 6,
              ),
              SizedBox(height: 10),
              AppSkeleton(
                width: double.infinity,
                height: 4,
                borderRadius: 6,
              ),
              SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppSkeleton(
                    width: 62,
                    height: 28,
                    borderRadius: 10,
                  ),
                  AppSkeleton(
                    width: 74,
                    height: 28,
                    borderRadius: 10,
                  ),
                  AppSkeleton(
                    width: 58,
                    height: 28,
                    borderRadius: 10,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =======================================================
// EXPERIENCE SKELETON
// =======================================================

class _ProfileExperienceSkeleton extends StatelessWidget {
  const _ProfileExperienceSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _SectionShell(
      titleWidth: 95,
      child: Column(
        children: [
          _TimelineItemSkeleton(showLine: true),
          SizedBox(height: 24),
          _TimelineItemSkeleton(showLine: false),
        ],
      ),
    );
  }
}

// =======================================================
// EDUCATION SKELETON
// =======================================================

class _ProfileEducationSkeleton extends StatelessWidget {
  const _ProfileEducationSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _SectionShell(
      titleWidth: 75,
      child: Column(
        children: [
          _TimelineItemSkeleton(showLine: true),
          SizedBox(height: 24),
          _TimelineItemSkeleton(showLine: false),
        ],
      ),
    );
  }
}

class _TimelineItemSkeleton extends StatelessWidget {
  final bool showLine;

  const _TimelineItemSkeleton({
    required this.showLine,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                const AppSkeleton(
                  width: 36,
                  height: 36,
                  borderRadius: 8,
                ),
                if (showLine) ...[
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.white24,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(
                  width: 130,
                  height: 14,
                  borderRadius: 6,
                ),
                SizedBox(height: 6),
                AppSkeleton(
                  width: 180,
                  height: 12,
                  borderRadius: 6,
                ),
                SizedBox(height: 14),
                AppSkeleton(
                  width: 150,
                  height: 14,
                  borderRadius: 6,
                ),
                SizedBox(height: 8),
                AppSkeleton(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 6,
                ),
                SizedBox(height: 6),
                AppSkeleton(
                  width: 220,
                  height: 12,
                  borderRadius: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// LINKS SKELETON
// =======================================================

class _ProfileLinksSkeleton extends StatelessWidget {
  const _ProfileLinksSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _SectionShell(
      titleWidth: 50,
      child: Column(
        children: [
          _LinkItemSkeleton(),
          SizedBox(height: 18),
          _LinkItemSkeleton(),
          SizedBox(height: 14),
          AppSkeleton(
            width: double.infinity,
            height: 52,
            borderRadius: 14,
          ),
        ],
      ),
    );
  }
}

class _LinkItemSkeleton extends StatelessWidget {
  const _LinkItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        AppSkeleton(
          width: 18,
          height: 18,
          borderRadius: 6,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(
                width: 110,
                height: 14,
                borderRadius: 6,
              ),
              SizedBox(height: 6),
              AppSkeleton(
                width: 200,
                height: 12,
                borderRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}