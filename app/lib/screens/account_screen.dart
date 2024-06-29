import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  // Implement sign-in or create account functionality
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
            const Text(
              'General Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
            ),
            _buildListTile(
              context,
              icon: Icons.history,
              title: 'Clear History',
              onTap: () {
                // Implement clear history functionality
              },
            ),
            _buildListTile(
              context,
              icon: Icons.brightness_6,
              title: 'Dark Mode',
              trailing: Transform.scale(
                scale: 0.8, // Adjust scale as necessary
                child: Switch(
                  value: true,
                  onChanged: (bool value) {
                    // Implement dark mode toggle functionality
                  },
                  activeColor: Colors.white,
                  activeTrackColor: Colors.grey,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Support Indie Devs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
            ),
            const SizedBox(height: 40),
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
            ),
            _buildListTile(
              context,
              icon: Icons.contact_mail,
              title: 'Contact Us',
              onTap: () {
                // Implement contact us functionality
              },
            ),
            _buildListTile(
              context,
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: '1.0.0', // Replace with actual app version
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
      void Function()? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: Colors.white70),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
