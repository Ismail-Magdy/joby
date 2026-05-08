import 'package:flutter/material.dart';

class CompanyHomeScreen extends StatelessWidget {
  const CompanyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Company Home")),
      body: const Center(child: Text("Welcome to the Company Home Screen!")),
    );
  }
}
