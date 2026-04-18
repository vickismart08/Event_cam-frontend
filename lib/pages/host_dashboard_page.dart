import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
import '../data/event_api_store.dart';
import '../theme/app_colors.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_buttons.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_card.dart';
import '../widgets/responsive_container.dart';
import '../widgets/glamora_brand_assets.dart';
import '../widgets/section_header.dart';
import 'event_editor_page.dart';
import 'event_hub_page.dart';
import 'landing_page.dart';
import 'login_page.dart';
import 'qr_generator_page.dart';

class HostDashboardPage extends StatefulWidget {
  const HostDashboardPage({super.key});

  @override
  State<HostDashboardPage> createState() => _HostDashboardPageState();
}

class _HostDashboardPageState extends State<HostDashboardPage> {
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await eventApiStore.loadDashboard();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([authController, eventApiStore]),
      builder: (context, _) {
        final email = authController.host?.email;
        final events = eventApiStore.eventsFor(email);

        return Scaffold(
          appBar: AppBar(
            title: const GlamoraAppBarTitle(title: 'Your events'),
            actions: [
              ListenableBuilder(
                listenable: themeController,
                builder: (context, _) => IconButton(
                  tooltip: themeController.isDark ? 'Light mode' : 'Dark mode',
                  icon: Icon(
                    themeController.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  ),
                  onPressed: themeController.toggle,
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const QrGeneratorPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_rounded, size: 18),
                label: const Text('QR code'),
              ),
              TextButton(
                onPressed: () async {
                  await authController.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil<void>(
                      MaterialPageRoute<void>(builder: (_) => const LandingPage()),
                      (_) => false,
                    );
                  }
                },
                child: const Text('Sign out'),
              ),
            ],
          ),
          body: email == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Sign in to manage events.'),
                      const SizedBox(height: 16),
                      PrimaryAppButton(
                        label: 'Sign in',
                        onPressed: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(builder: (_) => const LoginPage()),
                          );
                        },
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: ResponsiveContainer(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 28, bottom: 16),
                            child: SectionHeader(
                              title: 'Dashboard',
                              subtitle: 'Create an event and share the guest link or QR.',
                            ),
                          ),
                        ),
                      ),
                      if (_loading)
                        const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                      else if (events.isEmpty)
                        SliverFillRemaining(
                          child: EmptyState(
                            title: 'No events yet',
                            subtitle: 'Create your first event to get a guest upload link.',
                            icon: Icons.event_outlined,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList.separated(
                            itemCount: events.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final e = events[i];
                              return EventCard(
                                event: e,
                                onOpen: () {
                                  Navigator.of(context).push<void>(
                                    MaterialPageRoute<void>(
                                      builder: (_) => EventHubPage(
                                        ownerEmail: email,
                                        eventId: e.id,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 96)),
                    ],
                  ),
                ),
          floatingActionButton: email == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(builder: (_) => const EventEditorPage()),
                    );
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New event'),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
        );
      },
    );
  }
}
