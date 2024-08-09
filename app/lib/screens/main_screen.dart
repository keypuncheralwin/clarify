import 'package:clarify/types/user_history_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clarify/screens/home_screen.dart';
import 'package:clarify/screens/account_screen.dart';
import 'package:clarify/api/analyse_link.dart';
import 'package:clarify/utils/url_validator.dart';
import 'package:flutter/services.dart';
import 'package:clarify/providers/user_history_notifier.dart';
import 'package:clarify/widgets/analysed_link_bottom_sheet.dart';
import 'package:clarify/types/analysis_result.dart';

class MainScreen extends ConsumerStatefulWidget {
  final GlobalKey<HomeScreenState> homeScreenKey;

  const MainScreen({super.key, required this.homeScreenKey});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  AnalysisResult? _result;
  bool _isLoading = false;
  String? _errorMessage;
  final GlobalKey<AnalysedLinkBottomSheetState> _bottomSheetKey =
      GlobalKey<AnalysedLinkBottomSheetState>();

  late List<Widget> _children;

  @override
  void initState() {
    super.initState();
    _children = [
      HomeScreen(key: widget.homeScreenKey),
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
        if (result != null && result.status == 'success') {
          _errorMessage = null;
          _bottomSheetKey.currentState
              ?.updateContent(_isLoading, result.data, _errorMessage);
        } else {
          _errorMessage = result?.error?.errorMessage ?? 'An error occurred';
          _bottomSheetKey.currentState
              ?.updateContent(_isLoading, null, _errorMessage);
        }
      });

      if (result != null && result.status == 'success' && result.data != null) {
        final historyItem = UserHistoryItem(
          historyId: 'PLACEHOLDER',
          analysedLink: result.data!,
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
          result: _result?.data,
          errorMessage: _errorMessage,
        );
      },
    );
  }

  void _navigateToAccountScreen() {
    Navigator.of(context).push(_createRoute());
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
        appBar: AppBar(
          title: const Text('Account'),
        ),
        body: const AccountScreen(),
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
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
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _navigateToAccountScreen,
          ),
        ],
      ),
      body: Stack(
        children: [
          _children[_currentIndex],
          if (_currentIndex == 0)
            Positioned(
              bottom: MediaQuery.of(context).size.height *
                  0.05, // 10% of the screen height
              right: 25.0,
              child: FloatingActionButton(
                onPressed: _analyseLink,
                backgroundColor: Colors.deepPurple,
                child: Transform.rotate(
                  angle: -0.785398, // -45 degrees in radians
                  child: const Icon(
                    Icons.link,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
