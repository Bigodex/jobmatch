// =======================================================
// MAIN
// -------------------------------------------------------
// Inicialização do app + Firebase + Intl (datas pt_BR)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart'; // 👈 IMPORTANTE

import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // ===================================================
  // GARANTE INICIALIZAÇÃO DO FLUTTER
  // ===================================================
  WidgetsFlutterBinding.ensureInitialized();

  // ===================================================
  // INICIALIZA FORMATAÇÃO DE DATA (pt_BR)
  // 👇 RESOLVE O ERRO DO DateFormat
  // ===================================================
  await initializeDateFormatting('pt_BR', null);

  // ===================================================
  // INICIALIZA FIREBASE
  // ===================================================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ===================================================
  // SOBE APP COM RIVERPOD
  // ===================================================
  runApp(const ProviderScope(child: MyApp()));
}

// =======================================================
// APP ROOT
// =======================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.darkTheme,
    );
  }
}