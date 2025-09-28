import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = true;
  bool _locationEnabled = false;
  bool _autoBackupEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Settings Header
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Settings",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Customize your app experience",
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Settings Content
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Settings
                  _buildSettingsSection(
                    title: "Profile",
                    icon: Icons.person_outline,
                    items: [
                      _buildSettingsTile(
                        icon: Icons.visibility_off_outlined,
                        title: "Hide Profile",
                        subtitle: "Make your profile private",
                        trailing: CupertinoSwitch(
                          value: false,
                          onChanged: (value) {},
                          activeColor: const Color(0xFF667EEA),
                        ),
                      ),
                      _buildSettingsTile(
                        icon: Icons.edit_outlined,
                        title: "Edit Profile",
                        subtitle: "Update your personal information",
                        onTap: () {},
                      ),
                      _buildSettingsTile(
                        icon: Icons.security_outlined,
                        title: "Privacy Settings",
                        subtitle: "Control who can see your content",
                        onTap: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notifications Settings
                  _buildSettingsSection(
                    title: "Notifications",
                    icon: Icons.notifications_outlined,
                    items: [
                      _buildSettingsTile(
                        icon: Icons.notifications_active_outlined,
                        title: "Push Notifications",
                        subtitle: "Receive notifications on your device",
                        trailing: CupertinoSwitch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          },
                          activeColor: const Color(0xFF667EEA),
                        ),
                      ),
                      _buildSettingsTile(
                        icon: Icons.email_outlined,
                        title: "Email Notifications",
                        subtitle: "Get updates via email",
                        trailing: CupertinoSwitch(
                          value: true,
                          onChanged: (value) {},
                          activeColor: const Color(0xFF667EEA),
                        ),
                      ),
                      _buildSettingsTile(
                        icon: Icons.schedule_outlined,
                        title: "Notification Schedule",
                        subtitle: "Set quiet hours",
                        onTap: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Security Settings
                  _buildSettingsSection(
                    title: "Security",
                    icon: Icons.security_outlined,
                    items: [
                      _buildSettingsTile(
                        icon: Icons.fingerprint,
                        title: "Biometric Authentication",
                        subtitle: "Use fingerprint or face ID",
                        trailing: CupertinoSwitch(
                          value: _biometricEnabled,
                          onChanged: (value) {
                            setState(() {
                              _biometricEnabled = value;
                            });
                          },
                          activeColor: const Color(0xFF667EEA),
                        ),
                      ),
                      _buildSettingsTile(
                        icon: Icons.lock_outline,
                        title: "Change Password",
                        subtitle: "Update your account password",
                        onTap: () {},
                      ),
                      _buildSettingsTile(
                        icon: Icons.phonelink_lock_outlined,
                        title: "Two-Factor Authentication",
                        subtitle: "Add an extra layer of security",
                        onTap: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // App Settings
                  _buildSettingsSection(
                    title: "App Preferences",
                    icon: Icons.tune_outlined,
                    items: [
                      _buildSettingsTile(
                        icon: Icons.dark_mode_outlined,
                        title: "Dark Mode",
                        subtitle: "Switch to dark theme",
                        trailing: CupertinoSwitch(
                          value: _darkModeEnabled,
                          onChanged: (value) {
                            setState(() {
                              _darkModeEnabled = value;
                            });
                          },
                          activeColor: const Color(0xFF667EEA),
                        ),
                      ),
                      _buildSettingsTile(
                        icon: Icons.language_outlined,
                        title: "Language",
                        subtitle: "English",
                        onTap: () {},
                      ),
                      _buildSettingsTile(
                        icon: Icons.location_on_outlined,
                        title: "Location Services",
                        subtitle: "Allow location access",
                        trailing: CupertinoSwitch(
                          value: _locationEnabled,
                          onChanged: (value) {
                            setState(() {
                              _locationEnabled = value;
                            });
                          },
                          activeColor: const Color(0xFF667EEA),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Data & Storage
                  _buildSettingsSection(
                    title: "Data & Storage",
                    icon: Icons.storage_outlined,
                    items: [
                      _buildSettingsTile(
                        icon: Icons.backup_outlined,
                        title: "Auto Backup",
                        subtitle: "Automatically backup your data",
                        trailing: CupertinoSwitch(
                          value: _autoBackupEnabled,
                          onChanged: (value) {
                            setState(() {
                              _autoBackupEnabled = value;
                            });
                          },
                          activeColor: const Color(0xFF667EEA),
                        ),
                      ),
                      _buildSettingsTile(
                        icon: Icons.cloud_download_outlined,
                        title: "Download Quality",
                        subtitle: "High quality",
                        onTap: () {},
                      ),
                      _buildSettingsTile(
                        icon: Icons.delete_outline,
                        title: "Clear Cache",
                        subtitle: "Free up storage space",
                        onTap: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Support & About
                  _buildSettingsSection(
                    title: "Support & About",
                    icon: Icons.help_outline,
                    items: [
                      _buildSettingsTile(
                        icon: Icons.help_center_outlined,
                        title: "Help Center",
                        subtitle: "Get help and support",
                        onTap: () {},
                      ),
                      _buildSettingsTile(
                        icon: Icons.feedback_outlined,
                        title: "Send Feedback",
                        subtitle: "Share your thoughts with us",
                        onTap: () {},
                      ),
                      _buildSettingsTile(
                        icon: Icons.info_outline,
                        title: "About",
                        subtitle: "Version 1.0.0",
                        onTap: () {},
                      ),
                      _buildSettingsTile(
                        icon: Icons.logout,
                        title: "Sign Out",
                        subtitle: "Sign out of your account",
                        onTap: () {},
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
  
  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
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
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF667EEA),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
          ...items,
        ],
      ),
    );
  }
  
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
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
        trailing: trailing ?? (onTap != null ? const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF718096),
          size: 16,
        ) : null),
      ),
    );
  }
}

