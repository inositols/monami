import 'package:flutter/material.dart';

import 'empty_content_animation.dart';

class EmptyContentAnimationWihText extends StatelessWidget {
  final String text;
  const EmptyContentAnimationWihText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white54),
          ),
          // const EmptyContentAnimationView()
        ],
      ),
    );
  }
}
