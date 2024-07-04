import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clarify/providers/theme_provider.dart';
import 'package:clarify/widgets/sign_in_bottom_sheet.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showEmailBottomSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
              icon: Icons.token,
              title: 'Manage Tokens',
              onTap: () {
                // Implement navigation to manage tokens
              },
              isDarkMode: isDarkMode,
            ),
            _buildListTile(
              context,
              icon: Icons.history,
              title: 'Clear History',
              onTap: () {
                // Implement clear history functionality
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
              'Support Indie Devs',
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
                // Implement share with friends functionality
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
              title: 'How to Use',
              onTap: () {
                // Implement navigation to how to use
              },
              isDarkMode: isDarkMode,
            ),
            _buildListTile(
              context,
              icon: Icons.contact_mail,
              title: 'Contact Us',
              onTap: () {
                // Implement contact us functionality
              },
              isDarkMode: isDarkMode,
            ),
            _buildListTile(
              context,
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: '1.0.0', // Replace with actual app version
              isDarkMode: isDarkMode,
            ),
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
      required bool isDarkMode}) {
    return ListTile(
      leading: Icon(icon, color: isDarkMode ? Colors.white : Colors.black),
      title: Text(
        title,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
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
}
