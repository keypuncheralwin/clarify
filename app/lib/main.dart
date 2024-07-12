import 'package:clarify/providers/user_history_notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clarify/screens/main_screen.dart';
import 'package:clarify/providers/theme_provider.dart';
import 'package:shared_preferences_tools/shared_preferences_tools.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('Observer added');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('Observer removed');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint('AppLifecycleState changed: $state');
    if (state == AppLifecycleState.resumed) {
      debugPrint('APP RESUMED');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clarify',
      theme: ref.watch(themeProvider),
      home: const MainScreen(),
    );
  }
}
