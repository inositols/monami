import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/presentation/views/login/login_view_model.dart';
import 'package:monami/src/presentation/widgets/button_loader.dart';
import 'package:monami/src/presentation/widgets/custom_button.dart';
import 'package:monami/src/presentation/widgets/custom_textfield.dart';
import 'package:monami/src/shared/monami_logo.dart';
import 'component/custom_paint.dart';

enum Status {
  login,
  signUp,
}

Status type = Status.login;

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
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
        body: Container(
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
          child: Consumer(builder: (context, ref, _) {
            Future<void> onPressedFunction() async {
              if (!_formKey.currentState!.validate()) {
                return;
              }

              if (type == Status.login) {
                await ref
                    .read(loginViewModelProvider.notifier)
                    .login(email: _email.text, password: _password.text);
              } else {
                await ref.read(loginViewModelProvider.notifier).signUp(
                    email: _email.text,
                    password: _password.text,
                    username: _username.text);
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
                        child: const Center(
                          child: MonamiLogo(
                            size: 100,
                          ),
                        ),
                      )),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
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
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomButton(
                                  isLoading:
                                      ref.watch(loginViewModelProvider).loading,
                                  onPressed: () {
                                    onPressedFunction();
                                  },
                                  radius: 10,
                                  color: Colors.white,
                                  child: ButtonLoader(
                                    isLoading: ref
                                        .watch(loginViewModelProvider)
                                        .loading,
                                    textColor: Colors.black,
                                    text: type == Status.login
                                        ? 'Log in'
                                        : 'Sign up',
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: RichText(
                                    text: TextSpan(
                                      text: type == Status.login
                                          ? 'Don\'t have an account? '
                                          : 'Already have an account? ',
                                      style:
                                          const TextStyle(color: Colors.white),
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
          }),
        ));
  }
}
