import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ms_supplier_app/widgets/appbar_widget.dart';

class StaticsScreen extends StatelessWidget {
  StaticsScreen({super.key});
  final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance
      .collection('orders')
      .where("supplierId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const AppBarTitle(title: "Statics Screen"),
        leading: AppBarBackButton(
          color: Colors.black,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
          final data = snapshot.data!.docs;
          if (data.isEmpty) {
            return const Center(
              child: Text(
                "This category \n has no items yet !",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          double itemCount = 0;
          for (var item in data) {
            itemCount += item["orderQuantity"];
          }
          double count = 0;
          double totalPrice = 0;
          for (var item in data) {
            totalPrice += item["orderQuantity"] * item["orderPrice"];
            count += 1;
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StaticsModel(
                  lable: 'Sold out',
                  value: count,
                  decimal: 0,
                ),
                StaticsModel(
                  lable: 'Item count',
                  value: itemCount,
                  decimal: 0,
                ),
                StaticsModel(
                  lable: 'Total balance',
                  value: totalPrice,
                  decimal: 2,
                ),
                const SizedBox()
              ],
            ),
          );
        },
      ),
    );
  }
}

class StaticsModel extends StatelessWidget {
  final String lable;
  final double value;
  final int decimal;
  const StaticsModel({
    Key? key,
    required this.lable,
    required this.value,
    required this.decimal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          width: MediaQuery.of(context).size.width * .55,
          decoration: const BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Center(
            child: Text(
              lable.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
        Container(
            height: 90,
            width: MediaQuery.of(context).size.width * .55,
            decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25))),
            child: AnimatedCounter(
              value: value.round(),
              decimal: decimal,
            ))
      ],
    );
  }
}

class AnimatedCounter extends StatefulWidget {
  final int value;
  final int decimal;
  const AnimatedCounter(
      {super.key, required this.value, required this.decimal});

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = _controller;
    setState(() {
      _animation = Tween(begin: _animation.value, end: widget.value)
          .animate(_controller);
    });
    _controller.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Center(
          child: Text(
            widget.decimal == 2
                ? "${_animation.value.toStringAsFixed(widget.decimal)} \$"
                : _animation.value.toStringAsFixed(widget.decimal),
            style: const TextStyle(
                color: Colors.pink,
                fontSize: 40,
                letterSpacing: 2,
                fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
