import 'package:api/statefulwidget/lifecycle_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: LifecycleWidget(title: 'Lifecycle Widget'),
      debugShowCheckedModeBanner: false,
    );
  }
}
