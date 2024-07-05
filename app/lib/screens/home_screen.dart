import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clarify/providers/auth_provider.dart'; // Import your auth provider

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (user != null) ...[
                Text(
                  'Welcome, ${user.displayName}!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, color: Colors.grey),
                ),
                const SizedBox(height: 20),
              ],
              const Text(
                "Looks like you haven't clarified anything yet",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Text(
                "Get started by sharing a link to the clarify app or paste a link here by tapping the link button below",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
