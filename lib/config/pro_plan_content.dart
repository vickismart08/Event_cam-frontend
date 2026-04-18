import 'pricing_region.dart';

/// Copy for **Glamora Pro** pricing & benefits. Edit prices and bullets here.
class ProPlanContent {
  ProPlanContent._();

  static const String headline = 'Glamora Pro';

  static const String subtitle =
      'Pick monthly flexibility or yearly savings. Same Pro features either way — '
      'billing connects here soon.';

  /// Shown below the plan cards (full checklist).
  static const String includedHeading = 'What’s included in Pro';

  static const List<ProPlanBullet> bullets = [
    ProPlanBullet(
      title: 'Full-resolution photos',
      detail: 'Store and download images at original quality — ideal for prints, albums, and editing.',
    ),
    ProPlanBullet(
      title: 'Smarter compression on Free',
      detail: 'Free may optimize files for speed and storage; Pro keeps your master files intact.',
    ),
    ProPlanBullet(
      title: 'Bulk & ZIP export',
      detail: 'Download everything from an event in one shot — no saving one-by-one.',
    ),
    ProPlanBullet(
      title: 'More events & longer retention',
      detail: 'Run multiple active events and keep galleries online longer (exact limits TBD).',
    ),
    ProPlanBullet(
      title: 'Branding options',
      detail: 'Cleaner guest-facing pages and optional removal of Glamora promo elements.',
    ),
    ProPlanBullet(
      title: 'Priority support',
      detail: 'Faster help when your event day matters most.',
    ),
  ];

  /// Placeholder NGN amounts (edit when billing goes live). Shown when IP resolves to Nigeria.
  static const String _ngnMonthly = '₦18,600';
  static const String _ngnYearly = '₦122,500';

  static ProPricingTier tierMonthly(PricingRegion region) {
    final ngn = region == PricingRegion.nigeria;
    return ProPricingTier(
      id: 'monthly',
      title: 'Monthly',
      priceDisplay: ngn ? _ngnMonthly : '\$12',
      periodLine: 'per month',
      subLine: 'Cancel anytime',
      ctaLabel: 'Choose monthly',
    );
  }

  static ProPricingTier tierYearly(PricingRegion region) {
    final ngn = region == PricingRegion.nigeria;
    return ProPricingTier(
      id: 'yearly',
      title: 'Yearly',
      priceDisplay: ngn ? _ngnYearly : '\$79',
      periodLine: 'per year',
      subLine: 'Billed annually',
      badge: 'Best value',
      savingsLine: 'Save vs 12× monthly — placeholder pricing',
      ctaLabel: 'Choose yearly',
    );
  }

  static const String ctaComingSoonHint = 'Payments open soon — we’ll email active hosts.';
}

/// One pricing column (monthly or yearly card).
class ProPricingTier {
  const ProPricingTier({
    required this.id,
    required this.title,
    required this.priceDisplay,
    required this.periodLine,
    required this.subLine,
    required this.ctaLabel,
    this.badge,
    this.savingsLine,
  });

  final String id;
  final String title;
  final String priceDisplay;
  final String periodLine;
  final String subLine;
  final String ctaLabel;
  final String? badge;
  final String? savingsLine;
}

class ProPlanBullet {
  const ProPlanBullet({required this.title, this.detail});

  final String title;
  final String? detail;
}
