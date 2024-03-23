import 'package:flutter/material.dart';

import 'package:monami/src/resources/app_assets.dart';

class MonamiLogo extends StatelessWidget {
  final double? size;
  const MonamiLogo({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: size ?? 200,
        width: size ?? 200,
        decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                fit: BoxFit.fill, image: AppAssets.monamiLogo)));
  }
}
