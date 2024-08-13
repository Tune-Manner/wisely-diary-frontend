import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'home_screens.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final supabase = Supabase.instance.client;

  Future<void> _googleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '250529177786-j7sdpq73vmd9cqtlcc6fq02rl1oscqe7.apps.googleusercontent.com',
      );
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw 'No Access Token found.';
      }

      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user != null) {
        _navigateToHomePage(user.id);
      }
    } catch (e) {
      print('Error during Google sign in: $e');
    }
  }

  Future<void> _kakaoSignIn() async {
    try {
      kakao.OAuthToken token = await kakao.UserApi.instance.loginWithKakaoAccount();
      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.kakao,
        idToken: token.idToken!,
        accessToken: token.accessToken,
      );

      final user = response.user;
      if (user != null) {
        _navigateToHomePage(user.id);
      }
    } catch (e) {
      print('Error during Kakao sign in: $e');
    }
  }

  void _navigateToHomePage(String userId) {
    Navigator.of(context).pushReplacementNamed('/home', arguments: userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFBF0),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/wisely-diary-logo.png', height: 200, width: 300),
              SizedBox(height: 20),
              Text(
                '일기로운 슬기생활',
                style: TextStyle(fontFamily: 'HSSaemaul', fontSize: 50),
              ),
              SizedBox(height: 50),
              ElevatedButton.icon(
                icon: Image.asset('assets/google_logo.png', height: 24, width: 24),
                label: Text('Google로 시작하기'),
                onPressed: _googleSignIn,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  minimumSize: Size(300, 50),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Image.asset('assets/kakao_logo.png', height: 24, width: 24),
                label: Text('카카오로 시작하기'),
                onPressed: _kakaoSignIn,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Color(0xFFFFE812),
                  minimumSize: Size(300, 50),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Pass'),
                onPressed: () => _navigateToHomePage('Guest'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  minimumSize: Size(300, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
