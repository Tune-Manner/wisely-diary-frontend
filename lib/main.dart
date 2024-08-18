import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:gotrue/src/types/user.dart' as gotrue;
import 'WelcomePage.dart';
import 'add_photo_screens.dart';
import 'diary_summary_screens.dart';
import 'kakao/kakao_login.dart';
import 'kakao/main_view_model.dart';
import 'member_information.dart';
import 'test_page.dart';
import 'login_screens.dart';
import 'create_diary_screens.dart';
import 'home_screens.dart';
import 'wait_screens.dart';
import 'select_type_screens.dart';
import 'record_screens.dart';
import 'text_screens.dart';
import 'statistics/monthly_emotion_screens.dart';

// FCM 관련 import 추가
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'alarm/fcm_helper.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Firebase 초기화
  await Firebase.initializeApp();

  // 앱 권한 요청
  await FCMHelper.requestPermissions();

  // 알림 채널 생성 및 초기화
  await FCMHelper.createNotificationChannel();
  await FCMHelper.setupFlutterNotifications();

  //supabase초기화
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // 안드로이드 알람 매니처 초기화
  await AndroidAlarmManager.initialize();

  // 카카오 sdk초기화
  kakao.KakaoSdk.init(nativeAppKey: '2eb8687682cf67f94363bcca7b3125a4');

  print('App initialized with FCM.');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wisely Diary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/create-diary-screens': (context) => CreateDiaryPage(),
        '/wait': (context) => WaitPage(),
        '/select-type': (context) => SelectTypePage(),
        '/record': (context) => RecordScreen(),
        '/text': (context) => TextPage(),
        '/add-photo': (context) => AddPhotoScreen(transcription: ''),
        '/summary': (context) => DiarySummaryScreen(transcription: '', imageFiles: []),
        '/monthly-emotion' : (context) => MonthlyEmotionScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final String userId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => HomeScreens(userId: userId),
          );
        }
        return null;
      },
    );
  }
}
