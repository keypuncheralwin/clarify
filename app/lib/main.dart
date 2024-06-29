import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clarify/screens/main_screen.dart';
import 'package:clarify/providers/theme_provider.dart';

void main() => runApp(const ProviderScope(child: ClarifyApp()));

class ClarifyApp extends ConsumerWidget {
  const ClarifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Clarify',
      theme: theme,
      home: const MainScreen(),
    );
  }
}
