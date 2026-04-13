// =======================================================
// STEP LINKS
// -------------------------------------------------------
// Links no onboarding
// - Mesmo modelo de soft/hard skills e experience
// - Primeiro item fixo, não removível
// - Validações faladas pelo Jobu
// - Validações visuais com shared input
// - URL salva com https:// automático e oculto no input
// - Contadores ocultos
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';
import 'package:jobmatch/features/profile/models/social_link_model.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';
import 'package:jobmatch/shared/widgets/app_validated_input_field.dart';

// =======================================================
// TEXT FORMATTERS
// =======================================================
class LinkTitleInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = _toTitleCase(newValue.text);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }

  static String _toTitleCase(String value) {
    if (value.isEmpty) return value;

    final buffer = StringBuffer();
    bool capitalizeNext = true;

    for (int i = 0; i < value.length; i++) {
      final char = value[i];

      if (capitalizeNext && RegExp(r'[a-zà-ÿA-ZÀ-Ÿ]').hasMatch(char)) {
        buffer.write(char.toUpperCase());
        capitalizeNext = false;
      } else {
        buffer.write(char);
        capitalizeNext = char == ' ' || char == '-' || char == '\'';
      }
    }

    return buffer.toString();
  }
}

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
  static const String _hiddenUrlPrefix = 'https://';

  late List<TextEditingController> labels;
  late List<TextEditingController> urls;

  bool _validationTriggered = false;

  @override
  void initState() {
    super.initState();

    final onboarding = ref.read(onboardingProvider);

    final initialLinks = onboarding.links.isNotEmpty
        ? onboarding.links
        : [
            SocialLinkModel(
              label: '',
              url: '',
            ),
          ];

    labels = initialLinks
        .map(
          (e) => TextEditingController(
            text: LinkTitleInputFormatter._toTitleCase(e.label),
          ),
        )
        .toList();

    urls = initialLinks
        .map(
          (e) => TextEditingController(
            text: _stripUrlPrefix(e.url),
          ),
        )
        .toList();

    for (final controller in labels) {
      controller.addListener(_handleFieldChanged);
    }

    for (final controller in urls) {
      controller.addListener(_handleFieldChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in labels) {
      controller.dispose();
    }

    for (final controller in urls) {
      controller.dispose();
    }

    super.dispose();
  }

  void _handleFieldChanged() {
    widget.onJobuMessageChange(null);
    setState(() {});
    _sync();
  }

  void _showJobuMessage(String message) {
    widget.onJobuMessageChange(message);

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        widget.onJobuMessageChange(null);
      }
    });
  }

  String _stripUrlPrefix(String value) {
    final text = value.trim();

    if (text.toLowerCase().startsWith('https://')) {
      return text.substring(8);
    }

    if (text.toLowerCase().startsWith('http://')) {
      return text.substring(7);
    }

    return text;
  }

  String _buildStoredUrl(String value) {
    final text = _stripUrlPrefix(value).trim();

    if (text.isEmpty) return '';

    return '$_hiddenUrlPrefix$text';
  }

  bool _isValidUrl(String value) {
    final stored = _buildStoredUrl(value).trim().toLowerCase();

    if (stored.isEmpty) return false;
    if (!stored.startsWith('https://')) return false;

    final suffix = stored.substring(_hiddenUrlPrefix.length);

    if (suffix.isEmpty) return false;
    if (!suffix.contains('.')) return false;
    if (suffix.startsWith('.')) return false;
    if (suffix.endsWith('.')) return false;
    if (suffix.contains(' ')) return false;

    return true;
  }

  bool _isLinkCompletelyEmpty(int index) {
    return labels[index].text.trim().isEmpty &&
        urls[index].text.trim().isEmpty;
  }

  bool get _allLinksEmpty {
    return List.generate(labels.length, (index) => _isLinkCompletelyEmpty(index))
        .every((item) => item);
  }

  bool _itemHasAnyContent(int index) {
    return labels[index].text.trim().isNotEmpty ||
        urls[index].text.trim().isNotEmpty;
  }

  bool _isDuplicateLabelAt(int index) {
    final current = labels[index].text.trim().toLowerCase();
    if (current.isEmpty) return false;

    final occurrences = labels.where((controller) {
      return controller.text.trim().toLowerCase() == current;
    }).length;

    return occurrences > 1;
  }

  bool _labelIsValid(int index) {
    final value = labels[index].text.trim();

    if (value.isEmpty) return false;
    if (value.length < 2) return false;
    if (_isDuplicateLabelAt(index)) return false;

    return true;
  }

  bool _urlIsValidState(int index) {
    final value = urls[index].text.trim();

    if (value.isEmpty) return false;

    return _isValidUrl(value);
  }

  bool _labelHasError(int index) {
    if (!_validationTriggered) return false;

    if (_allLinksEmpty && index == 0) {
      return true;
    }

    if (!_itemHasAnyContent(index)) {
      return false;
    }

    return !_labelIsValid(index);
  }

  bool _urlHasError(int index) {
    if (!_validationTriggered) return false;

    if (_allLinksEmpty && index == 0) {
      return true;
    }

    if (!_itemHasAnyContent(index)) {
      return false;
    }

    return !_urlIsValidState(index);
  }

  List<SocialLinkModel> _buildLinks() {
    return List.generate(
      labels.length,
      (index) => SocialLinkModel(
        label: labels[index].text.trim(),
        url: _buildStoredUrl(urls[index].text),
      ),
    );
  }

  void _sync() {
    ref.read(onboardingProvider.notifier).setLinks(_buildLinks());
  }

  void _addLink() {
    final labelController = TextEditingController();
    final urlController = TextEditingController();

    labelController.addListener(_handleFieldChanged);
    urlController.addListener(_handleFieldChanged);

    setState(() {
      labels.add(labelController);
      urls.add(urlController);
    });

    _sync();
    widget.onJobuMessageChange(null);
  }

  void _removeLink(int index) {
    if (index == 0) {
      _showJobuMessage(
        'O primeiro item é fixo para te orientar.',
      );
      return;
    }

    labels[index].dispose();
    urls[index].dispose();

    setState(() {
      labels.removeAt(index);
      urls.removeAt(index);
    });

    _sync();
    widget.onJobuMessageChange(null);
  }

  void _handleContinue() {
    setState(() {
      _validationTriggered = true;
    });

    final rawLinks = List.generate(
      labels.length,
      (index) => SocialLinkModel(
        label: labels[index].text.trim(),
        url: _buildStoredUrl(urls[index].text),
      ),
    );

    final filledLinks = rawLinks.where((item) {
      return item.label.isNotEmpty || item.url.isNotEmpty;
    }).toList();

    if (filledLinks.isEmpty) {
      _showJobuMessage(
        'Preencha pelo menos um link \nou clique em pular.',
      );
      return;
    }

    for (final item in filledLinks) {
      if (item.label.isEmpty) {
        _showJobuMessage('Preencha o nome do link ou remova o item vazio.');
        return;
      }

      if (item.label.length < 2) {
        _showJobuMessage('O nome do link está curto demais.');
        return;
      }

      final strippedUrl = _stripUrlPrefix(item.url);

      if (strippedUrl.isEmpty) {
        _showJobuMessage('Preencha a URL do link ${item.label}.');
        return;
      }

      if (!_isValidUrl(item.url)) {
        _showJobuMessage(
          'A URL de ${item.label} precisa ser válida.',
        );
        return;
      }
    }

    final normalizedLabels = filledLinks
        .map((e) => e.label.trim().toLowerCase())
        .toList();

    if (normalizedLabels.toSet().length != normalizedLabels.length) {
      _showJobuMessage(
        'Você adicionou links repetidos.',
      );
      return;
    }

    ref.read(onboardingProvider.notifier).setLinks(filledLinks);
    widget.onJobuMessageChange(null);
    widget.onNext();
  }

  void _handleSkip() {
    ref.read(onboardingProvider.notifier).setLinks([]);
    widget.onJobuMessageChange(null);
    widget.onSkip();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

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
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.links,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Links',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      color: theme.dividerColor.withOpacity(0.2),
                    ),
                    if (labels.isNotEmpty)
                      Column(
                        children: List.generate(labels.length, (index) {
                          return Column(
                            children: [
                              _linkItem(index),
                              if (index != labels.length - 1)
                                Divider(
                                  height: 24,
                                  color: theme.dividerColor.withOpacity(0.2),
                                ),
                            ],
                          );
                        }),
                      ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _addLink,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar link'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _handleSkip,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: theme.colorScheme.primary,
                              ),
                              foregroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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

  Widget _linkItem(int index) {
    final isFixedItem = index == 0;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _fieldLabel(
                icon: AppIcons.info,
                label: 'Nome do Link',
              ),
            ),
            const SizedBox(width: 8),
            Opacity(
              opacity: isFixedItem ? 0.35 : 1,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: IconButton(
                  tooltip: isFixedItem ? 'Item fixo' : 'Remover link',
                  onPressed: () => _removeLink(index),
                  icon: SvgPicture.asset(
                    AppIcons.trash,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                      theme.iconTheme.color ?? Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppValidatedInputField(
          controller: labels[index],
          hint: 'Nome do link (ex: LinkedIn)',
          maxLength: 60,
          hasError: _labelHasError(index),
          isValid: _labelIsValid(index),
          inputFormatters: [
            LinkTitleInputFormatter(),
          ],
          onChanged: (_) {
            widget.onJobuMessageChange(null);
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
        _fieldLabel(
          icon: AppIcons.links,
          label: 'URL',
        ),
        const SizedBox(height: 8),
        AppValidatedInputField(
          controller: urls[index],
          hint: 'seu-link.com',
          maxLength: 200,
          keyboardType: TextInputType.url,
          hasError: _urlHasError(index),
          isValid: _urlIsValidState(index),
          onChanged: (_) {
            widget.onJobuMessageChange(null);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _fieldLabel({
    required String icon,
    required String label,
  }) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 16,
          height: 16,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}