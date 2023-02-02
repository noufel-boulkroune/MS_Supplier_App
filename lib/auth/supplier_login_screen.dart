// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/supplier_home_screen.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/snackbar.dart';
import 'supplier_signup_screen.dart';

class SupplierLoginScreen extends StatefulWidget {
  static const routeName = "supplier_login";
  const SupplierLoginScreen({super.key});

  @override
  State<SupplierLoginScreen> createState() => _SupplierLoginScreenState();
}

final TextEditingController _emailControler = TextEditingController();
final TextEditingController _passwordControler = TextEditingController();

class _SupplierLoginScreenState extends State<SupplierLoginScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late String email, password, profileImage;
  bool processing = false;

  bool passwordVisibility = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scafoldKey =
      GlobalKey<ScaffoldMessengerState>();
  @override
  void dispose() {
    _emailControler.dispose();
    _passwordControler.dispose();
    super.dispose();
  }

  void login() async {
    setState(() {
      processing = true;
    });

    if (_formKey.currentState!.validate()) {
      setState(() {
        email = _emailControler.text;
        password = _passwordControler.text;
      });
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: email,
          password: password,
        )
            .then((value) async {
          setState(() {
            processing = false;
          });
          await FirebaseAuth.instance.currentUser!.reload();

          if (FirebaseAuth.instance.currentUser!.emailVerified == true) {
            setState(() {
              _formKey.currentState!.reset();
              processing = false;
            });
            User? user = FirebaseAuth.instance.currentUser;
            final SharedPreferences pref = await _prefs;
            pref.setString("supplierId", user!.uid);
            await Future.delayed(const Duration(microseconds: 10)).whenComplete(
                () => Navigator.pushReplacementNamed(
                    context, SupplierHomeScreen.routeName));
          } else {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Email verification"),
                content: const Text("Please verify your email before Login"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        processing = false;
                      });
                      Navigator.of(ctx).pop();
                    },
                    child: const Text("Ok"),
                  ),
                  TextButton(
                    onPressed: () {
                      try {
                        FirebaseAuth.instance.currentUser!
                            .sendEmailVerification();
                      } catch (error) {
                        print(error);
                      }
                      setState(() {
                        processing = false;
                      });
                      Navigator.of(ctx).pop();
                    },
                    child: const Text("Resend"),
                  ),
                ],
              ),
            );
          }
        });
      } on FirebaseAuthException catch (error) {
        if (error.code == 'user-not-found') {
          SnackBarHundler.showSnackBar(
            _scafoldKey,
            "No user found for that email.",
          );
          setState(() {
            processing = false;
          });
        } else if (error.code == 'wrong-password') {
          SnackBarHundler.showSnackBar(
            _scafoldKey,
            "Wrong password provided for that user.",
          );
          setState(() {
            processing = false;
          });
        }
      }
    } else {
      SnackBarHundler.showSnackBar(_scafoldKey, "Pleas fill all fields");
      setState(() {
        processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scafoldKey,
      child: Scaffold(
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          reverse: true,
          child: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * .94,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    const AuthHeaderLable(
                      headerLable: 'Log In',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextFormField(
                            controller: _emailControler,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Pleas enter your Email";
                              } else if (value.isValidEmail() == false) {
                                return "invalide email";
                              } else if (value.isValidEmail() == true) {
                                null;
                              }

                              return null;
                            },
                            decoration: textFormDecoration.copyWith(
                                labelText: "Email Adress",
                                hintText: "Enter your email")),
                        const SizedBox(
                          height: 50,
                        ),
                        TextFormField(
                            controller: _passwordControler,
                            obscureText: !passwordVisibility,
                            validator: (value) => value!.isEmpty
                                ? "Pleas enter your Password"
                                : null,
                            decoration: textFormDecoration.copyWith(
                                labelText: "Password",
                                hintText: "Enter your password",
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        passwordVisibility =
                                            !passwordVisibility;
                                      });
                                    },
                                    icon: !passwordVisibility
                                        ? const Icon(
                                            Icons.visibility,
                                            color: Colors.lightBlueAccent,
                                          )
                                        : const Icon(
                                            Icons.visibility_off,
                                            color: Colors.lightBlueAccent,
                                          )))),
                        TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Forget Password?",
                              style: TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: Colors.lightBlueAccent,
                              ),
                            )),
                      ],
                    ),
                    Column(
                      children: [
                        HaveAccount(
                          actionLabel: "Sign Up",
                          haveAccont: "Don't have an account? ",
                          onPressed: () {
                            Navigator.pushNamed(
                                context, SupplierSignupScreen.routeName);
                          },
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        processing
                            ? const Center(child: CircularProgressIndicator())
                            : AuthMainButton(
                                mainButtonLable: "Log In",
                                onPressed: () {
                                  login();
                                },
                              ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
