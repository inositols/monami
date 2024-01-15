import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/features/auth/providers/user_id_provider.dart';
import 'package:monami/state/post/typedefs/user_id.dart';
import 'package:monami/state/user_info/provider/user_info_provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 20),
                height: 250,
                width: double.maxFinite,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(136, 14, 79, 1),
                      Color.fromRGBO(150, 24, 91, 0.678),
                    ],
                    tileMode: TileMode.clamp,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Profile",
                            style: GoogleFonts.leagueSpartan(
                                fontWeight: FontWeight.w800,
                                fontSize: 26,
                                color: Colors.white),
                          ),
                          const SizedBox(
                            width: 100,
                          ),
                          const Icon(Icons.notifications)
                        ],
                      ),
                    ),
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white)),
                      child: const Icon(Icons.camera),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Consumer(builder: (context, ref, _) {
                      final id = ref.watch(userIdProvider);
                      final user = ref.watch(userInfoModelProvider(id));

                      return user.when(
                          data: (user) => Text(
                                user.displayName,
                                style: GoogleFonts.leagueSpartan(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 26,
                                    color: Colors.white),
                              ),
                          error: (error, stackTrace) => Text(error.toString()),
                          loading: () => const LinearProgressIndicator());
                    })
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Profile",
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: const Color(0xff000000)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ProfileListTile(
                      text: "Edit Personal Info",
                      icon: Icons.edit,
                      onTap: () {},
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Account",
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: const Color(0xff000000)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ProfileListTile(
                      text: "Reset transaction Pin",
                      icon: Icons.restore,
                      onTap: () {},
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 5,
                    ),
                    ProfileListTile(
                      text: "Biometric Login",
                      icon: Icons.fingerprint,
                      onTap: () {},
                      icons: CupertinoSwitch(
                        value: true,
                        onChanged: (val) {},
                        activeColor: Colors.pink.shade900,
                      ),
                    ),
                    const Divider(),
                    ProfileListTile(
                      text: "Biometric Transaction",
                      icon: Icons.fingerprint,
                      onTap: () {},
                      icons: CupertinoSwitch(
                        value: true,
                        onChanged: (val) {},
                        activeColor: Colors.pink.shade900,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      "General",
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: const Color(0xff000000)),
                    ),
                    ProfileListTile(
                      text: "App Demos",
                      icon: Icons.play_arrow,
                      onTap: () {},
                    ),
                    const Divider(),
                    ProfileListTile(
                      text: "Log Out",
                      icon: Icons.logout,
                      onTap: () {},
                      icons: const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileListTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? icons;
  const ProfileListTile({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.icons = const Icon(
      Icons.arrow_forward_ios,
      color: Color.fromRGBO(136, 14, 79, 1),
    ),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: onTap,
          leading: Icon(icon),
          title: Text(
            text,
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: const Color(0xff000000)),
          ),
          trailing: icons),
    );
  }
}
