// lib/utils/url_validator.dart
bool isValidUrl(String url) {
  final Uri? uri = Uri.tryParse(url);
  return uri != null && uri.hasScheme && uri.hasAuthority;
}
