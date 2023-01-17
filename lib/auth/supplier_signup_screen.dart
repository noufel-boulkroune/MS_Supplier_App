import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storege;

import '../auth/supplier_login_screen.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/snackbar.dart';

class SupplierSignupScreen extends StatefulWidget {
  static const routeName = "supplier_signup";
  const SupplierSignupScreen({super.key});

  @override
  State<SupplierSignupScreen> createState() => _SupplierSignupScreenState();
}

final TextEditingController _nameControler = TextEditingController();
final TextEditingController _emailControler = TextEditingController();
final TextEditingController _passwordControler = TextEditingController();

class _SupplierSignupScreenState extends State<SupplierSignupScreen> {
  late String storeName, email, password, storeLogo, _supplierid;
  bool processing = false;
  XFile? _imageFile;
  //dynamic _pickedImageError;

  CollectionReference suppliers =
      FirebaseFirestore.instance.collection("suppliers");

  bool passwordVisibility = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scafoldKey =
      GlobalKey<ScaffoldMessengerState>();
  @override
  void dispose() {
    _nameControler.dispose();
    _emailControler.dispose();
    _passwordControler.dispose();
    super.dispose();
  }

  void _pickImageFromCamera() async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: 300,
        maxWidth: 300,
        imageQuality: 95,
      );
      setState(() {
        _imageFile = pickedImage;
      });
    } catch (error) {
      setState(() {
        //   _pickedImageError = error;
      });
      //  print(_pickedImageError);
    }
  }

  void _pickImageFromGallery() async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 300,
        maxWidth: 300,
        imageQuality: 95,
      );
      setState(() {
        _imageFile = pickedImage;
      });
    } catch (error) {
      setState(() {
        //  _pickedImageError = error;
      });
      // print(_pickedImageError);
    }
  }

  void signUp() async {
    setState(() {
      processing = true;
    });
    if (_formKey.currentState!.validate()) {
      if (_imageFile != null) {
        setState(() {
          storeName = _nameControler.text;
          email = _emailControler.text;
          password = _passwordControler.text;
        });
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          try {
            await FirebaseAuth.instance.currentUser!
                .sendEmailVerification()
                .then((value) async {
              //Store image in firebase

              firebase_storege.Reference reference =
                  firebase_storege.FirebaseStorage.instance.ref(
                "supplier-image/$email.jpg",
              );

              await reference.putFile(File(_imageFile!.path));

              storeLogo = await reference.getDownloadURL();

              await FirebaseAuth.instance.currentUser!
                  .updateDisplayName(storeName);
              await FirebaseAuth.instance.currentUser!
                  .updatePhotoURL(storeName);
              _supplierid = FirebaseAuth.instance.currentUser!.uid;
              await suppliers.doc(_supplierid).set({
                "storeName": storeName,
                "email": email,
                "storeLogo": storeLogo,
                "phone": "",
                "storeAddress": "",
                "supplierId": _supplierid,
                "coverImage": ""
              }).then((value) {
                setState(() {
                  _imageFile = null;
                  _formKey.currentState!.reset();
                  processing = false;
                });
              });
              await Future.delayed(const Duration(microseconds: 10))
                  .whenComplete(() => Navigator.pushNamed(
                      context, SupplierLoginScreen.routeName));
            });
          } catch (error) {
            // ignore: avoid_print
            print(error);
          }
        } on FirebaseAuthException catch (error) {
          if (error.code == 'weak-password') {
            SnackBarHundler.showSnackBar(
              _scafoldKey,
              "The password provided is too weak.",
            );
            setState(() {
              processing = false;
            });
          } else if (error.code == 'email-already-in-use') {
            SnackBarHundler.showSnackBar(
              _scafoldKey,
              "The account already exists for that email.",
            );
            setState(() {
              processing = false;
            });
          }
        }
      } else {
        SnackBarHundler.showSnackBar(_scafoldKey, "Pleas pick image first");
        setState(() {
          processing = false;
        });
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
                    const AuthHeaderLable(
                      headerLable: 'Sign Up',
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.lightBlueAccent,
                        backgroundImage: _imageFile == null
                            ? null
                            : FileImage(File(_imageFile!.path)),
                        child: _imageFile == null
                            ? const Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.lightBlueAccent,
                                borderRadius: BorderRadius.circular(25)),
                            child: IconButton(
                                onPressed: () {
                                  _pickImageFromCamera();
                                },
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Container(
                            // constraints: BoxConstraints.expand(),
                            decoration: BoxDecoration(
                                color: Colors.lightBlueAccent,
                                borderRadius: BorderRadius.circular(25)),
                            child: IconButton(
                                onPressed: () {
                                  _pickImageFromGallery();
                                },
                                icon: const Icon(
                                  Icons.photo,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                        controller: _nameControler,
                        validator: (value) => value!.isEmpty
                            ? "Pleas enter your full name"
                            : null,
                        decoration: textFormDecoration),
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
                    TextFormField(
                        controller: _passwordControler,
                        obscureText: !passwordVisibility,
                        validator: (value) =>
                            value!.isEmpty ? "Pleas enter your Password" : null,
                        decoration: textFormDecoration.copyWith(
                            labelText: "Password",
                            hintText: "Enter your password",
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    passwordVisibility = !passwordVisibility;
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
                    HaveAccount(
                      actionLabel: "Log In",
                      haveAccont: "Already have account? ",
                      onPressed: () {
                        Navigator.pushNamed(
                            context, SupplierLoginScreen.routeName);
                      },
                    ),
                    processing
                        ? const CircularProgressIndicator()
                        : AuthMainButton(
                            mainButtonLable: "Sign Up",
                            onPressed: () {
                              signUp();
                            },
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
