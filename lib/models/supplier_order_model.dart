import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class SupplierOrderModel extends StatelessWidget {
  final dynamic order;
  const SupplierOrderModel({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Container(
        constraints:
            const BoxConstraints(maxHeight: 80, maxWidth: double.infinity),
        child: Row(
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 80, maxWidth: 80),
              child: Image.network(order["orderImage"]),
            ),
            Flexible(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order["productName"],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("\$ ${order["orderPrice"].toStringAsFixed(2)}"),
                      Text("x ${order["orderQuantity"].toString()}")
                    ],
                  )
                ],
              ),
            ))
          ],
        ),
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [const Text("See more .."), Text(order["deliveryStatus"])],
      ),
      children: [
        Container(
          // height: 230,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name: ${order["customerName"]}",
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  "Phone: ${order["customerPhone"]}",
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  "Email Address: ${order["customerEmail"]}",
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  "Address: ${order["customerAddress"]}",
                  style: const TextStyle(fontSize: 15),
                ),
                Row(
                  children: [
                    const Text(
                      "Payment Status: ",
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      "${order["paymentStatus"]}",
                      style:
                          const TextStyle(fontSize: 15, color: Colors.purple),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Delivry Status: ",
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      "${order["deliveryStatus"]}",
                      style: const TextStyle(fontSize: 15, color: Colors.green),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      order["deliveryStatus"] == "preparing"
                          ? "Order Date: "
                          : "Shipping date: ",
                      style: const TextStyle(fontSize: 15),
                    ),
                    Text(
                      DateFormat("yyyy-MM-dd")
                          .format(order["orderDate"].toDate())
                          .toString(),
                      style: const TextStyle(fontSize: 15, color: Colors.green),
                    ),
                  ],
                ),
                order["deliveryStatus"] == "delivered"
                    ? const Text(
                        "This order has been already delivered",
                        style: TextStyle(color: Colors.lightBlue),
                      )
                    : Row(
                        children: [
                          const Text(
                            "Change Delivery Status To: ",
                            style: TextStyle(fontSize: 15),
                          ),
                          order["deliveryStatus"] == "preparing"
                              ? TextButton(
                                  onPressed: () {
                                    DatePicker.showDatePicker(
                                      context,
                                      minTime: DateTime.now(),
                                      maxTime: DateTime.now()
                                          .add(const Duration(days: 365)),
                                      //update order delivery status and order date in firebase
                                      onConfirm: (date) async {
                                        await FirebaseFirestore.instance
                                            .collection("orders")
                                            .doc(order["order"])
                                            .update({
                                          "deliveryDate":
                                              date.toIso8601String(),
                                          "deliveryStatus": "shipping",
                                        });
                                      },
                                    );
                                  },
                                  child: const Text("Shipping ?"))
                              : TextButton(
                                  onPressed: () async {
                                    FirebaseFirestore.instance
                                        .collection("orders")
                                        .doc(order["order"])
                                        .update({
                                      "deliveryStatus": "delivered",
                                    });
                                  },
                                  child: const Text("Delivered ?"))
                        ],
                      ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
