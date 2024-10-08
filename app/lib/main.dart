import 'package:clarify/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clarify/providers/theme_provider.dart';
import 'package:clarify/screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences_tools/shared_preferences_tools.dart';
import 'package:uni_links/uni_links.dart'; // Import uni_links package
import 'package:clarify/utils/link_utils.dart'; // Import the openLink function
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesToolsDebug.init();
  await dotenv.load(fileName: ".env"); // Load environment variables
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clarify',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const ClarifyApp(),
    );
  }
}

class ClarifyApp extends ConsumerStatefulWidget {
  const ClarifyApp({super.key});

  @override
  _ClarifyAppState createState() => _ClarifyAppState();
}

class _ClarifyAppState extends ConsumerState<ClarifyApp>
    with WidgetsBindingObserver {
  final GlobalKey<HomeScreenState> _homeScreenKey =
      GlobalKey<HomeScreenState>();
  static const platform = MethodChannel('com.clarify.app/api');
  bool _shouldRefresh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    platform.setMethodCallHandler(_handleNativeCalls);
    _initUniLinks(); // Initialize uni_links to handle deep links
    debugPrint('ClarifyApp initialized and observer added');
  }

  Future<void> _handleNativeCalls(MethodCall call) async {
    if (call.method == "historyUpdated") {
      setState(() {
        _shouldRefresh = true;
      });
      debugPrint(
          'Link analyzed broadcast received, should refresh set to true');
    }
  }

  void _initUniLinks() async {
    try {
      Uri? initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
      uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      });
    } on PlatformException {
      // Handle exception
    }
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'clarify' && uri.host == 'open') {
      final String? url = uri.queryParameters['url'];
      final String? isVideoString = uri.queryParameters['isVideo'];
      final bool isVideo = isVideoString == 'true';
      if (url != null) {
        openLink(context, url, isVideo);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    debugPrint('Observer removed and ClarifyApp disposed');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('AppLifecycleState changed: $state');
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed');
      if (_shouldRefresh) {
        debugPrint('Triggering refresh as should refresh is true');
        _homeScreenKey.currentState?.triggerRefresh();
        setState(() {
          _shouldRefresh = false;
        });
      } else {
        debugPrint('No refresh needed as should refresh is false');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clarify',
      theme: ref.watch(themeProvider),
      home: MainScreen(homeScreenKey: _homeScreenKey),
    );
  }
}
