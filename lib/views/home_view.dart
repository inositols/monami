import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// extension log on

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    bool signup = false;
    useEffect(
      () {
        signup = true;
        return () {};
      },
      [signup],
    );
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/background_light.png'),
              fit: BoxFit.cover),
        ),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome to Monami",
                style: GoogleFonts.raleway(
                    fontSize: 25,
                    color: const Color.fromRGBO(182, 37, 190, 1),
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(
                height: 50,
              ),
              TextFormFieldWidget(
                text: 'Email',
                controller: emailController,
              ),
              TextFormFieldWidget(
                text: 'Password',
                controller: passwordController,
              ),
              signup == true
                  ? TextFormFieldWidget(
                      text: 'Password',
                      controller: passwordController,
                    )
                  : const SizedBox.shrink(),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    signup == true;
                  },
                  child: Text(
                    'Forgot Password',
                    style: GoogleFonts.raleway(
                        fontSize: 15,
                        color: const Color.fromRGBO(182, 37, 190, 1),
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.only(top: 0),
                  height: 40,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(182, 37, 190, 1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Text(
                      "Login",
                      style: GoogleFonts.raleway(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Or Login with',
                style: GoogleFonts.raleway(
                    fontSize: 15,
                    color: const Color.fromRGBO(182, 37, 190, 1),
                    fontWeight: FontWeight.w800),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 40,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(182, 37, 190, 1),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.google,
                      color: Color(0xff4285F4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@immutable
class TextFormFieldWidget extends StatelessWidget {
  final String text;
  final TextEditingController controller;

  const TextFormFieldWidget({
    Key? key,
    required this.text,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: text,
          labelStyle: GoogleFonts.raleway(
              color: const Color.fromRGBO(182, 37, 190, 1),
              fontWeight: FontWeight.w800),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromRGBO(182, 37, 190, 1),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromRGBO(182, 37, 190, 1),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
