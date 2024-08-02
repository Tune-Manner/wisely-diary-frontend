import 'package:flutter/material.dart';

class AnotherLogin extends StatelessWidget {
  const AnotherLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Another Login'),
      ),
      body: const Center(
        child: Text('Another Login Page'),
      ),
    );
  }
}