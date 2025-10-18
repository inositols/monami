import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monami/src/data/remote/notification_service.dart';
import 'package:monami/src/presentation/views/onboarding/onboarding_view.dart';
import 'package:monami/src/data/state/constants/firebase_collection.dart';
import 'package:monami/src/data/state/constants/firebase_field_name.dart';
import 'package:monami/src/handlers/handlers.dart';
import 'package:monami/src/data/local/local_cache.dart';
import 'package:monami/src/data/remote/auth_service.dart';
import 'package:monami/src/utils/router/locator.dart';
import 'package:monami/src/utils/router/route_name.dart';
import '../../../services/storage_service.dart';
import '../favorites/favorites_view.dart';
import '../product/create_product_view.dart';
import '../dashboard/user_dashboard_view.dart';
import 'edit_profile_view.dart';
import 'order_history_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool biometricLogin = true;
  bool biometricTransaction = true;
  bool notificationsEnabled = true;
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  // Service instances
  late final NavigationService _navigationService =
      locator<NavigationService>();
  late final SnackbarHandler _snackbarHandler = locator<SnackbarHandler>();
  late final LocalCache _localCache = locator<LocalCache>();
  late final AuthService _authService = locator<AuthService>();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // First try to get user from AuthService
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        if (mounted) {
          setState(() {
            userProfile = {
              'id': currentUser.userId,
              'name': currentUser.displayName ?? 'User',
              'email': currentUser.email ?? 'user@email.com',
              'phone': currentUser.phoneNumber ?? '',
              'status': currentUser.status ?? 'active',
              'role': currentUser.role ?? 'user',
              'lastLogin': DateTime.now().toIso8601String(),
            };
            isLoading = false;
          });
        }
        return;
      }

      // Fallback to Firebase Auth user
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        print('No Firebase user found');
        return;
      }

      // Get user details from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.users)
          .where(FirebaseFieldName.userId, isEqualTo: firebaseUser.uid)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first.data();
        if (mounted) {
          setState(() {
            userProfile = {
              'id': userData[FirebaseFieldName.userId],
              'name': userData[FirebaseFieldName.displayName] ?? 'User',
              'email': userData[FirebaseFieldName.email] ??
                  firebaseUser.email ??
                  'user@email.com',
              'phone': userData[FirebaseFieldName.phoneNumber] ?? '',
              'status': userData[FirebaseFieldName.status] ?? 'active',
              'role': userData[FirebaseFieldName.role] ?? 'user',
              'lastLogin': DateTime.now().toIso8601String(),
            };
            isLoading = false;
          });
        }
      } else {
        print('User not found in Firestore');
        // Fallback to Firebase Auth user data
        if (mounted) {
          setState(() {
            userProfile = {
              'id': firebaseUser.uid,
              'name': firebaseUser.displayName ?? 'User',
              'email': firebaseUser.email ?? 'user@email.com',
              'phone': firebaseUser.phoneNumber ?? '',
              'status': 'active',
              'role': 'user',
              'lastLogin': DateTime.now().toIso8601String(),
            };
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user profile from Firebase: $e');
      // Fallback to local storage
      try {
        final profile = await StorageService.getUserProfile();
        if (mounted) {
          setState(() {
            userProfile = profile;
            isLoading = false;
          });
        }
      } catch (fallbackError) {
        print('Error loading user profile from local storage: $fallbackError');
        _snackbarHandler.showErrorSnackbar('Failed to load user profile');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: null,
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667EEA),
                      Color(0xFF764BA2),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Header with notifications
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Profile",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 28,
                                color: Colors.white,
                              ),
                            ),
                            GestureDetector(
                              onTap: _showNotifications,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                child: const Icon(Icons.notifications_outlined,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Profile Avatar
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 56,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: const Icon(Icons.person,
                                  color: Colors.white, size: 40),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _changeProfilePicture,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.camera_alt,
                                    color: Color(0xFF667EEA), size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // User Name
                      Column(
                        children: [
                          Text(
                            userProfile?['name'] ?? 'User',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userProfile?['email'] ?? 'user@email.com',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Section
                  _buildSection(
                    title: "Profile",
                    items: [
                      _buildModernListTile(
                        icon: Icons.person_outline,
                        title: "Edit Personal Info",
                        subtitle: "Update your personal information",
                        onTap: () async {
                          final result = await _navigationService.pushNamed(
                            Routes.editProfileRoute,
                          );
                          // Refresh profile data when returning
                          if (result == true || result == null) {
                            await _loadUserProfile();
                          }
                        },
                      ),
                      _buildModernListTile(
                        icon: Icons.favorite_outline,
                        title: "Wishlist",
                        subtitle: "View your saved items",
                        onTap: () {
                          _navigationService.pushNamed(Routes.favoritesRoute);
                        },
                      ),
                      _buildModernListTile(
                        icon: Icons.shopping_bag_outlined,
                        title: "Order History",
                        subtitle: "Track your orders",
                        onTap: () {
                          _navigationService
                              .pushNamed(Routes.orderHistoryRoute);
                        },
                      ),
                      _buildModernListTile(
                        icon: Icons.dashboard_outlined,
                        title: "My Dashboard",
                        subtitle: "View your created products",
                        onTap: () {
                          _navigationService
                              .pushNamed(Routes.userDashboardRoute);
                        },
                      ),
                      _buildModernListTile(
                        icon: Icons.add_box_outlined,
                        title: "Create Product",
                        subtitle: "Add new product to the store",
                        onTap: () async {
                          final result = await _navigationService.pushNamed(
                            Routes.createProductRoute,
                          );
                          if (result == true && mounted) {
                            _snackbarHandler.showSnackbar(
                              'Product created successfully! Check the home screen.',
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // General Section
                  _buildSection(
                    title: "General",
                    items: [
                      _buildModernListTile(
                        icon: Icons.notifications_none,
                        title: "Notifications",
                        subtitle: "Manage your notifications",
                        onTap: _manageNotifications,
                      ),
                      _buildModernListTile(
                        icon: Icons.bug_report,
                        title: "Test Notification",
                        subtitle: "Send a test notification",
                        onTap: _testNotification,
                      ),
                      _buildModernListTile(
                        icon: Icons.help_outline,
                        title: "Help & Support",
                        subtitle: "Get help and contact support",
                        onTap: _showHelpSupport,
                      ),
                      _buildModernListTile(
                        icon: Icons.info_outline,
                        title: "About",
                        subtitle: "App version and information",
                        onTap: _showAbout,
                      ),
                      _buildModernListTile(
                        icon: Icons.logout,
                        title: "Log Out",
                        subtitle: "Sign out of your account",
                        onTap: _logout,
                        isDestructive: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: const Color(0xFF2D3748),
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildModernListTile({
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

  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Change Profile Picture',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildImageOption(
                        icon: Icons.camera_alt,
                        title: 'Camera',
                        onTap: () {
                          Navigator.pop(context);
                          _showMessage('Camera would open here');
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildImageOption(
                        icon: Icons.photo_library,
                        title: 'Gallery',
                        onTap: () {
                          Navigator.pop(context);
                          _showMessage('Gallery would open here');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF667EEA).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF667EEA),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF667EEA),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    _navigationService.pushNamed(Routes.notificationsRoute);
  }

  void _testNotification() async {
    try {
      final notificationService = NotificationService();
      await notificationService.sendTestNotification();
      _snackbarHandler.showSnackbar('Test notification sent!');
    } catch (e) {
      _snackbarHandler.showErrorSnackbar('Error sending test notification: $e');
    }
  }

  void _manageNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Notification Settings',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A202C),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: Text(
                      'Push Notifications',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Receive notifications about orders',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF718096),
                      ),
                    ),
                    value: notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        notificationsEnabled = value;
                      });
                    },
                    activeColor: const Color(0xFF667EEA),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Done',
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
      },
    );
  }

  void _showHelpSupport() {
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
                  onTap: () => _showMessage('Chat support would open here'),
                ),
                _buildHelpOption(
                  icon: Icons.email_outlined,
                  title: 'Email Support',
                  subtitle: 'Send us an email',
                  onTap: () => _showMessage('Email app would open here'),
                ),
                _buildHelpOption(
                  icon: Icons.phone_outlined,
                  title: 'Call Support',
                  subtitle: 'Call our support hotline',
                  onTap: () => _showMessage('Phone dialer would open here'),
                ),
                _buildHelpOption(
                  icon: Icons.help_outline,
                  title: 'FAQ',
                  subtitle: 'Frequently asked questions',
                  onTap: () => _showMessage('FAQ page would open here'),
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

  void _showAbout() {
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

  void _logout() {
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

  void _showMessage(String message) {
    _snackbarHandler.showSnackbar(message);
  }
}
