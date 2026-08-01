import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppGuardLogo extends StatelessWidget {
  const AppGuardLogo({super.key, this.size = 32, this.alert = false});

  final double size;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final color = alert ? AppColors.alert : AppColors.cyan;
    if (!alert) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * .2),
        child: Image.asset(
          'assets/images/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        border: Border.all(color: color.withValues(alpha: .5)),
        borderRadius: BorderRadius.circular(size * .2),
      ),
      child: Icon(Icons.shield_outlined, color: color, size: size * .62),
    );
  }
}
