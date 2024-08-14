import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 예시 회원 데이터
  String userName = '홍길동';
  String userEmail = 'tune@mail.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이미지 부분
            Image.asset(
              'assets/images/wisely-diary-logo.png', // 이미지 경로를 올바르게 설정하세요.
              width: 100,
              height: 100,
            ),
            SizedBox(height: 20),
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
            SizedBox(
              width: 200, // 버튼의 가로 길이 설정
              child: ElevatedButton(
                onPressed: () {
                  // 알람 설정 버튼 클릭 시 동작
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300], // 버튼 색상
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  '알람 설정',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 200, // 버튼의 가로 길이 설정
              child: ElevatedButton(
                onPressed: () {
                  // 이번달 감정 통계 버튼 클릭 시 동작
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300], // 버튼 색상
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  '이번달 감정 통계',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 200, // 버튼의 가로 길이 설정
              child: ElevatedButton(
                onPressed: () {
                  // 회원 탈퇴 버튼 클릭 시 동작
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300], // 버튼 색상
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  '회원 탈퇴',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
