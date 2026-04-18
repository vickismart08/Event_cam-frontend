import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../config/app_brand.dart';
import 'qr_png_export_stub.dart' if (dart.library.html) 'qr_png_export_web.dart' as web_save;

/// Renders [RepaintBoundary] to a PNG — sharp enough for print; works on web (download) and
/// mobile (share sheet → Save image / Drive / etc.).
Future<void> exportQrPngFromBoundary({
  required GlobalKey boundaryKey,
  required BuildContext context,
  String filename = 'glamora-qr.png',
}) async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
  if (!context.mounted) return;

  final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    throw StateError('QR is not ready to export yet.');
  }

  final dpr = MediaQuery.devicePixelRatioOf(context);
  final pixelRatio = (dpr * 2.5).clamp(2.5, 4.0);
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  if (byteData == null) {
    throw StateError('Could not encode PNG.');
  }

  final bytes = byteData.buffer.asUint8List(
    byteData.offsetInBytes,
    byteData.lengthInBytes,
  );

  if (kIsWeb) {
    await web_save.downloadPngBytesWeb(bytes, filename);
  } else {
    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          name: filename,
          mimeType: 'image/png',
        ),
      ],
      subject: '${AppBrand.displayName} QR',
    );
  }
}
