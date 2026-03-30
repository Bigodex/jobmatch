// =======================================================
// EDIT LINKS SCREEN
// -------------------------------------------------------
// Edição de links sociais do usuário (VERSÃO BLINDADA)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jobmatch/core/constants/app_theme.dart';

import 'package:jobmatch/features/profile/models/social_link_model.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';
import 'package:jobmatch/features/profile/screens/success_screen.dart';

import 'package:jobmatch/shared/widgets/app_header.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class EditLinksScreen extends ConsumerStatefulWidget {
  final List<SocialLinkModel> links;

  const EditLinksScreen({
    super.key,
    required this.links,
  });

  @override
  ConsumerState<EditLinksScreen> createState() =>
      _EditLinksScreenState();
}

class _EditLinksScreenState
    extends ConsumerState<EditLinksScreen> {

  // =======================================================
  // CONTROLLERS
  // =======================================================
  late List<TextEditingController> urls;
  late List<String> selectedPlatforms;

  final List<String> platforms = [
    'GitHub',
    'LinkedIn',
    'Behance',
    'Instagram',
    'Outro',
  ].toSet().toList(); // 🔥 garante sem duplicados

  // =======================================================
  // NORMALIZAÇÃO
  // =======================================================
  String normalizePlatform(String label) {
    switch (label.toLowerCase()) {
      case 'github':
        return 'GitHub';
      case 'linkedin':
        return 'LinkedIn';
      case 'behance':
        return 'Behance';
      case 'instagram':
        return 'Instagram';
      default:
        return 'Outro';
    }
  }

  @override
  void initState() {
    super.initState();

    urls = widget.links
        .map((e) => TextEditingController(text: e.url))
        .toList();

    selectedPlatforms = widget.links
        .map((e) => normalizePlatform(e.label))
        .toList();
  }

  // =======================================================
  // ADD LINK
  // =======================================================
  void _addLink() {
    setState(() {
      urls.add(TextEditingController());
      selectedPlatforms.add('Outro'); // 🔥 seguro
    });
  }

  // =======================================================
  // REMOVE LINK
  // =======================================================
  void _removeLink(int index) {
    setState(() {
      urls.removeAt(index);
      selectedPlatforms.removeAt(index);
    });
  }

  // =======================================================
  // SAVE
  // =======================================================
  Future<void> _save() async {
    final updated = List.generate(
      urls.length,
      (index) => SocialLinkModel(
        label: selectedPlatforms[index],
        url: urls[index].text,
      ),
    );

    await ref.read(profileProvider.notifier)
        .updateLinks(updated);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const SuccessScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      body: Column(
        children: [
          // ===================================================
          // HEADER
          // ===================================================
          const SafeArea(
            bottom: false,
            child: AppHeader(
              title: 'Editar',
              showBackButton: true,
            ),
          ),

          // ===================================================
          // CONTENT
          // ===================================================
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: AppSectionCard(
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
                            'Links',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Divider(
                            color: theme.dividerColor.withOpacity(0.2),
                          ),

                          const SizedBox(height: 12),

                          // ===================================================
                          // LISTA
                          // ===================================================
                          Column(
                            children: List.generate(urls.length, (index) {
                              return Column(
                                children: [
                                  _linkItem(index),

                                  if (index != urls.length - 1)
                                    Divider(
                                      height: 24,
                                      color: theme.dividerColor
                                          .withOpacity(0.2),
                                    ),
                                ],
                              );
                            }),
                          ),

                          const SizedBox(height: 16),

                          // ===================================================
                          // ADD BUTTON
                          // ===================================================
                          TextButton.icon(
                            onPressed: _addLink,
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar link'),
                          ),

                          const SizedBox(height: 20),

                          // ===================================================
                          // SAVE BUTTON
                          // ===================================================
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _save,
                              child: const Text('Salvar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // ITEM LINK
  // =======================================================
  Widget _linkItem(int index) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Link',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            IconButton(
              onPressed: () => _removeLink(index),
              icon: const Icon(Icons.delete, size: 18),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ===================================================
        // DROPDOWN (BLINDADO)
        // ===================================================
        DropdownButtonFormField<String>(
          value: platforms.contains(selectedPlatforms[index])
              ? selectedPlatforms[index]
              : null,
          items: platforms.map((platform) {
            return DropdownMenuItem<String>(
              value: platform,
              child: Text(platform),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedPlatforms[index] = value;
            });
          },
          decoration: _inputDecoration(theme, 'Selecione o tipo'),
        ),

        const SizedBox(height: 10),

        // ===================================================
        // INPUT URL
        // ===================================================
        TextField(
          controller: urls[index],
          decoration: _inputDecoration(
            theme,
            'https://seulink.com',
          ),
        ),
      ],
    );
  }

  // =======================================================
  // INPUT STYLE
  // =======================================================
  InputDecoration _inputDecoration(
    ThemeData theme,
    String hint,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13),
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 1.5,
        ),
      ),
    );
  }
}