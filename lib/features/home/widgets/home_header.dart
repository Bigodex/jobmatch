import 'package:flutter/material.dart';

import '../../../shared/widgets/app_cover.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_user_info.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_section_card.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        children: [

          // COVER + AVATAR
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [

              const AppCover(),

              const Positioned(
                bottom: -45,
                child: AppAvatar(
                  imageUrl: 'https://i.pravatar.cc/150?img=3',
                  size: 90,
                ),
              ),
            ],
          ),

          const SizedBox(height: 50),

          // USER INFO
          const AppUserInfo(
            name: 'Pedro Piola',
            role: 'Desenvolvedor FullStack',
          ),

          const SizedBox(height: 16),

          // BUTTON
          AppPrimaryButton(
            text: 'Ver meu currículo',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}