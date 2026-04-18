import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../auth/auth_controller.dart';
import '../auth/qr_link_entitlement.dart';
import '../config/qr_link_tool_content.dart';
import '../pricing/pricing_region_controller.dart';
import '../theme/app_colors.dart';
import 'app_buttons.dart';
import 'section_header.dart';
import 'soft_card.dart';

/// Landing block: sign-in required; one clean QR free per account, then watermark until paid.
class QrAnyLinkTool extends StatefulWidget {
  const QrAnyLinkTool({super.key});

  @override
  State<QrAnyLinkTool> createState() => _QrAnyLinkToolState();
}

class _QrAnyLinkToolState extends State<QrAnyLinkTool> {
  final _controller = TextEditingController();
  String? _encoded;
  String? _error;
  bool _watermarked = false;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _normalizeUrl(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    var s = t;
    if (!s.contains('://')) {
      s = 'https://$s';
    }
    final uri = Uri.tryParse(s);
    if (uri == null || !uri.hasScheme) return null;
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') return null;
    if (uri.host.isEmpty) return null;
    return uri.toString();
  }

  Future<void> _generate() async {
    final uid = authController.firebaseUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(QrLinkToolContent.needSignInHint),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final url = _normalizeUrl(_controller.text);
    if (url == null) {
      setState(() {
        _encoded = null;
        _watermarked = false;
        _error = QrLinkToolContent.invalidUrlHint;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final e = await QrLinkEntitlementService.fetch(uid);
      final wm = e.shouldWatermark;

      if (!mounted) return;
      setState(() {
        _encoded = url;
        _watermarked = wm;
        _loading = false;
      });

      if (!wm && !e.paymentConfirmed && !e.freeTrialConsumed) {
        await QrLinkEntitlementService.markFreeTrialConsumed(uid);
      }
    } on FirebaseException catch (err) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _encoded = null;
        _watermarked = false;
        _error = '${QrLinkToolContent.firestoreErrorHint} (${err.code})';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _encoded = null;
        _watermarked = false;
        _error = QrLinkToolContent.firestoreErrorHint;
      });
    }
  }

  void _clearQr() {
    setState(() {
      _encoded = null;
      _error = null;
      _watermarked = false;
    });
  }

  void _unlock(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(QrLinkToolContent.paymentSoonMessage),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _goLogin(BuildContext context) {
    context.push('/login');
  }

  @override
  Widget build(BuildContext context) {
    final price = QrLinkToolContent.priceDisplay(pricingRegionController.region);
    final w = MediaQuery.sizeOf(context).width;
    final qrSize = (w >= 600 ? 220.0 : 180.0).clamp(160.0, 260.0);

    return ListenableBuilder(
      listenable: authController,
      builder: (context, _) {
        final signedIn = authController.firebaseUser != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: QrLinkToolContent.title,
              subtitle: QrLinkToolContent.subtitle,
            ),
            const SizedBox(height: 22),
            SoftCard(
              padding: EdgeInsets.all(w >= 600 ? 28 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!signedIn) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.45)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            QrLinkToolContent.needSignInHint,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.of(context).textPrimary,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.icon(
                              onPressed: () => _goLogin(context),
                              icon: const Icon(Icons.login_rounded, size: 20),
                              label: const Text(QrLinkToolContent.signInToGenerate),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  TextField(
                    controller: _controller,
                    enabled: signedIn && !_loading,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    onSubmitted: signedIn ? (_) => _generate() : null,
                    decoration: InputDecoration(
                      labelText: 'Link to encode',
                      hintText: QrLinkToolContent.hintUrl,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFB),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      PrimaryAppButton(
                        label: QrLinkToolContent.ctaGenerate,
                        onPressed: signedIn && !_loading ? _generate : null,
                        icon: Icons.qr_code_2_rounded,
                        minimumSize: const Size(160, 48),
                      ),
                      if (_loading)
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      Text(
                        '${QrLinkToolContent.payToUnlockLabel(price)} · one-time',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.of(context).textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  if (_encoded != null) ...[
                    if (_watermarked) ...[
                      const SizedBox(height: 16),
                      _TrialBanner(
                        message: QrLinkToolContent.trialUsedWatermarkHint,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Center(
                      child: _QrWithOptionalWatermark(
                        data: _encoded!,
                        size: qrSize,
                        watermarked: _watermarked,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      _encoded!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.of(context).textSecondary.withValues(alpha: 0.95)),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TextButton(
                          onPressed: _clearQr,
                          child: Text(QrLinkToolContent.clearQrLabel),
                        ),
                        SecondaryOutlinedButton(
                          label: QrLinkToolContent.payToUnlockLabel(price),
                          onPressed: () => _unlock(context),
                          icon: Icons.lock_open_rounded,
                          minimumSize: const Size(200, 48),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TrialBanner extends StatelessWidget {
  const _TrialBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.of(context).textPrimary.withValues(alpha: 0.92),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrWithOptionalWatermark extends StatelessWidget {
  const _QrWithOptionalWatermark({
    required this.data,
    required this.size,
    required this.watermarked,
  });

  final String data;
  final double size;
  final bool watermarked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.of(context).border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          QrImageView(
            data: data,
            version: QrVersions.auto,
            size: size,
            gapless: true,
            backgroundColor: Colors.white,
          ),
          if (watermarked)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ColoredBox(
                  color: Colors.white.withValues(alpha: 0.78),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Transform.rotate(
                        angle: -0.28,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            QrLinkToolContent.watermarkBanner,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              height: 1.15,
                              color: AppColors.primary.withValues(alpha: 0.88),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
