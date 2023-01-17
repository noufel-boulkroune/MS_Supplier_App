import 'package:flutter/material.dart';
import 'package:ms_supplier_app/auth/forgot_password.dart';
import 'package:ms_supplier_app/auth/update_password.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:ms_supplier_app/screens/minor_screen/edit_product.dart';
import 'package:ms_supplier_app/screens/minor_screen/edit_store.dart';
import 'package:ms_supplier_app/screens/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import '../screens/supplier_home_screen.dart';
import 'auth/supplier_login_screen.dart';
import 'auth/supplier_signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // initialRoute: OnboardingScreen.routeName,
      initialRoute: OnboardingScreen.routeName,
      routes: {
        SupplierHomeScreen.routeName: (context) => const SupplierHomeScreen(),
        SupplierSignupScreen.routeName: (context) =>
            const SupplierSignupScreen(),
        SupplierLoginScreen.routeName: (context) => const SupplierLoginScreen(),
        EditStore.routeName: (context) => const EditStore(),
        EditProduct.routeName: (context) => const EditProduct(),
        ForgotPassword.routeName: (context) => const ForgotPassword(),
        UpdatePassword.routeName: (context) => const UpdatePassword(),
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
      },
    );
  }
}
