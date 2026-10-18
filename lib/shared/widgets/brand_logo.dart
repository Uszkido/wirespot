import 'package:flutter/material.dart';

import '../../core/branding/app_branding.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({this.size = 48, this.borderRadius = 8, super.key});

  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      image: true,
      label: AppBranding.appName,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        height: size,
        decoration: BoxDecoration(
          // The logo artwork uses a deep navy field. A theme-aware frame keeps
          // it legible and visually integrated when the app switches themes.
          color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(
              alpha: isDark ? 0.35 : 0.7,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: isDark ? 0.22 : 0.10),
              blurRadius: isDark ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          AppBranding.logoAsset,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
