import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../theme/app_colors.dart';
import '../utils/guest_link_parser.dart';

/// Opens the device camera to read a guest gallery QR (payload is guest URL or slug).
class GuestQrScanPage extends StatefulWidget {
  const GuestQrScanPage({super.key});

  @override
  State<GuestQrScanPage> createState() => _GuestQrScanPageState();
}

class _GuestQrScanPageState extends State<GuestQrScanPage> {
  var _handled = false;
  MobileScannerController? _controller;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = MobileScannerController();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _tryNavigate(String? raw) {
    if (_handled || raw == null || raw.isEmpty) return;
    final slug = GuestLinkParser.parseSlug(raw);
    if (slug == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This QR is not a valid Event Camshot guest link.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    _handled = true;
    _controller?.stop();
    context.go('/e/$slug');
  }

  void _onDetect(BarcodeCapture capture) {
    for (final b in capture.barcodes) {
      final v = b.rawValue ?? b.displayValue;
      _tryNavigate(v);
      if (_handled) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Scan guest QR'),
      ),
      body: kIsWeb
          ? _WebPasteFallback(onSubmit: _tryNavigate)
          : _ScannerBody(
              controller: _controller!,
              onDetect: _onDetect,
            ),
    );
  }
}

class _ScannerBody extends StatelessWidget {
  const _ScannerBody({
    required this.controller,
    required this.onDetect,
  });

  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: controller,
          onDetect: onDetect,
          errorBuilder: (context, error) => _ScanError(
            message: error.errorDetails?.message ?? error.toString(),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Align the guest QR in the frame. We open the gallery as soon as it reads.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, height: 1.35),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanError extends StatelessWidget {
  const _ScanError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_outlined, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Camera unavailable',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Back to paste link'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Web often blocks or limits camera scanning; offer paste instead.
class _WebPasteFallback extends StatefulWidget {
  const _WebPasteFallback({required this.onSubmit});

  final void Function(String?) onSubmit;

  @override
  State<_WebPasteFallback> createState() => _WebPasteFallbackState();
}

class _WebPasteFallbackState extends State<_WebPasteFallback> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.qr_code_2_rounded, size: 56, color: AppColors.primary.withValues(alpha: 0.85)),
          const SizedBox(height: 16),
          Text(
            'Paste your guest link',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            'QR scanning from the camera is limited in the browser. '
            'Paste the same link or code you would open from the QR.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: 'Guest link or code',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => widget.onSubmit(_ctrl.text),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Open gallery'),
          ),
        ],
      ),
    );
  }
}
