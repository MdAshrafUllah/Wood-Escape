import 'dart:io';

import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppLinks {
  AppLinks._();

  // TODO: Replace with real URLs before release
  static const String privacyPolicyUrl = 'https://example.com/privacy-policy';
  static const String termsUrl = 'https://example.com/terms-and-conditions';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.woodescape';
  static const String appStoreUrl = 'https://apps.apple.com/app/id0000000000';

  static Future<bool> openPrivacyPolicy() => _openUrl(privacyPolicyUrl);

  static Future<bool> openTerms() => _openUrl(termsUrl);

  static Future<bool> rateApp() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
      return true;
    }

    final url = Platform.isIOS ? appStoreUrl : playStoreUrl;
    return _openUrl(url);
  }

  static Future<void> shareApp() async {
    await Share.share(
      'Check out WoodEscape. A fun relaxing wooden block puzzle!\n'
      'Try it here: $playStoreUrl',
      subject: 'WoodEscape Puzzle Game',
    );
  }

  static Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  static Future<bool> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
