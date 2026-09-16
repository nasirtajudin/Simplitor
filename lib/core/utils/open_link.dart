import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

/// Opens an external link. Placeholder URLs (Terms, Privacy, Support)
/// point to google.com for now — swap in the real links later.
Future<void> openExternalLink(String url) async {
  try {
    final Uri uri = Uri.parse(url);
    if (kIsWeb) {
      await launchUrl(uri);
    } else {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  } catch (_) {
    // Never crash the app over a failed link launch.
  }
}