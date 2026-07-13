import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const HmsApp());
}

class HmsApp extends StatelessWidget {
  const HmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HMS - Hotel Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // TODO: Replace with LoginPage when auth module is ready
      home: const Scaffold(
        body: Center(child: Text('HMS - Hotel Management System')),
      ),
    );
  }
}
