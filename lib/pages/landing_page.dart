import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../config/app_links.dart';
import '../config/app_brand.dart';
import '../config/pro_plan_content.dart';
import '../config/qr_link_tool_content.dart';
import '../pricing/pricing_region_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_buttons.dart';
import '../widgets/mock_qr_placeholder.dart';
import '../widgets/responsive_container.dart';
import '../widgets/section_header.dart';
import '../widgets/qr_any_link_tool.dart';
import '../widgets/soft_card.dart';
import 'host_dashboard_page.dart';
import 'login_page.dart';
import 'sign_up_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final GlobalKey _qrToolSectionKey = GlobalKey();

  void _scrollToQrTool() {
    final ctx = _qrToolSectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
        alignment: 0.12,
      );
    }
  }

  void _openGuestJoin(BuildContext context) {
    context.push('/join');
  }

  void _openHostSignIn(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    );
  }

  void _openHostGallery(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const HostDashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w >= 1000;
    final landingQrUrl = AppLinks.baseUrl();

    return ListenableBuilder(
      listenable: Listenable.merge([authController, pricingRegionController]),
      builder: (context, _) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HeroGradientShell(
                  child: ResponsiveContainer(
                    maxWidth: 1180,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _LandingNavBar(
                          onQrForAnyLink: _scrollToQrTool,
                          onJoin: () => _openGuestJoin(context),
                          onHostSignIn: () => _openHostSignIn(context),
                          onHostGallery: () => _openHostGallery(context),
                          onHostSignOut: () => authController.signOut(),
                        ),
                        SizedBox(height: isWide ? 52 : 36),
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 55,
                                child: _HeroCopyBlock(
                                  onCreate: () => _openHostSignIn(context),
                                  onJoin: () => _openGuestJoin(context),
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                flex: 45,
                                child: _GuestPreviewCard(
                                  landingQrUrl: landingQrUrl,
                                  isWide: true,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _HeroCopyBlock(
                            onCreate: () => _openHostSignIn(context),
                            onJoin: () => _openGuestJoin(context),
                          ),
                          const SizedBox(height: 28),
                          _GuestPreviewCard(
                            landingQrUrl: landingQrUrl,
                            isWide: false,
                          ),
                        ],
                        SizedBox(height: isWide ? 80 : 56),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Builder(
                builder: (context) {
                  final cs = Theme.of(context).colorScheme;
                  return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 24,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ResponsiveContainer(
                    maxWidth: 1180,
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionHeader(
                          title: 'How it works',
                          subtitle:
                              'One link for every guest. No accounts, no friction — just memories in one place.',
                        ),
                        const SizedBox(height: 28),
                        LayoutBuilder(
                          builder: (context, c) {
                            final row = c.maxWidth >= 840;
                            if (row) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _HowStepCard(step: '1', icon: Icons.event_rounded, title: 'Create your event', body: 'Add the name, date, and venue. Turn moderation on if you want to approve shots before they go live.')),
                                  const SizedBox(width: 18),
                                  Expanded(child: _HowStepCard(step: '2', icon: Icons.qr_code_2_rounded, title: 'Share link or QR', body: 'Print a QR for signage or drop the guest link in your invite. Each event gets its own unique URL.')),
                                  const SizedBox(width: 18),
                                  Expanded(child: _HowStepCard(step: '3', icon: Icons.photo_library_rounded, title: 'Watch the gallery grow', body: 'Guests upload from their phones. You review if needed, then enjoy a single beautiful gallery.')),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                _HowStepCard(step: '1', icon: Icons.event_rounded, title: 'Create your event', body: 'Add the name, date, and venue. Turn moderation on if you want to approve shots before they go live.'),
                                const SizedBox(height: 16),
                                _HowStepCard(step: '2', icon: Icons.qr_code_2_rounded, title: 'Share link or QR', body: 'Print a QR for signage or drop the guest link in your invite. Each event gets its own unique URL.'),
                                const SizedBox(height: 16),
                                _HowStepCard(step: '3', icon: Icons.photo_library_rounded, title: 'Watch the gallery grow', body: 'Guests upload from their phones. You review if needed, then enjoy a single beautiful gallery.'),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 56),
                        KeyedSubtree(
                          key: _qrToolSectionKey,
                          child: const QrAnyLinkTool(),
                        ),
                        const SizedBox(height: 56),
                        SectionHeader(
                          title: ProPlanContent.headline,
                          subtitle: ProPlanContent.subtitle,
                        ),
                        const SizedBox(height: 24),
                        const _ProPricingSection(),
                      ],
                    ),
                  ),
                );
                },
              ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 64),
                  child: Center(
                    child: Text(
                      AppBrand.copyrightLine,
                      style: TextStyle(color: AppColors.of(context).textSecondary.withValues(alpha: 0.8), fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Soft gradient behind the landing hero — adapts to light / dark mode.
class _HeroGradientShell extends StatelessWidget {
  const _HeroGradientShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? const [Color(0xFF1A0D0D), Color(0xFF161620), AppColors.darkBackground]
        : const [Color(0xFFFFF8F8), Color(0xFFF9FAFB), AppColors.background];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Full-width landing nav: logo + "Glamora" on the left, nav links on the right.
/// On narrow screens the links wrap below the logo.
class _LandingNavBar extends StatelessWidget {
  const _LandingNavBar({
    required this.onQrForAnyLink,
    required this.onJoin,
    required this.onHostSignIn,
    required this.onHostGallery,
    required this.onHostSignOut,
  });

  final VoidCallback onQrForAnyLink;
  final VoidCallback onJoin;
  final VoidCallback onHostSignIn;
  final VoidCallback onHostGallery;
  final VoidCallback onHostSignOut;

  @override
  Widget build(BuildContext context) {
    final signedIn = authController.host != null;
    final w = MediaQuery.sizeOf(context).width;
    final narrow = w < 640;

    final brand = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppBrand.logoIconAsset,
          width: narrow ? 38 : 46,
          height: narrow ? 38 : 46,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          gaplessPlayback: true,
          errorBuilder: (context, e, _) =>
              Icon(Icons.photo_camera_rounded, size: narrow ? 38 : 46, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          AppBrand.displayName,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: narrow ? 20 : 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: AppColors.of(context).textPrimary,
            height: 1,
          ),
        ),
      ],
    );

    final links = Wrap(
      spacing: 2,
      runSpacing: 6,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ListenableBuilder(
          listenable: themeController,
          builder: (context, _) => IconButton(
            tooltip: themeController.isDark ? 'Switch to light mode' : 'Switch to dark mode',
            icon: Icon(
              themeController.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 20,
            ),
            onPressed: themeController.toggle,
          ),
        ),
        Tooltip(
          message: QrLinkToolContent.title,
          child: TextButton.icon(
            onPressed: onQrForAnyLink,
            icon: Icon(Icons.qr_code_2_rounded, size: 17, color: AppColors.primary),
            label: Text(
              narrow ? 'QR link' : QrLinkToolContent.navLinkLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.of(context).textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
        ),
        TextButton(
          onPressed: onJoin,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.of(context).textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          child: const Text('Join as guest'),
        ),
        if (!signedIn) ...[
          TextButton(
            onPressed: onHostSignIn,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.of(context).textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            child: const Text('Sign in'),
          ),
          const SizedBox(width: 4),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: narrow ? 14 : 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => const SignUpPage()),
              );
            },
            child: const Text('Get started', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ] else ...[
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: onHostGallery,
            child: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: onHostSignOut,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.of(context).textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            child: const Text('Sign out'),
          ),
        ],
      ],
    );

    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [brand, const SizedBox()],
          ),
          const SizedBox(height: 10),
          links,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        brand,
        const Spacer(),
        links,
      ],
    );
  }
}

class _HeroCopyBlock extends StatelessWidget {
  const _HeroCopyBlock({required this.onCreate, required this.onJoin});

  final VoidCallback onCreate;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, size: 16, color: Colors.amber.shade900),
              const SizedBox(width: 6),
              Text(
                'Live guest uploads • Shared gallery',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.of(context).textPrimary,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Every guest photo.\nOne beautiful gallery.',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: MediaQuery.sizeOf(context).width >= 600 ? 44 : 34,
              ),
        ),
        const SizedBox(height: 18),
        Text(
          'Collect wedding and party photos without chasing people for Dropbox links. '
          'Guests open your link or scan a QR — no app install required.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 17,
                color: AppColors.of(context).textSecondary,
              ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: const [
            _MiniFeature(icon: Icons.groups_rounded, label: 'Unlimited guests'),
            _MiniFeature(icon: Icons.link_rounded, label: 'Unique event link'),
            _MiniFeature(icon: Icons.verified_user_outlined, label: 'Optional moderation'),
          ],
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            PrimaryAppButton(
              label: 'Create an event',
              onPressed: onCreate,
              icon: Icons.add_rounded,
              minimumSize: const Size(168, 52),
            ),
            SecondaryOutlinedButton(
              label: 'Join to upload',
              onPressed: onJoin,
              icon: Icons.upload_rounded,
              minimumSize: const Size(168, 52),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniFeature extends StatelessWidget {
  const _MiniFeature({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.of(context).textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _GuestPreviewCard extends StatelessWidget {
  const _GuestPreviewCard({required this.landingQrUrl, required this.isWide});

  final String landingQrUrl;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.all(isWide ? 32 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Guest experience',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This is what signage could look like — scan opens the upload screen in the browser.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: isWide ? 28 : 22),
          Center(
            child: MockQrPlaceholder(
              size: isWide ? 210 : 176,
              showFrame: true,
              showCaption: false,
            ),
          ),
          const SizedBox(height: 16),
          SelectableText(
            landingQrUrl,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.of(context).textSecondary.withValues(alpha: 0.95),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Guests scan and upload instantly',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProPricingSection extends StatelessWidget {
  const _ProPricingSection();

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ProPlanContent.ctaComingSoonHint),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 720;
            final monthly = _ProTierPriceCard(
              tier: pricingRegionController.monthlyTier,
              emphasize: false,
              onCta: () => _comingSoon(context),
            );
            final yearly = _ProTierPriceCard(
              tier: pricingRegionController.yearlyTier,
              emphasize: true,
              onCta: () => _comingSoon(context),
            );
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: monthly),
                  const SizedBox(width: 20),
                  Expanded(child: yearly),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                monthly,
                const SizedBox(height: 16),
                yearly,
              ],
            );
          },
        ),
        const SizedBox(height: 36),
        Text(
          ProPlanContent.includedHeading,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        ...ProPlanContent.bullets.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ProBulletRow(bullet: b),
            )),
      ],
    );
  }
}

class _ProTierPriceCard extends StatelessWidget {
  const _ProTierPriceCard({
    required this.tier,
    required this.emphasize,
    required this.onCta,
  });

  final ProPricingTier tier;
  final bool emphasize;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final borderColor = emphasize ? AppColors.primary : colors.border.withValues(alpha: 0.7);
    final borderWidth = emphasize ? 2.0 : 1.0;
    final gradientBase = colors.surface;
    final gradientEnd = emphasize
        ? AppColors.primary.withValues(alpha: 0.06)
        : colors.surface.withValues(alpha: 0.85);

    return SoftCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: borderWidth),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientBase, gradientEnd],
          ),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PRO',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                  ),
                ),
                const SizedBox(width: 10),
                if (tier.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tier.badge!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.amber.shade900,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              tier.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  tier.priceDisplay,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.of(context).textPrimary,
                      ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    tier.periodLine,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tier.subLine,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            if (tier.savingsLine != null) ...[
              const SizedBox(height: 8),
              Text(
                tier.savingsLine!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onCta,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(tier.ctaLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProBulletRow extends StatelessWidget {
  const _ProBulletRow({required this.bullet});

  final ProPlanBullet bullet;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bullet.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
              ),
              if (bullet.detail != null && bullet.detail!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  bullet.detail!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HowStepCard extends StatelessWidget {
  const _HowStepCard({
    required this.step,
    required this.icon,
    required this.title,
    required this.body,
  });

  final String step;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border.withValues(alpha: 0.55)),
        boxShadow: AppShadows.card(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  step,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: AppColors.primary, size: 26),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
