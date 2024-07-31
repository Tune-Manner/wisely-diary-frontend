import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:gotrue/src/types/user.dart' as gotrue;
import 'WelcomePage.dart';
import 'kakao/kakao_login.dart';
import 'kakao/main_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://rgsasjlstibbmhvrjoiv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJnc2FzamxzdGliYm1odnJqb2l2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE3MDU2MjksImV4cCI6MjAzNzI4MTYyOX0.UlabKu0o_X1QnMsq8av05DKNRc4fjOAb01fcMpkcuRs',
  );
  kakao.KakaoSdk.init(nativeAppKey: '2eb8687682cf67f94363bcca7b3125a4');

  runApp(MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _userId;
  final viewModel = MainViewModel(KakaoLogin());

  @override
  void initState() {
    super.initState();

    supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        _userId = data.session?.user?.id;
      });
    });
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainApp()),
          (Route<dynamic> route) => false,
    );
  }

  Future<void> _saveUserToDatabase(gotrue.User user) async {
    final userData = {
      'member_code': int.parse(user.id.hashCode.toString()),
      'member_email': user.email,
      'join_at': DateTime.now().toIso8601String(),
      'member_name': user.userMetadata?['full_name'],
      'member_status': 'active',
      'password': 'password'
    };

    final response = await supabase
        .from('member')
        .upsert(userData)
        .maybeSingle();
  }

  Future<void> _saveKakaoUserToDatabase(gotrue.User user, String memberName) async {
    final userData = {
      'member_code': int.parse(user.id.hashCode.toString()),
      'member_email': user.email,
      'join_at': DateTime.now().toIso8601String(),
      'member_name': memberName,
      'member_status': 'active',
      'password': 'password'
    };

    final response = await supabase
        .from('member')
        .upsert(userData)
        .maybeSingle();

    // 사용자 메타데이터 업데이트
    final updateResponse = await supabase.auth.updateUser(UserAttributes(
      data: {'full_name': memberName},
    ));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
        child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        ElevatedButton(
        onPressed: () async {
      const webClientId = '250529177786-ufcdttr2mssq4tleorq6d6r44eh24k71.apps.googleusercontent.com';
      const iosClientId = '250529177786-j7sdpq73vmd9cqtlcc6fq02rl1oscqe7.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      await _saveUserToDatabase(user!);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              WelcomePage(userId: googleUser.displayName),
        ),
      );
    },
    child: Text('Sign in with Google'),
    ),
    ElevatedButton(
    onPressed: () async {
    try {
    // 카카오 로그인
    OAuthToken kakaoToken = await UserApi.instance
        .loginWithKakaoAccount();
    final accessToken = kakaoToken.accessToken;
    final idToken = kakaoToken.idToken;

    if (accessToken == null || idToken == null) {
    throw 'No Access Token or ID Token found.';
    }

    // 카카오 사용자 정보 가져오기
    final kakaoUser = await UserApi.instance.me();
    final memberName = kakaoUser.kakaoAccount?.profile
        ?.nickname ?? 'Unknown';

    // Supabase auth에 사용자 등록
    final response = await supabase.auth.signInWithIdToken(
    provider: OAuthProvider.kakao,
    idToken: idToken,
    accessToken: accessToken,
    );

    // 사용자 정보를 데이터베이스에 저장
    final user = response.user;
    await _saveKakaoUserToDatabase(user!, memberName);

    // WelcomePage로 이동하여 닉네임을 전달
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WelcomePage(userId: memberName),
      ),
    );
    } catch (e) {
      print('Error during Kakao login: $e');
    }
    },
      child: Text('Sign in with Kakao'),
    ),
          if (_userId != null)
            ElevatedButton(
              onPressed: _signOut,
              child: Text('Sign out'),
            ),
        ],
        ),
        ),
        ),
    );
  }
}



