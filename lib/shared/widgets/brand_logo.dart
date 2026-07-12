import 'package:flutter/material.dart';

import '../../core/branding/app_branding.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({this.size = 48, this.borderRadius = 8, super.key});

  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        AppBranding.logoAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
