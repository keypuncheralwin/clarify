import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clarify/screens/home_screen.dart';
import 'package:clarify/screens/favorites_screen.dart';
import 'package:clarify/screens/account_screen.dart';
import 'package:clarify/widgets/custom_bottom_navigation_bar.dart';
import 'package:clarify/widgets/bottom_sheet_content.dart';
import 'package:clarify/api/analyse_link.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _result;
  bool _isLoading = false;
  final GlobalKey<BottomSheetContentState> _bottomSheetKey = GlobalKey<BottomSheetContentState>();

  final List<Widget> _children = [
    const HomeScreen(),
    const FavoritesScreen(),
    const AccountScreen(),
  ];

  final int _remainingTokens = 10; // Example token count

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _analyzeLink() async {
    setState(() {
      _isLoading = true;
      _result = null; // Clear previous result
    });

    ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    String? url = clipboardData?.text;

    if (url != null && url.isNotEmpty) {
      _showBottomSheet();
      final result = await ApiService.analyzeLink(url);
      setState(() {
        _result = result;
        _isLoading = false;
        _bottomSheetKey.currentState?.updateContent(_isLoading, _result);
      });
    } else {
      print("No URL found in clipboard.");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BottomSheetContent(
          key: _bottomSheetKey,
          isLoading: _isLoading,
          result: _result,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clarify'),
        actions: [
          Row(
            children: [
              const SizedBox(width: 5),
              Text(
                '$_remainingTokens',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.token, color: Colors.white),
            ],
          ),
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabTapped: onTabTapped,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _analyzeLink,
              backgroundColor: Colors.deepPurple,
              child: Transform.rotate(
                angle: -0.785398, // -45 degrees in radians
                child: const Icon(
                  Icons.link,
                  color:Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}
