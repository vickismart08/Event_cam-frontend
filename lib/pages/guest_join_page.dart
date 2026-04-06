import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../utils/guest_link_parser.dart';
import '../widgets/app_buttons.dart';
import '../widgets/responsive_container.dart';
import '../widgets/soft_card.dart';

/// Asks guests for a gallery link or sends them to scan a QR before upload.
class GuestJoinPage extends StatefulWidget {
  const GuestJoinPage({super.key});

  @override
  State<GuestJoinPage> createState() => _GuestJoinPageState();
}

class _GuestJoinPageState extends State<GuestJoinPage> {
  final _link = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  void _continueWithSlug() {
    final slug = GuestLinkParser.parseSlug(_link.text);
    if (slug == null) {
      setState(() {
        _errorText =
            'Paste a full guest link (with /e/…) or the join code from your host.';
      });
      return;
    }
    setState(() => _errorText = null);
    context.go('/e/$slug');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Join a gallery'),
      ),
      body: ResponsiveContainer(
        maxWidth: 520,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Private guest gallery',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                'Your host shared a link or QR for this event. '
                'Paste the gallery link below, or scan the QR code — then you can add photos to their gallery.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 28),
              SoftCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Gallery link',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Example: https://yoursite.com/e/summer-wedding-2026',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _link,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (_) => _continueWithSlug(),
                      decoration: InputDecoration(
                        hintText: 'Paste guest link or join code',
                        errorText: _errorText,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      onChanged: (_) {
                        if (_errorText != null) setState(() => _errorText = null);
                      },
                    ),
                    const SizedBox(height: 20),
                    PrimaryAppButton(
                      label: 'Continue to upload',
                      onPressed: _continueWithSlug,
                      icon: Icons.arrow_forward_rounded,
                      minimumSize: const Size(double.infinity, 52),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.border.withValues(alpha: 0.9))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text('or', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  ),
                  Expanded(child: Divider(color: AppColors.border.withValues(alpha: 0.9))),
                ],
              ),
              const SizedBox(height: 28),
              SecondaryOutlinedButton(
                label: 'Scan QR code',
                icon: Icons.qr_code_scanner_rounded,
                onPressed: () => context.push('/join/scan'),
                minimumSize: const Size(double.infinity, 52),
              ),
              const SizedBox(height: 12),
              Text(
                'Point your camera at the QR on the invitation or signage. '
                'On some browsers you may need to paste the link instead.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
