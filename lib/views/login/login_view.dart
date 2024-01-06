import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/custom_widgets/button_loader.dart';
import 'package:monami/custom_widgets/custom_button.dart';
import 'package:monami/custom_widgets/custom_textfield.dart';
import 'package:monami/state/auth/providers/auth_state_provider.dart';

import 'component/custom_paint.dart';

enum Status {
  login,
  signUp,
}

Status type = Status.login;

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool obscureText = true;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController();

  void _switchType() {
    if (type == Status.signUp) {
      setState(() {
        type = Status.login;
      });
    } else {
      setState(() {
        type = Status.signUp;
      });
    }
    // print(type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Consumer(builder: (context, ref, _) {
          Future<void> onPressedFunction() async {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            if (type == Status.login) {
              await ref
                  .read(authStateProvider.notifier)
                  .login(_email.text, _password.text);
            } else {
              await ref
                  .read(authStateProvider.notifier)
                  .signUp(_email.text, _password.text, _username.text);
            }
          }

          return Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomPaint(
                    painter: BottomClip(),
                    child: Container(
                      padding: const EdgeInsets.only(top: 80),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const FlutterLogo(size: 100),
                          const SizedBox(
                            height: 20,
                          ),
                          Text("MONAMI",
                              style: GoogleFonts.stardosStencil(
                                color: Colors.black,
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    )),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  height: MediaQuery.of(context).size.height / 2,
                  child: Column(
                    children: [
                      CustomTextfield(
                          hintText: "Email",
                          prefixIcon: const Icon(Icons.mail),
                          controller: _email,
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return 'Invalid email!';
                            }
                            return null;
                          }),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextfield(
                        hintText: "Password",
                        controller: _password,
                        prefixIcon: const Icon(Icons.lock),
                        validator: (value) =>
                            value!.isEmpty ? 'Field is required' : null,
                        obscureText: obscureText,
                        suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => obscureText = !obscureText),
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            )),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (type == Status.signUp)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          child: CustomTextfield(
                            hintText: "Username",
                            controller: _username,
                            prefixIcon: const Icon(Icons.person),
                            validator: type == Status.signUp
                                ? (value) {
                                    if (value!.isEmpty) {
                                      return 'Username cannot be empty';
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                        ),
                      const Spacer(),
                      Expanded(
                        flex: 2,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomButton(
                                isLoading:
                                    ref.watch(authStateProvider).isLoading,
                                onPressed: () {
                                  onPressedFunction();
                                },
                                radius: 10,
                                color: Colors.white,
                                child: ButtonLoader(
                                  isLoading:
                                      ref.watch(authStateProvider).isLoading,
                                  textColor: Colors.black,
                                  text: type == Status.login
                                      ? 'Log in'
                                      : 'Sign up',
                                ),
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: RichText(
                                  text: TextSpan(
                                    text: type == Status.login
                                        ? 'Don\'t have an account? '
                                        : 'Already have an account? ',
                                    style: const TextStyle(color: Colors.white),
                                    children: [
                                      TextSpan(
                                          text: type == Status.login
                                              ? 'Sign up now'
                                              : 'Log in',
                                          style: const TextStyle(
                                              color: Colors.grey),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              _switchType();
                                            })
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }));
  }
}
