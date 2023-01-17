import 'package:flutter/material.dart';
import 'package:ms_supplier_app/widgets/appbar_widget.dart';

class MyStoreScreen extends StatelessWidget {
  const MyStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const AppBarTitle(title: "My Store"),
        leading: AppBarBackButton(
          color: Colors.black,
        ),
      ),
    );
  }
}
