import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clarify/providers/theme_provider.dart';

class WebViewScreen extends ConsumerWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider).brightness == Brightness.dark;

    final ThemeData theme = isDarkMode
        ? ThemeData.dark().copyWith(
            primaryColor: Colors.deepPurple,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F1F1F), // Match the dark mode color
              foregroundColor: Colors.white,
            ),
          )
        : ThemeData.light().copyWith(
            primaryColor: Colors.deepPurple,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white, // Match the light mode color
              foregroundColor: Color(0xFF1F1F1F),
            ),
          );

    final MediaQueryData mediaQueryData =
        // ignore: deprecated_member_use
        MediaQueryData.fromView(WidgetsBinding.instance.window);

    return MediaQuery(
      data: mediaQueryData,
      child: Theme(
        data: theme,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              'Clarify',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: WebView(
            initialUrl: url,
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
      ),
    );
  }
}
