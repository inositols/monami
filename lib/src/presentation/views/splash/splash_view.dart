import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Consumer;
import 'package:monami/src/shared/base_scaffold.dart';
import 'package:monami/src/shared/monami_logo.dart';
import 'package:monami/src/utils/constants/app_colors.dart';

import 'splash_view_model.dart';

class SplashView extends StatelessWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      backgroundColor: AppColor.bgColor,
      builder: (_) {
        return SizedBox.expand(
          child: Consumer(
            builder: (_, ref, __) {
              ref.read(splashViewModelProvider);
              return const Center(
                child: MonamiLogo(),
              );
            },
          ),
        );
      },
    );
  }
}
