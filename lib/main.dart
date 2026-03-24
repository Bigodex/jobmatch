import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

import 'core/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

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