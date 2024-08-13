import 'dart:convert';
import 'dart:io';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:gotrue/src/types/user.dart' as gotrue;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart'; // DeviceInfoPlus 패키지 import
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart'; // permission_handler import
import 'WelcomePage.dart';
import 'kakao/kakao_login.dart';
import 'kakao/main_view_model.dart';
import 'test_page.dart';
export 'main.dart';

// FCM 권한 요청 함수
Future<void> requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  if (defaultTargetPlatform == TargetPlatform.android && Platform.isAndroid && await _isAndroid13OrAbove()) {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}'); // 로그 추가
  } else {
    print('No explicit permission required on this OS version.'); // 로그 추가
  }
}

Future<bool> _isAndroid13OrAbove() async {
  if (Platform.isAndroid) {
    var version = await _getAndroidVersion();
    return version != null && version >= 33;
  }
  return false;
}

// 알림 채널 생성 함수
Future<void> createNotificationChannel() async {
  if (Platform.isAndroid) {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_alarm_channel', // 채널 ID
      'Daily Alarm Notifications', // 채널 이름
      description: 'This channel is used for daily alarm notifications.', // 채널 설명
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print('Notification channel created.'); // 로그 추가
  }
}

// 로컬 알림 초기화
Future<void> setupFlutterNotifications() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  print('Local notifications initialized.'); // 로그 추가
}

// 앱 권한 요청 함수 추가
Future<void> _requestPermissions() async {
  // 알림 권한 확인 및 요청
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
    print('Notification permission requested.'); // 로그 추가
  } else {
    print('Notification permission already granted or not required.'); // 로그 추가
  }

  // 정확한 알람 권한 확인 및 요청 (Android 12 이상)
  if (Platform.isAndroid) {
    if (await _isAndroid12OrAbove()) {
      var status = await Permission.scheduleExactAlarm.status;
      if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
        // 권한 요청
        status = await Permission.scheduleExactAlarm.request();
        print('Exact alarm permission requested.'); // 로그 추가
      }
      if (!status.isGranted) {
        // 권한이 거부된 경우 처리
        print("Exact alarms are not permitted");
      } else {
        print("Exact alarms are permitted"); // 로그 추가
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // Firebase 초기화
  await Firebase.initializeApp();

  // 앱 권한 요청 추가
  await _requestPermissions();

  // 알림 채널 생성 및 초기화
  await createNotificationChannel();
  await setupFlutterNotifications();

  // Supabase 초기화
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // 안드로이드 알람 매니처 초기화
  await AndroidAlarmManager.initialize();

  //카카오 SDK초기화
  kakao.KakaoSdk.init(nativeAppKey: '2eb8687682cf67f94363bcca7b3125a4');

  print('App initialized.'); // 로그 추가

  runApp(const MainApp());
}

Future<bool> _isAndroid12OrAbove() async {
  if (Platform.isAndroid) {
    var version = await _getAndroidVersion();
    return version != null && version >= 31;
  }
  return false;
}

Future<int?> _getAndroidVersion() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  return androidInfo.version.sdkInt;
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: requestNotificationPermissions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print('Permissions granted. Launching HomePage.'); // 로그 추가
            return const HomePage();
          } else {
            print('Waiting for permissions...'); // 로그 추가
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
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

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      setState(() {
        _userId = data.session?.user.id;
      });
      print('User ID: $_userId'); // 로그 추가
    });
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    print('User signed out.'); // 로그 추가

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainApp()),
          (Route<dynamic> route) => false,
    );
  }

  Future<void> _saveUserToDatabase(gotrue.User? user) async {
    if (user != null) {
      final userData = {
        'member_email': user.email,
        'join_at': DateTime.now().toIso8601String(),
        'member_name': user.userMetadata?['full_name'],
        'member_status': 'active',
        'member_id':user.id
      };

      final response = await Supabase.instance.client
          .from('member')
          .upsert(userData)
          .maybeSingle();

      print('User data saved to database: $response'); // 로그 추가
    }
  }

  Future<void> _saveKakaoUserToDatabase(gotrue.User user, String memberName) async {
    final userData = {
      'member_email': user.email,
      'join_at': DateTime.now().toIso8601String(),
      'member_name': memberName,
      'member_status': 'active',
      'member_id':user.id
    };

    final response = await Supabase.instance.client
        .from('member')
        .upsert(userData)
        .maybeSingle();

    // 사용자 메타데이터 업데이트
    final updateResponse = await Supabase.instance.client.auth.updateUser(UserAttributes(
      data: {'full_name': memberName},
    ));

    print('Kakao user data saved to database: $response'); // 로그 추가
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFBF0), // 배경 색상 추가
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/wisely-diary-logo.png',
                height: 200.0,
                width: 300.0,
              ),
              SizedBox(height: 0.0), // 텍스트와 구분선 사이의 간격 조정
              Text(
                '일기로운 슬기생활',
                style: TextStyle(
                    fontFamily: 'HSSaemaul',
                    fontSize: 50.0,
                    height: 0.01
                ),
              ),
              SizedBox(height: 70.0), // 텍스트와 구분선 사이의 간격 조정
              Container(
                width: 350.0, // 선의 길이 조정
                height: 1.0, // 선의 두께 조정
                color: Colors.grey, // 선의 색상
              ),
              SizedBox(height: 60.0), // 구분선과 버튼 사이의 간격 조정
              ElevatedButton.icon(
                icon: Image.asset(
                  'assets/google_logo.png', // 구글 로고 이미지 경로
                  height: 24.0,
                  width: 24.0,
                  fit: BoxFit.contain,
                ),
                label: Text('Google로 시작하기'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  minimumSize: Size(350, 50), // 버튼 넓이 조정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () async {
                  const webClientId =
                      '250529177786-ufcdttr2mssq4tleorq6d6r44eh24k71.apps.googleusercontent.com';
                  const iosClientId =
                      '250529177786-j7sdpq73vmd9cqtlcc6fq02rl1oscqe7.apps.googleusercontent.com';

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

                  final response = await Supabase.instance.client.auth.signInWithIdToken(
                    provider: OAuthProvider.google,
                    idToken: idToken,
                    accessToken: accessToken,
                  );

                  final user = response.user;
                  await _saveUserToDatabase(user!);

                  print('Google sign-in successful. Navigating to WelcomePage.'); // 로그 추가

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WelcomePage(userId: googleUser.displayName),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                icon: Image.asset(
                  'assets/kakao_logo.png', // 카카오 로고 이미지 경로
                  height: 24.0,
                  width: 24.0,
                ),
                label: Text('카카오로 시작하기'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Color(0xFFFFE812),
                  minimumSize: Size(350, 50), // 버튼 넓이 조정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () async {
                  try {
                    // 카카오 로그인
                    OAuthToken kakaoToken = await UserApi.instance.loginWithKakaoAccount();
                    final accessToken = kakaoToken.accessToken;
                    final idToken = kakaoToken.idToken;

                    if (accessToken == null || idToken == null) {
                      throw 'No Access Token or ID Token found.';
                    }

                    // 카카오 사용자 정보 가져오기
                    final kakaoUser = await UserApi.instance.me();
                    final memberName = kakaoUser.kakaoAccount?.profile?.nickname ?? 'Unknown';

                    // Supabase auth에 사용자 등록
                    final response = await Supabase.instance.client.auth.signInWithIdToken(
                      provider: OAuthProvider.kakao,
                      idToken: idToken,
                      accessToken: accessToken,
                    );

                    // 사용자 정보를 데이터베이스에 저장
                    final user = response.user;
                    await _saveKakaoUserToDatabase(user!, memberName);

                    print('Kakao sign-in successful. Navigating to WelcomePage.'); // 로그 추가

                    // WelcomePage로 이동하여 닉네임을 전달
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WelcomePage(userId: memberName),
                      ),
                    );
                  } catch (e) {
                    print('Error during Kakao login: $e');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
