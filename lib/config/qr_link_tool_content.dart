import 'pricing_region.dart';

/// Marketing + regional price for the “QR for any link” tool on the landing page.
class QrLinkToolContent {
  QrLinkToolContent._();

  static const String title = 'QR code for any link';

  static const String navLinkLabel = 'QR for any link';

  static const String subtitle =
      'Sign in to generate. Every account gets one free scannable QR. After that, previews are '
      'watermarked until payment is confirmed — then your codes work normally again.';

  static String priceDisplay(PricingRegion region) {
    return region == PricingRegion.nigeria ? '₦1,550' : '\$1';
  }

  static const String ctaGenerate = 'Generate QR';

  static String payToUnlockLabel(String price) => 'Confirm payment — $price';

  static const String signInToGenerate = 'Sign in to generate';

  static const String paymentSoonMessage =
      'Payment confirmation will unlock clean QR codes. Integration is coming soon — your account will update automatically after checkout.';

  static const String hintUrl = 'https://yoursite.com/page';

  static const String invalidUrlHint = 'Enter a valid http or https link.';

  static const String needSignInHint = 'Sign in to generate QR codes and use your free trial.';

  static const String trialUsedWatermarkHint =
      'Your free QR has been used. This preview is watermarked and will not scan. Pay once to unlock clean codes.';

  static const String firestoreErrorHint =
      'Could not load your account settings. Check your connection and Firestore setup.';

  static const String clearQrLabel = 'Clear';

  static const String watermarkBanner = 'PREVIEW — WILL NOT SCAN · PAY TO UNLOCK';
}
