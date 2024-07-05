import 'package:flutter/material.dart';
import 'package:clarify/screens/home_screen.dart';
import 'package:clarify/screens/favorites_screen.dart';
import 'package:clarify/screens/account_screen.dart';
import 'package:clarify/widgets/custom_bottom_navigation_bar.dart';
import 'package:clarify/widgets/analysed_link_bottom_sheet.dart';
import 'package:clarify/api/analyse_link.dart';
import 'package:clarify/utils/url_validator.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clarify/api/auth_service.dart';

class MainScreen extends StatefulWidget {
  final String? email;
  final String? token;

  const MainScreen({super.key, this.email, this.token});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _result;
  bool _isLoading = false;
  String? _errorMessage;
  final GlobalKey<AnalysedLinkBottomSheetState> _bottomSheetKey = GlobalKey<AnalysedLinkBottomSheetState>();
  BuildContext? _bottomSheetContext;

  final List<Widget> _children = [
    const HomeScreen(),
    const FavoritesScreen(),
    const AccountScreen(),
  ];

  final int _remainingTokens = 10; // Example token count

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.email != null && widget.token != null) {
        authenticateUser(widget.email!, widget.token!);
      }
    });
  }

  Future<void> authenticateUser(String email, String token) async {
    _showMessageBottomSheet('Authenticating...', false);

    try {
      final firebaseToken = await AuthService.verifyMagicLink(email, token);
      await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
      if (mounted) {
        _closeBottomSheet();
        _showMessageBottomSheet('Authenticated', true);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _closeBottomSheet();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (Route<dynamic> route) => false,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _closeBottomSheet();
        _showMessageBottomSheet('Authentication failed', true);
      }
    }
  }

  Future<void> _analyzeLink() async {
    setState(() {
      _isLoading = true;
      _result = null; // Clear previous result
      _errorMessage = null; // Clear previous error message
    });

    ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    String? url = clipboardData?.text;

    if (url != null && url.isNotEmpty && isValidUrl(url)) {
      _showAnalysisBottomSheet();
      final result = await ApiService.analyzeLink(url);
      setState(() {
        _result = result;
        _isLoading = false;
        _bottomSheetKey.currentState?.updateContent(_isLoading, _result, _errorMessage);
      });
    } else {
      setState(() {
        _errorMessage = "No valid URL found in your clipboard. Make sure you have copied a valid link first before tapping the link button.";
        _isLoading = false;
      });
      _showAnalysisBottomSheet();
    }
  }

  void _showMessageBottomSheet(String message, bool isSuccess) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_bottomSheetContext != null) {
        Navigator.pop(_bottomSheetContext!);
      }

      showModalBottomSheet(
        context: context,
        isDismissible: true,
        builder: (BuildContext context) {
          _bottomSheetContext = context;
          return Container(
            padding: const EdgeInsets.all(16.0),
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSuccess)
                  const Icon(Icons.check_circle, color: Colors.green, size: 24.0),
                if (!isSuccess)
                  const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text(message),
              ],
            ),
          );
        },
      ).whenComplete(() {
        _bottomSheetContext = null;
      });
    });
  }

  void _showAnalysisBottomSheet() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_bottomSheetContext != null) {
        Navigator.pop(_bottomSheetContext!);
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          _bottomSheetContext = context;
          return AnalysedLinkBottomSheet(
            key: _bottomSheetKey,
            isLoading: _isLoading,
            result: _result,
            errorMessage: _errorMessage,
          );
        },
      ).whenComplete(() {
        _bottomSheetContext = null;
      });
    });
  }

  void _closeBottomSheet() {
    if (_bottomSheetContext != null) {
      Navigator.pop(_bottomSheetContext!);
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}
