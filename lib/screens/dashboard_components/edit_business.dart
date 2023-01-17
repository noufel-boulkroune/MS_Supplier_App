import 'package:flutter/material.dart';
import 'package:ms_supplier_app/widgets/appbar_widget.dart';

class EditBusinessScreen extends StatelessWidget {
  const EditBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const AppBarTitle(title: "Edit Business"),
        leading: AppBarBackButton(
          color: Colors.black,
        ),
      ),
    );
  }
}
