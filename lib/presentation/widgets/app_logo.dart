import 'package:flutter/material.dart';
import 'package:woodescape/core/constants/app_images.dart';

class BuildLogo extends StatelessWidget {
  const BuildLogo({super.key, this.size = 120});

  final double? size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(AppImages.logo, height: size, width: size),
    );
  }
}
