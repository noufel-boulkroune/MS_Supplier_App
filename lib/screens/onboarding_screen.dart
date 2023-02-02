import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ms_supplier_app/auth/supplier_login_screen.dart';
import 'package:ms_supplier_app/screens/supplier_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = "onboarding-screen";
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Timer? countDownTimer;
  int seconds = 5;
  List<int> discountList = [];
  String supplierId = "";

  @override
  void initState() {
    startTimer();
    _prefs.then((SharedPreferences prefs) {
      return prefs.getString('supplierId') ?? "";
    }).then((String prefValue) {
      setState(() {
        supplierId = prefValue;
      });
    });

    super.initState();
  }

  void startTimer() {
    countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else if (seconds == 0) {
          stopTimer();
          supplierId != ""
              ? Navigator.pushReplacementNamed(
                  context, SupplierHomeScreen.routeName)
              : Navigator.pushReplacementNamed(
                  context, SupplierLoginScreen.routeName);
        }
      });
    });
  }

  void stopTimer() {
    countDownTimer!.cancel();
  }

  void getDiscount() {
    FirebaseFirestore.instance
        .collection("products")
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        discountList.add(doc["discount"]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GestureDetector(
              onTap: () {
                stopTimer();
                supplierId != ""
                    ? Navigator.pushReplacementNamed(
                        context, SupplierHomeScreen.routeName)
                    : Navigator.pushReplacementNamed(
                        context, SupplierLoginScreen.routeName);
              },
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  "assets/images/onboard/sale.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 60,
              child: Container(
                height: 35,
                width: 100,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(185, 113, 182, 214),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25))),
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, SupplierLoginScreen.routeName);
                  },
                  child: seconds == 0
                      ? const Text(
                          "Skip",
                          style: TextStyle(fontSize: 18),
                        )
                      : Text(
                          "Skip $seconds",
                          style: const TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
