// lib/features/network/screens/network_screen.dart

// =======================================================
// NETWORK SCREEN
// -------------------------------------------------------
// Tela de rede / conexões
// - atualiza ao entrar
// - suporta pull-to-refresh
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jobmatch/features/network/providers/network_provider.dart';
import 'package:jobmatch/features/network/widgets/network_discover_sections.dart';
import 'package:jobmatch/features/network/widgets/network_search_bar.dart';
import 'package:jobmatch/shared/widgets/app_header.dart';

class NetworkScreen extends ConsumerStatefulWidget {
  const NetworkScreen({super.key});

  @override
  ConsumerState<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends ConsumerState<NetworkScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(networkProfilesProvider);
    });
  }

  Future<void> _refreshNetwork() async {
    ref.invalidate(networkProfilesProvider);
    await ref.read(networkProfilesProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Minha Rede',
              showBackButton: true,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshNetwork,
                displacement: 24,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    children: const [
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: NetworkSearchBar(),
                      ),
                      SizedBox(height: 20),
                      NetworkDiscoverSections(),
                      SizedBox(height: 24),
                    ],
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