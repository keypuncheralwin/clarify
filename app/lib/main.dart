import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

void main() => runApp(const ClarifyApp());

class ClarifyApp extends StatelessWidget {
  const ClarifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clarify',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const platform = MethodChannel('com.example.clarify/api');
  int _currentIndex = 0;
  Map<String, dynamic>? _result;
  bool _isLoading = false;
  final GlobalKey<_BottomSheetContentState> _bottomSheetKey = GlobalKey<_BottomSheetContentState>();

  final List<Widget> _children = [
    const HomeScreen(),
    const HistoryScreen(),
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
      try {
        final result = await platform.invokeMethod<Map<dynamic, dynamic>>('analyzeLink', {'url': url});
        if (result != null) {
          setState(() {
            _result = Map<String, dynamic>.from(result);
            _isLoading = false;
            _bottomSheetKey.currentState?.updateContent(_isLoading, _result);
          });
        } else {
          setState(() {
            _isLoading = false;
            _bottomSheetKey.currentState?.updateContent(_isLoading, null);
          });
        }
      } on PlatformException catch (e) {
        print("Failed to analyze link: '${e.message}'.");
        setState(() {
          _isLoading = false;
          _bottomSheetKey.currentState?.updateContent(_isLoading, null);
        });
      }
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
                child: const Icon(Icons.link),
              ),
            )
          : null,
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const CustomBottomNavigationBar({super.key, required this.currentIndex, required this.onTabTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1F1F1F),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.history, 'History', 1),
            _buildNavItem(Icons.account_circle, 'Account', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            color: currentIndex == index ? Colors.deepPurple : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: currentIndex == index ? Colors.deepPurple : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Screen', style: TextStyle(fontSize: 24, color: Colors.white)),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('History Screen', style: TextStyle(fontSize: 24, color: Colors.white)),
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Account Screen', style: TextStyle(fontSize: 24, color: Colors.white)),
    );
  }
}

class BottomSheetContent extends StatefulWidget {
  final bool isLoading;
  final Map<String, dynamic>? result;

  const BottomSheetContent({super.key, required this.isLoading, required this.result});

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  late bool _isLoading;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading;
    _result = widget.result;
  }

  void updateContent(bool isLoading, Map<String, dynamic>? result) {
    setState(() {
      _isLoading = isLoading;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: _isLoading
          ? _buildLoadingContent()
          : _result != null
              ? _buildResultContent(_result!)
              : const Text('No data available'),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[700]!,
          highlightColor: Colors.grey[500]!,
          child: Container(
            width: double.infinity,
            height: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: Colors.grey[700]!,
          highlightColor: Colors.grey[500]!,
          child: Container(
            width: double.infinity,
            height: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: Colors.grey[700]!,
          highlightColor: Colors.grey[500]!,
          child: Container(
            width: double.infinity,
            height: 100,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildResultContent(Map<String, dynamic> result) {
    final title = result['title'] ?? 'No title available';
    final clarityScore = result['clarityScore']?.toString() ?? 'N/A';
    final answer = result['answer'] ?? 'No answer available';
    final summary = result['summary'] ?? 'No summary available';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Clarity Score: $clarityScore',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          answer,
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 10),
        Text(
          summary,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

