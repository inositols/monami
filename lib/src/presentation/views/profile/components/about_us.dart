import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showAbout(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'About Monami',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A202C),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version: 1.0.0',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A modern e-commerce app with beautiful UI and smooth user experience.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2024 Monami. All rights reserved.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF667EEA),
              ),
            ),
          ),
        ],
      );
    },
  );
}
