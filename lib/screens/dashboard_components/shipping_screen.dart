import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ms_supplier_app/models/supplier_order_model.dart';

class ShippingScreen extends StatelessWidget {
  ShippingScreen({super.key});

  final Stream<QuerySnapshot> _orderStream = FirebaseFirestore.instance
      .collection("orders")
      .where("supplierId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where("deliveryStatus", isEqualTo: "shipping")
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
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
          if (order.isEmpty) {
            return const Center(
              child: Text(
                "You Have Not \n\n Active Orders !",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          return ListView.builder(
              itemCount: order.length,
              itemBuilder: (context, index) => Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: Colors.lightBlueAccent),
                      borderRadius: BorderRadius.circular(15)),
                  child: SupplierOrderModel(
                    order: order[index],
                  )));
        },
      ),
    );
  }
}
