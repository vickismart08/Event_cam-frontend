import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/pricing_region.dart';
import '../config/pro_plan_content.dart';

/// Resolves [PricingRegion] from the visitor's **approximate country** (IP geolocation).
/// Used only to choose NGN vs USD display — no GPS permission, works on web and mobile.
final PricingRegionController pricingRegionController = PricingRegionController();

class PricingRegionController extends ChangeNotifier {
  PricingRegion region = PricingRegion.international;
  bool resolved = false;

  /// Call once after app start. Safe to call multiple times; only first successful result applies.
  Future<void> detect() async {
    if (resolved) return;
    final code = await _fetchCountryCode();
    region = code == 'NG' ? PricingRegion.nigeria : PricingRegion.international;
    resolved = true;
    notifyListeners();
  }

  ProPricingTier get monthlyTier => ProPlanContent.tierMonthly(region);
  ProPricingTier get yearlyTier => ProPlanContent.tierYearly(region);
}

Future<String?> _fetchCountryCode() async {
  try {
    final r = await http
        .get(Uri.parse('https://ipapi.co/json/'))
        .timeout(const Duration(seconds: 8));
    if (r.statusCode == 200) {
      final j = jsonDecode(r.body);
      if (j is Map<String, dynamic>) {
        final c = j['country_code'];
        if (c is String && c.length == 2) return c.toUpperCase();
      }
    }
  } catch (e) {
    if (kDebugMode) debugPrint('pricing geo (ipapi): $e');
  }

  try {
    final r = await http
        .get(Uri.parse('https://get.geojs.io/v1/ip/country.json'))
        .timeout(const Duration(seconds: 8));
    if (r.statusCode == 200) {
      final j = jsonDecode(r.body);
      if (j is String && j.length == 2) return j.toUpperCase();
    }
  } catch (e) {
    if (kDebugMode) debugPrint('pricing geo (geojs): $e');
  }

  return null;
}
