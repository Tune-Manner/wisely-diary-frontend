import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('홈 페이지')),
      body: Center(
        child: Text('환영합니다!'),
      ),
    );
  }
}
