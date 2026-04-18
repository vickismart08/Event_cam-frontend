import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/glamora_brand_assets.dart';
import '../widgets/qr_any_link_tool.dart';
import '../widgets/responsive_container.dart';

/// Stand-alone page that wraps [QrAnyLinkTool] for the dashboard route.
class QrGeneratorPage extends StatelessWidget {
  const QrGeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const GlamoraAppBarTitle(title: 'Generate QR code'),
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          maxWidth: 780,
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 48),
          child: const QrAnyLinkTool(),
        ),
      ),
    );
  }
}
