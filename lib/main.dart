import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ms_supplier_app/auth/forgot_password.dart';
import 'package:ms_supplier_app/auth/update_password.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:ms_supplier_app/screens/minor_screen/edit_product.dart';
import 'package:ms_supplier_app/screens/minor_screen/edit_store.dart';
import 'package:ms_supplier_app/screens/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ms_supplier_app/services/notification_services.dart';

import '../screens/supplier_home_screen.dart';
import 'auth/supplier_login_screen.dart';
import 'auth/supplier_signup_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  print("Handling a background message: ${message.notification!.title}");
  print("Handling a background message: ${message.notification!.body}");
  print("Handling a background message: ${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationServices.creteNotificationChannel();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
