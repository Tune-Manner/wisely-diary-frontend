import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:gotrue/src/types/user.dart' as gotrue;
import 'package:wisely_diary/alarm/alarm_setting_page.dart';
import 'package:wisely_diary/statistics/monthly_emotion_screens.dart';
import 'package:wisely_diary/today_cartoon.dart';
import 'WelcomePage.dart';
import 'add_photo_screens.dart';
import 'diary_summary_screens.dart';
import 'custom_scaffold.dart';
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
import 'my_page.dart';

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

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await dotenv.load(fileName: ".env");

  // Firebase 초기화
  await Firebase.initializeApp();

  // 앱 권한 요청
  await FCMHelper.requestPermissions();

  // 알림 채널 생성 및 초기화
  await FCMHelper.createNotificationChannel();
  await FCMHelper.setupFlutterNotifications();

  //supabase초기화
  await Supabase.initialize(
    url: 'https://rgsasjlstibbmhvrjoiv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJnc2FzamxzdGliYm1odnJqb2l2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE3MDU2MjksImV4cCI6MjAzNzI4MTYyOX0.UlabKu0o_X1QnMsq8av05DKNRc4fjOAb01fcMpkcuRs',
  );

  // 안드로이드 알람 매니처 초기화
  await AndroidAlarmManager.initialize();

  // 카카오 sdk초기화
  kakao.KakaoSdk.init(nativeAppKey: '2eb8687682cf67f94363bcca7b3125a4');

  // 로케일 초기화
  await initializeDateFormatting('ko_KR', null);

  print('App initialized with FCM.');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return MaterialApp(
      title: 'Wisely Diary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Color(0xFFFDFBF0),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/create-diary-screens': (context) => CreateDiaryPage(),
        '/mypage': (context) => CustomScaffold(
              body: MyPage(),
              title: '마이페이지',
            ),
        '/statistics': (context) => MonthlyEmotionScreen(),
        '/notifications': (context) => AlarmSettingPage(),
        '/today-cartoon': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          final int diaryCode = arguments['diaryCode']; 
          return TodayCartoonPage(diaryCode: diaryCode);
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final String userId = settings.arguments as String? ?? '';
          return MaterialPageRoute(
            builder: (context) => HomeScreens(userId: userId),
          );
        }
        if (settings.name == '/wait') {
          final int emotionNumber = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => WaitPage(emotionNumber: emotionNumber),
          );
        }
        if (settings.name == '/text') {
          final int emotionNumber = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => TextPage(emotionNumber: emotionNumber),
          );
        }
        if (settings.name == '/select-type') {
          final int emotionNumber = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => SelectTypePage(emotionNumber: emotionNumber),
          );
        }
        if (settings.name == '/record') {
          final int emotionNumber = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => RecordScreen(emotionNumber: emotionNumber),
          );
        }
        if (settings.name == '/add-photo') {
          final Map<String, dynamic> args =
              settings.arguments as Map<String, dynamic>;
          final String transcription = args['transcription'] ?? '';
          final int diaryCode = args['diaryCode'] ?? 0; 

          return MaterialPageRoute(
            builder: (context) => AddPhotoScreen(
              transcription: transcription,
              diaryCode: diaryCode, 
            ),
          );
        }
        if (settings.name == '/summary') {
          final Map<String, dynamic> args =
              settings.arguments as Map<String, dynamic>;
          final String transcription = args['transcription'] ?? '';
          final List<File> imageFiles = args['imageFiles'] ?? [];
          final int diaryCode = args['diaryCode'] ?? 0; 

          return MaterialPageRoute(
            builder: (context) => DiarySummaryScreen(
              transcription: transcription,
              imageFiles: imageFiles,
              diaryCode: diaryCode,
            ),
          );
        }
        return null;
      },
    );
  }
}
