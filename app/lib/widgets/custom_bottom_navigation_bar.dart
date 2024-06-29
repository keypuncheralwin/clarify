import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const CustomBottomNavigationBar({super.key, required this.currentIndex, required this.onTabTapped});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F1F1F) : const Color(0xFFF5F5F5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(Icons.home, 'Home', 0, isDarkMode),
            _buildNavItem(Icons.favorite, 'Favorites', 1, isDarkMode),
            _buildNavItem(Icons.account_circle, 'Account', 2, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isDarkMode) {
    return GestureDetector(
      onTap: () => onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            color: currentIndex == index ? Colors.deepPurple : (isDarkMode ? Colors.grey : Colors.black),
          ),
          Text(
            label,
            style: TextStyle(
              color: currentIndex == index ? Colors.deepPurple : (isDarkMode ? Colors.grey : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
