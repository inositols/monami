import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monami/src/data/local/local_cache.dart';
import 'package:monami/src/data/remote/auth_service.dart';
import 'package:monami/src/handlers/handlers.dart';
import 'package:monami/src/utils/router/locator.dart';
import 'package:monami/src/utils/router/route_name.dart';

void showHelpSupport(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help & Support',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A202C),
                ),
              ),
              const SizedBox(height: 24),
              _buildHelpOption(
                icon: Icons.message_outlined,
                title: 'Chat Support',
                subtitle: 'Chat with our support team',
                onTap: () => showMessage('Chat support would open here'),
              ),
              _buildHelpOption(
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: 'Send us an email',
                onTap: () => showMessage('Email app would open here'),
              ),
              _buildHelpOption(
                icon: Icons.phone_outlined,
                title: 'Call Support',
                subtitle: 'Call our support hotline',
                onTap: () => showMessage('Phone dialer would open here'),
              ),
              _buildHelpOption(
                icon: Icons.help_outline,
                title: 'FAQ',
                subtitle: 'Frequently asked questions',
                onTap: () => showMessage('FAQ page would open here'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildHelpOption({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: ListTile(
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF667EEA).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF667EEA),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A202C),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF718096),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFF718096),
      ),
    ),
  );
}

void logout(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Log Out',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A202C),
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF718096),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF718096),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Sign out using AuthService
                await _authService.logout();

                // Clear all local data using LocalCache
                await _localCache.clearAllData();

                // Navigate to onboarding using NavigationService
                _navigationService.pushNamedAndRemoveUntil(
                  Routes.onboardingRoute,
                  Routes.splashScreenViewRoute,
                );

                _snackbarHandler.showSnackbar('Logged out successfully');
              } catch (e) {
                print('Error during logout: $e');
                _snackbarHandler.showErrorSnackbar(
                    'Error during logout. Please try again.');
              }
            },
            child: Text(
              'Log Out',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      );
    },
  );
}

void showMessage(String message) {
  _snackbarHandler.showSnackbar(message);
}

final _authService = locator<AuthService>();
final _localCache = locator<LocalCache>();
final _navigationService = locator<NavigationService>();
final _snackbarHandler = locator<SnackbarHandler>();
