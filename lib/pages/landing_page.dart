import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../config/app_links.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../widgets/app_buttons.dart';
import '../widgets/mock_qr_placeholder.dart';
import '../widgets/responsive_container.dart';
import '../widgets/section_header.dart';
import '../widgets/soft_card.dart';
import 'host_dashboard_page.dart';
import 'login_page.dart';
import 'sign_up_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

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
      listenable: authController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HeroGradientShell(
                  child: ResponsiveContainer(
                    maxWidth: 1180,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TopBar(
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
                        SizedBox(height: isWide ? 64 : 48),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 24,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ResponsiveContainer(
                    maxWidth: 1180,
                    padding: const EdgeInsets.fromLTRB(20, 44, 20, 40),
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
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 48),
                  child: Center(
                    child: Text(
                      '© ${DateTime.now().year} Event Camshot',
                      style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.8), fontSize: 13),
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

class _HeroGradientShell extends StatelessWidget {
  const _HeroGradientShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF8F8),
            Color(0xFFF9FAFB),
            AppColors.background,
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: child,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onJoin,
    required this.onHostSignIn,
    required this.onHostGallery,
    required this.onHostSignOut,
  });

  final VoidCallback onJoin;
  final VoidCallback onHostSignIn;
  final VoidCallback onHostGallery;
  final VoidCallback onHostSignOut;

  @override
  Widget build(BuildContext context) {
    final signedIn = authController.host != null;

    final logo = Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Event Camshot',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 4,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        TextButton(onPressed: onJoin, child: const Text('Join as guest')),
        if (!signedIn) ...[
          TextButton(onPressed: onHostSignIn, child: const Text('Host sign in')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => const SignUpPage()),
              );
            },
            child: const Text('Get started'),
          ),
        ] else ...[
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onHostGallery,
            child: const Text('Dashboard'),
          ),
          TextButton(onPressed: onHostSignOut, child: const Text('Sign out')),
        ],
      ],
    );

    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              logo,
              const SizedBox(height: 14),
              actions,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: logo),
            actions,
          ],
        );
      },
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
                      color: AppColors.textPrimary,
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
                color: AppColors.textSecondary,
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
                color: AppColors.textPrimary,
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
              color: AppColors.textSecondary.withValues(alpha: 0.95),
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
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
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
