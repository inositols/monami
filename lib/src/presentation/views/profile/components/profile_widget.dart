import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monami/src/handlers/handlers.dart';
import 'package:monami/src/presentation/views/profile/components/about_us.dart';
import 'package:monami/src/presentation/views/profile/components/build_modern_listtile.dart';
import 'package:monami/src/presentation/views/profile/profile_dialogs.dart';
import 'package:monami/src/utils/router/locator.dart';
import 'package:monami/src/utils/router/route_name.dart';

import '../profile_content.dart' show changeProfilePicture, buildSection;

class ProfileWidget extends StatelessWidget {
  final Map<String, dynamic> userProfile;
  final WidgetRef ref;
  final Future<Map<String, dynamic>?> Function() loadUserProfile;
  const ProfileWidget(
      {super.key,
      required this.userProfile,
      required this.ref,
      required this.loadUserProfile});

  @override
  Widget build(BuildContext context) {
    final navigationService = locator<NavigationService>();
    final snackbarHandler = locator<SnackbarHandler>();
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
                              onTap: () {
                                navigationService
                                    .pushNamed(Routes.notificationsRoute);
                              },
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
                              onTap: () => changeProfilePicture(context),
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
                  buildSection(
                    title: "Profile",
                    items: [
                      buildModernListTile(
                        icon: Icons.person_outline,
                        title: "Edit Personal Info",
                        subtitle: "Update your personal information",
                        onTap: () async {
                          final result = await navigationService.pushNamed(
                            Routes.editProfileRoute,
                          );
                          // Refresh profile data when returning
                          if (result == true || result == null) {
                            await loadUserProfile();
                          }
                        },
                      ),
                      buildModernListTile(
                        icon: Icons.favorite_outline,
                        title: "Wishlist",
                        subtitle: "View your saved items",
                        onTap: () {
                          navigationService.pushNamed(Routes.favoritesRoute);
                        },
                      ),
                      buildModernListTile(
                        icon: Icons.shopping_bag_outlined,
                        title: "Order History",
                        subtitle: "Track your orders",
                        onTap: () {
                          navigationService.pushNamed(Routes.orderHistoryRoute);
                        },
                      ),
                      buildModernListTile(
                        icon: Icons.dashboard_outlined,
                        title: "My Dashboard",
                        subtitle: "View your created products",
                        onTap: () {
                          navigationService
                              .pushNamed(Routes.userDashboardRoute);
                        },
                      ),
                      buildModernListTile(
                        icon: Icons.add_box_outlined,
                        title: "Create Product",
                        subtitle: "Add new product to the store",
                        onTap: () async {
                          final result = await navigationService.pushNamed(
                            Routes.createProductRoute,
                          );
                          if (result == true) {
                            snackbarHandler.showSnackbar(
                              'Product created successfully! Check the home screen.',
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // General Section
                  buildSection(
                    title: "General",
                    items: [
                      // buildModernListTile(
                      //   icon: Icons.notifications_none,
                      //   title: "Notifications",
                      //   subtitle: "Manage your notifications",
                      //   onTap: _manageNotifications,
                      // ),
                      buildModernListTile(
                        icon: Icons.help_outline,
                        title: "Help & Support",
                        subtitle: "Get help and contact support",
                        onTap: () => showHelpSupport(context),
                      ),
                      buildModernListTile(
                        icon: Icons.info_outline,
                        title: "About",
                        subtitle: "App version and information",
                        onTap: () => showAbout(context),
                      ),
                      buildModernListTile(
                        icon: Icons.logout,
                        title: "Log Out",
                        subtitle: "Sign out of your account",
                        onTap: () => logout(context),
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
}
