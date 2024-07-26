import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'HomePage.dart'; // 홈 페이지를 위한 파일 임포트

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SupabaseClient client = Supabase.instance.client;

  Future<void> signInWithGoogle() async {
    try {
      final response = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'http://localhost:3000', // 리다이렉트 URL 설정
      );

      // 로그인 성공 후 사용자 정보 가져오기
      final user = client.auth.currentUser;
      if (user != null) {
        print('Google 로그인 성공: ${user.email}');
        // 홈 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // 로그인 실패 처리
        print('Google 로그인 실패');
      }
    } catch (e) {
      print('로그인 중 오류 발생: $e');
    }
  }

  Future<void> signInWithKakao() async {
    try {
      final response = await client.auth.signInWithOAuth(
        OAuthProvider.kakao,
        redirectTo: 'http://localhost:3000/', // 리다이렉트 URL 설정
      );

      // 로그인 성공 후 사용자 정보 가져오기
      final user = client.auth.currentUser;
      if (user != null) {
        print('Kakao 로그인 성공: ${user.email}');
        // 홈 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // 로그인 실패 처리
        print('Kakao 로그인 실패');
      }
    } catch (e) {
      print('로그인 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SignInButton(
              Buttons.Google,
              onPressed: signInWithGoogle,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: signInWithKakao,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3C1E1E), // Kakao 색상
                foregroundColor: Colors.white, // 버튼 텍스트 색상
              ),
              child: Text('Kakao 로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
