import 'package:clarify/screens/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openLink(BuildContext context, String url, bool isVideo) async {
  final Uri uri = Uri.parse(url);
  try {
    if (isVideo) {
      final Uri youtubeUri = Uri.parse('vnd.youtube:$url');
      final Uri webYoutubeUri = Uri.parse(url);

      if (await canLaunchUrl(youtubeUri)) {
        await launchUrl(youtubeUri);
      } else if (await canLaunchUrl(webYoutubeUri)) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WebViewScreen(url: url),
          ),
        );
      } else {
        throw 'Could not launch $url';
      }
    } else {
      if (await canLaunchUrl(uri)) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WebViewScreen(url: url),
          ),
        );
      } else {
        throw 'Could not launch $url';
      }
    }
  } catch (e) {
    // Handle exception
    print('Exception: $e');
  }
}
