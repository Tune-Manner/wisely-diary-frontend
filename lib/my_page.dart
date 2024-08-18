import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  // 예시 회원 데이터
  String userName = '홍길동';
  String userEmail = 'tune@mail.com';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이미지 부분
            Image.asset(
              'assets/wisely-diary-logo.png',
              width: 100,
              height: 100,
            ),
            SizedBox(height: 10),
            // 사용자 이름
            Text(
              userName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            // 이메일
            Text(
              userEmail,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 40),
            // 버튼들
            _buildButton('알람 설정', () {
              // 알람 설정 버튼 클릭 시 동작
            }),
            SizedBox(height: 10),
            _buildButton('이번달 감정 통계', () {
              // 이번달 감정 통계 버튼 클릭 시 동작
            }),
            SizedBox(height: 10),
            _buildButton('로그아웃', () {
              // 로그아웃 버튼 클릭 시 동작
            }),
            SizedBox(height: 10),
            _buildButton('회원 탈퇴', () {
              // 회원 탈퇴 버튼 클릭 시 동작
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 200, // 버튼의 가로 길이 설정
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300], // 버튼 색상
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}