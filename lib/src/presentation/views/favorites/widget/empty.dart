// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monami/src/presentation/widgets/custom_button.dart';

class EmptyState extends StatelessWidget {
  final Animation<Offset>? slideAnimation;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback onButtonTap;

  const EmptyState({
    super.key,
    this.slideAnimation,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    required this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 60,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF718096),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(
            onPressed: onButtonTap,
            text: "Start Shopping",
            textColor: Colors.white,
            gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
            radius: 16,
            width: 180,
            height: 54,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ],
      ),
    );

    return slideAnimation != null
        ? SlideTransition(position: slideAnimation!, child: content)
        : content;
  }
}
