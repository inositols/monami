import 'package:flutter/material.dart'
    show
        Widget,
        StatelessWidget,
        Text,
        AppBar,
        BuildContext,
        PreferredSizeWidget,
        Colors,
        FontWeight,
        Key,
        Size,
        kToolbarHeight;

import 'package:google_fonts/google_fonts.dart';
import 'package:monami/views/onboarding/components/constants/app_color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool leading;
  final List<Widget> actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.leading = true,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: leading,
      title: Text(
        title,
        style: GoogleFonts.adamina(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColor.whiteColor,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
