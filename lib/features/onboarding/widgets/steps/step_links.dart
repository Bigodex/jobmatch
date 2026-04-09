// =======================================================
// STEP LINKS
// -------------------------------------------------------
// Links sociais/profissionais no onboarding
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';
import 'package:jobmatch/features/profile/models/social_link_model.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class StepLinks extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Function(String?) onJobuMessageChange;

  const StepLinks({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.onJobuMessageChange,
  });

  @override
  ConsumerState<StepLinks> createState() => _StepLinksState();
}

class _StepLinksState extends ConsumerState<StepLinks> {
  late List<SocialLinkModel> _items;

  @override
  void initState() {
    super.initState();
    final onboarding = ref.read(onboardingProvider);
    _items = List<SocialLinkModel>.from(onboarding.links);
  }

  void _showJobuMessage(String message) {
    widget.onJobuMessageChange(message);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onJobuMessageChange(null);
      }
    });
  }

  void _sync() {
    ref.read(onboardingProvider.notifier).setLinks(_items);
  }

  bool _isValidUrl(String value) {
    final text = value.trim().toLowerCase();
    return text.startsWith('http://') || text.startsWith('https://');
  }

  Future<void> _openAddDialog() async {
    final labelController = TextEditingController();
    final urlController = TextEditingController();

    final result = await showDialog<SocialLinkModel>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: const Text('Adicionar link'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    hintText: 'Nome do link (Ex: LinkedIn, GitHub)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    hintText: 'https://...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final label = labelController.text.trim();
                final url = urlController.text.trim();

                if (label.isEmpty) {
                  Navigator.pop(context);
                  _showJobuMessage('Preencha o nome do link.');
                  return;
                }

                if (url.isEmpty) {
                  Navigator.pop(context);
                  _showJobuMessage('Preencha a URL do link.');
                  return;
                }

                if (!_isValidUrl(url)) {
                  Navigator.pop(context);
                  _showJobuMessage('O link precisa começar com http:// ou https://');
                  return;
                }

                Navigator.pop(
                  context,
                  SocialLinkModel(
                    label: label,
                    url: url,
                  ),
                );
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _items.add(result);
      });
      _sync();
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _sync();
  }

  void _handleContinue() {
    widget.onJobuMessageChange(null);
    _sync();
    widget.onNext();
  }

  void _handleSkip() {
    widget.onJobuMessageChange(null);
    widget.onSkip();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          AppSectionCard(
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Adicione links importantes agora ou pule e complete depois.',
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openAddDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar link'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (_items.isEmpty)
                      Text(
                        'Nenhum link adicionado ainda.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.60),
                        ),
                      )
                    else
                      Column(
                        children: List.generate(_items.length, (index) {
                          final item = _items[index];

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.label,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.url,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.75),
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _removeItem(index),
                                  child: const Icon(Icons.delete, size: 18),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _handleSkip,
                            child: const Text('Pular'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _handleContinue,
                            child: const Text('Continuar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}