import 'package:clarify/types/user_history_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clarify/screens/home_screen.dart';
import 'package:clarify/screens/favorites_screen.dart';
import 'package:clarify/screens/account_screen.dart';
import 'package:clarify/widgets/custom_bottom_navigation_bar.dart';
import 'package:clarify/api/analyse_link.dart';
import 'package:clarify/utils/url_validator.dart';
import 'package:flutter/services.dart';
import 'package:clarify/providers/auth_provider.dart';
import 'package:clarify/providers/user_history_notifier.dart';
import 'package:clarify/widgets/analysed_link_bottom_sheet.dart';
import 'package:clarify/types/analysed_link_response.dart';

class MainScreen extends ConsumerStatefulWidget {
  final GlobalKey<HomeScreenState> homeScreenKey;

  const MainScreen({super.key, required this.homeScreenKey});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  AnalysedLinkResponse? _result;
  bool _isLoading = false;
  String? _errorMessage;
  final GlobalKey<AnalysedLinkBottomSheetState> _bottomSheetKey =
      GlobalKey<AnalysedLinkBottomSheetState>();

  late List<Widget> _children;

  final int _remainingTokens = 10; // Example token count

  @override
  void initState() {
    super.initState();
    _children = [
      HomeScreen(key: widget.homeScreenKey),
      const FavoritesScreen(),
      const AccountScreen(),
    ];
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _analyseLink() async {
    setState(() {
      _isLoading = true;
      _result = null; // Clear previous result
      _errorMessage = null; // Clear previous error message
    });

    ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    String? url = clipboardData?.text;

    if (url != null && url.isNotEmpty && isValidUrl(url)) {
      _showBottomSheet();
      final result = await ApiService.analyseLink(url);
      setState(() {
        _result = result;
        _isLoading = false;
        _bottomSheetKey.currentState
            ?.updateContent(_isLoading, _result, _errorMessage);
      });

      if (result != null) {
        final historyItem = UserHistoryItem(
          historyId: 'PLACEHOLDER',
          analysedLink: result,
        );
        ref.read(userHistoryProvider.notifier).addNewHistory(historyItem);
      }
    } else {
      setState(() {
        _errorMessage =
            "No valid URL found in your clipboard. Make sure you have copied a valid link first before tapping the link button.";
        _isLoading = false;
      });
      _showBottomSheet();
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AnalysedLinkBottomSheet(
          key: _bottomSheetKey,
          isLoading: _isLoading,
          result: _result,
          errorMessage: _errorMessage,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final authStatus = user != null ? 'Authenticated' : 'Not authenticated';

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
              onPressed: _analyseLink,
              backgroundColor: Colors.deepPurple,
              child: Transform.rotate(
                angle: -0.785398, // -45 degrees in radians
                child: const Icon(
                  Icons.link,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}
