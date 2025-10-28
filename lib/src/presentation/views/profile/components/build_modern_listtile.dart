import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

Widget buildModernListTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  Widget? trailing,
  bool isDestructive = false,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : const Color(0xFF667EEA).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF667EEA),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: isDestructive ? Colors.red : const Color(0xFF2D3748),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: const Color(0xFF718096),
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios,
            color: const Color(0xFF718096),
            size: 16,
          ),
    ),
  );
}
