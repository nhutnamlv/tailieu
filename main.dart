import 'package:flutter/material.dart';
import 'package:apppp1/view/RegisterView.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RegisterView(),
    );
  }
}