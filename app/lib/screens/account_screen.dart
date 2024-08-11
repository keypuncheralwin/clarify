// lib/screens/account_screen.dart
import 'package:clarify/widgets/confirm_logout_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clarify/providers/theme_provider.dart';
import 'package:clarify/providers/auth_provider.dart';
import 'package:clarify/widgets/sign_in_bottom_sheet.dart';
import 'package:clarify/widgets/clear_history_bottom_sheet.dart';
import 'package:clarify/widgets/tutorial_bottom_sheet.dart';
import 'package:clarify/widgets/feedback_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider).brightness == Brightness.dark;
    final user = ref.watch(authStateProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user == null)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _showEmailBottomSheet(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    'Sign in or create an account',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            const SizedBox(height: 40),
            Text(
              'General Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildListTile(
              context,
              icon: Icons.history,
              title: 'Clear History',
              onTap: () {
                _showClearHistoryBottomSheet(context);
              },
              isDarkMode: isDarkMode,
            ),
            _buildListTile(
              context,
              icon: Icons.brightness_6,
              title: 'Dark Mode',
              trailing: Transform.scale(
                scale: 0.8, // Adjust scale as necessary
                child: Switch(
                  value: isDarkMode,
                  onChanged: (bool value) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                  activeColor: Colors.white,
                  activeTrackColor: Colors.grey,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ),
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 40),
            Text(
              'Support the Clarify team',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildListTile(
              context,
              icon: Icons.share,
              title: 'Share with Friends',
              onTap: () {
                _shareApp(context); // Call the share function
              },
              isDarkMode: isDarkMode,
            ),
            _buildListTile(
              context,
              icon: Icons.feedback,
              title: 'Leave Feedback (Please...)',
              onTap: () {
                _showFeedbackBottomSheet(context);
              },
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 40),
            Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildListTile(
              context,
              icon: Icons.help_outline,
              title: 'How to use Clarify',
              onTap: () {
                _showTutorialBottomSheet(context);
              },
              isDarkMode: isDarkMode,
            ),
            _buildListTile(
              context,
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: dotenv.env['APP_VER'] ?? 'Demo',
              isDarkMode: isDarkMode,
            ),
            if (user != null) ...[
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _showConfirmLogoutBottomSheet(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 10),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon,
      required String title,
      String? subtitle,
      Widget? trailing,
      void Function()? onTap,
      required bool isDarkMode,
      Color textColor = Colors.black}) {
    return ListTile(
      leading: Icon(icon, color: isDarkMode ? Colors.white : Colors.black),
      title: Text(
        title,
        style: TextStyle(color: isDarkMode ? Colors.white : textColor),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showEmailBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return const SignInBottomSheet();
      },
    );
  }

  void _showClearHistoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return const ClearHistoryBottomSheet();
      },
    ).then((confirmed) {
      if (confirmed == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History cleared successfully')),
        );
      }
    });
  }

  void _showTutorialBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return const TutorialBottomSheet();
      },
    );
  }

  void _showFeedbackBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return const FeedbackBottomSheet();
      },
    );
  }

  void _shareApp(BuildContext context) {
    const String message =
        'Hey, check out the Clarify app at www.clarifyapp.io';
    Share.share(message);
  }

  void _showConfirmLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return const ConfirmLogoutBottomSheet();
      },
    );
  }
}
