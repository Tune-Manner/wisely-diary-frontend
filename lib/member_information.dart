import 'package:flutter/material.dart';

class MemberInformationPage extends StatelessWidget {
  const MemberInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 정보 페이지'),
      ),
      body: Center(
        child: Text('회원 정보 페이지입니다.'),
      ),
    );
  }
}