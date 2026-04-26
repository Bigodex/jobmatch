// =======================================================
// EDIT LINKS SCREEN
// -------------------------------------------------------
// Agora no mesmo padrão do StepLinks:
// - Primeiro item fixo
// - Labels + ícones acima dos campos
// - Validações visuais com shared input
// - URL salva com https:// automático e oculto no input
// - Salva apenas itens válidos
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

import 'package:jobmatch/features/profile/models/social_link_model.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';
import 'package:jobmatch/features/profile/screens/success_screen.dart';

import 'package:jobmatch/shared/widgets/app_header.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';
import 'package:jobmatch/shared/widgets/app_validated_input_field.dart';

// =======================================================
// TEXT FORMATTER
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
  static const String _hiddenUrlPrefix = 'https://';

  late List<TextEditingController> labels;
  late List<TextEditingController> urls;

  bool _validationTriggered = false;
  bool _hasChanged = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final initialLinks = widget.links.isNotEmpty
        ? widget.links
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

    _recalculateState();
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
    _errorMessage = null;
    _recalculateState();
  }

  void _recalculateState() {
    _hasChanged = _hasLinksChanged();

    if (mounted) {
      setState(() {});
    }
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

  List<SocialLinkModel> _buildAllLinks() {
    return List.generate(
      labels.length,
      (index) => SocialLinkModel(
        label: labels[index].text.trim(),
        url: _buildStoredUrl(urls[index].text),
      ),
    );
  }

  List<SocialLinkModel> _buildFilledLinks() {
    return _buildAllLinks().where((item) {
      return item.label.isNotEmpty || item.url.isNotEmpty;
    }).toList();
  }

  bool _hasLinksChanged() {
    final current = _buildFilledLinks();
    final original = widget.links;

    if (current.length != original.length) return true;

    for (int i = 0; i < current.length; i++) {
      if (current[i].label.trim() != original[i].label.trim()) return true;
      if (current[i].url.trim() != original[i].url.trim()) return true;
    }

    return false;
  }

  void _addLink() {
    final labelController = TextEditingController();
    final urlController = TextEditingController();

    labelController.addListener(_handleFieldChanged);
    urlController.addListener(_handleFieldChanged);

    setState(() {
      labels.add(labelController);
      urls.add(urlController);
      _errorMessage = null;
    });

    _recalculateState();
  }

  void _removeLink(int index) {
    if (index == 0) {
      setState(() {
        _validationTriggered = true;
        _errorMessage = 'O primeiro item é fixo para te orientar.';
      });
      return;
    }

    labels[index].dispose();
    urls[index].dispose();

    setState(() {
      labels.removeAt(index);
      urls.removeAt(index);
      _errorMessage = null;
    });

    _recalculateState();
  }

  Future<void> _save() async {
    setState(() {
      _validationTriggered = true;
      _errorMessage = null;
    });

    final filledLinks = _buildFilledLinks();

    if (filledLinks.isEmpty) {
      setState(() {
        _errorMessage = 'Preencha pelo menos um link.';
      });
      return;
    }

    for (final item in filledLinks) {
      if (item.label.isEmpty) {
        setState(() {
          _errorMessage = 'Preencha o nome do link ou remova o item vazio.';
        });
        return;
      }

      if (item.label.length < 2) {
        setState(() {
          _errorMessage = 'O nome do link está curto demais.';
        });
        return;
      }

      final strippedUrl = _stripUrlPrefix(item.url);

      if (strippedUrl.isEmpty) {
        setState(() {
          _errorMessage = 'Preencha a URL do link ${item.label}.';
        });
        return;
      }

      if (!_isValidUrl(item.url)) {
        setState(() {
          _errorMessage = 'A URL de ${item.label} precisa ser válida.';
        });
        return;
      }
    }

    final normalizedLabels = filledLinks
        .map((e) => e.label.trim().toLowerCase())
        .toList();

    if (normalizedLabels.toSet().length != normalizedLabels.length) {
      setState(() {
        _errorMessage = 'Você adicionou links repetidos.';
      });
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      await ref
          .read(profileProvider.notifier)
          .updateLinks(filledLinks)
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              throw Exception('Tempo limite ao salvar.');
            },
          );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SuccessScreen(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: AppHeader(
              title: 'Editar',
              showBackButton: true,
            ),
          ),
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
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (!_hasChanged || _isSaving) ? null : _save,
                              child: Text(
                                _isSaving ? 'Salvando...' : 'Salvar',
                              ),
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
            _errorMessage = null;
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
            _errorMessage = null;
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