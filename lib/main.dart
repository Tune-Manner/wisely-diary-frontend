import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'WelcomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://rgsasjlstibbmhvrjoiv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJnc2FzamxzdGliYm1odnJqb2l2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE3MDU2MjksImV4cCI6MjAzNzI4MTYyOX0.UlabKu0o_X1QnMsq8av05DKNRc4fjOAb01fcMpkcuRs',
  );
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

  Future<void> _saveUserToDatabase(User user) async {
    final userData = {
      'member_code': int.parse(user.id.hashCode.toString()), // member_code가 bigint이므로 int로 변환
      'member_email': user.email,
      'join_at': DateTime.now().toIso8601String(),
      'member_name': user.userMetadata?['full_name'],
      'member_status': 'active', // 기본 상태를 active로 설정
      'password':'password'
      // 비밀번호는 Google OAuth를 사용하는 경우 필요하지 않으므로 포함하지 않음
      // withdraw_at은 사용자가 탈퇴할 때 업데이트
    };

    final response = await supabase
        .from('member')
        .upsert(userData)
        .maybeSingle();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_userId ?? 'Not signed in'),
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
                    builder: (context) => WelcomePage(userId: googleUser.displayName),
                  ),
                );
              },
              child: Text('Sign in with Google'),
            ),
            ElevatedButton(
              onPressed: _userId == null ? null : _signOut,
              child: Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
