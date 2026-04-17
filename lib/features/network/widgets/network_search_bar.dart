// =======================================================
// NETWORK SEARCH BAR
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

import '../providers/network_provider.dart';

class NetworkSearchBar extends ConsumerStatefulWidget {
  const NetworkSearchBar({super.key});

  @override
  ConsumerState<NetworkSearchBar> createState() => _NetworkSearchBarState();
}

class _NetworkSearchBarState extends ConsumerState<NetworkSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final query = ref.watch(networkSearchProvider);

    if (_controller.text != query) {
      _controller.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.cardTertiary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 20,
            color: Colors.white.withOpacity(0.72),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (value) {
                ref.read(networkSearchProvider.notifier).state = value;
              },
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Buscar por pessoa, cargo ou cidade',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          if (query.trim().isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                ref.read(networkSearchProvider.notifier).state = '';
                FocusScope.of(context).unfocus();
              },
              child: Icon(
                Icons.close,
                size: 18,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
        ],
      ),
    );
  }
}