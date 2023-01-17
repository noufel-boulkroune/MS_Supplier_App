import 'package:flutter/material.dart';
import 'package:ms_supplier_app/widgets/appbar_widget.dart';

import 'delivered_screen.dart';
import 'preparing_screen.dart';
import 'shipping_screen.dart';

class SupplierOrdersScreen extends StatelessWidget {
  const SupplierOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const AppBarTitle(title: "Orders"),
            leading: AppBarBackButton(
              color: Colors.black,
            ),
            bottom: const TabBar(
                indicatorWeight: 4,
                indicatorColor: Colors.lightBlueAccent,
                tabs: [
                  RepeatedTab(label: "Preparing"),
                  RepeatedTab(label: "Shipping"),
                  RepeatedTab(label: "Delivered"),
                ]),
          ),
          body: TabBarView(children: [
            PreparingScreen(),
            ShippingScreen(),
            DeliveredScreen()
          ])),
    );
  }
}

class RepeatedTab extends StatelessWidget {
  final String label;
  const RepeatedTab({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
