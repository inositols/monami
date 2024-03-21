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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Settings",
                style: GoogleFonts.lato(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(10),
              Text(
                "Profile",
                style: GoogleFonts.lato(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SettingListTile(
                text: "Hide Profile",
                onPressed: (bool hide) {},
              ),
              SettingListTile(
                text: "Notification",
                onPressed: (bool hide) {},
              ),
              SettingListTile(
                text: "Hide Profile",
                onPressed: (bool hide) {},
              ),
              SettingListTile(
                text: "Notification",
                onPressed: (bool hide) {},
              ),
              const Gap(20),
              Text(
                "Profile",
                style: GoogleFonts.lato(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SettingListTile(
                text: "Hide Profile",
                onPressed: (bool hide) {},
              ),
              SettingListTile(
                text: "Notification",
                onPressed: (bool hide) {},
              ),
            ],
          )),
    );
  }
}

class SettingListTile extends StatelessWidget {
  final String text;
  final Function(bool) onPressed;
  const SettingListTile({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(
        text,
        style: GoogleFonts.roboto(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: CupertinoSwitch(
        activeColor: Colors.pink.shade900,
        value: true,
        onChanged: onPressed,
      ),
    );
  }
}
