import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badges/badges.dart' as badge;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ms_supplier_app/screens/dashboard_screen.dart';
import 'package:ms_supplier_app/screens/home_screen.dart';
import 'package:ms_supplier_app/screens/stores_screen.dart';
import 'package:ms_supplier_app/screens/upload_products_screen.dart';
import 'package:ms_supplier_app/services/notification_services.dart';

import 'category_screen.dart';

class SupplierHomeScreen extends StatefulWidget {
  static const routeName = "Supplier_screen";
  const SupplierHomeScreen({super.key});

  @override
  State<SupplierHomeScreen> createState() => _SupplierHomeScreenState();
}

class _SupplierHomeScreenState extends State<SupplierHomeScreen> {
  @override
  void initState() {
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        NotificationServices.displayNotification(message);
      }
    });
    super.initState();
  }

  int _selectedIndex = 0;
  final List<Widget> _tabs = [
    const HomeScreen(),
    const CategoryScreen(),
    StoresScreen(),
    DashboardScreen(),
    const UploadProductsScreen(),
  ];

  final Stream<QuerySnapshot> _orderStream = FirebaseFirestore.instance
      .collection("orders")
      .where("supplierId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where("deliveryStatus", isEqualTo: "preparing")
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _orderStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Material(
            color: Colors.white,
            child: Center(
              child: Image(
                image: AssetImage("assets/svgs/loading-animation-blue.gif"),
              ),
            ),
          );
        }
        final order = snapshot.data!.docs;

        return Scaffold(
          body: _tabs[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.lightBlueAccent,
            unselectedItemColor: Colors.grey,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            currentIndex: _selectedIndex,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: "Category",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.shop),
                label: "Stores",
              ),
              BottomNavigationBarItem(
                icon: badge.Badge(
                    showBadge: order.isEmpty ? false : true,
                    badgeAnimation: const badge.BadgeAnimation.slide(),
                    badgeStyle: const badge.BadgeStyle(
                        badgeColor: Colors.lightBlueAccent),
                    badgeContent: Text(order.length.toString()),
                    child: const Icon(Icons.dashboard)),
                label: "Dashboard",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.upload),
                label: "Upload",
              ),
            ],
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}
