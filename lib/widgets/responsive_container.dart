import 'package:flutter/material.dart';

class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1120,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  /// Album-style grid: 4 columns when there is room; fewer on narrow phones.
  static int galleryCrossAxisCount(double width) {
    if (width < 340) return 2;
    if (width < 420) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
