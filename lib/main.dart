import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:wisely_diary/diary_summary_screens.dart';
import 'add_photo_screens.dart';
import 'login_screens.dart';
import 'create_diary_screens.dart';
import 'home_screens.dart';
import 'wait_screens.dart';
import 'select_type_screens.dart';
import 'text_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://rgsasjlstibbmhvrjoiv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJnc2FzamxzdGliYm1odnJqb2l2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE3MDU2MjksImV4cCI6MjAzNzI4MTYyOX0.UlabKu0o_X1QnMsq8av05DKNRc4fjOAb01fcMpkcuRs',
  );
  kakao.KakaoSdk.init(nativeAppKey: '2eb8687682cf67f94363bcca7b3125a4');
  
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
        '/text': (context) => TextPage(),
        '/add-photo': (context) => AddPhotoScreen(transcription: ''),
        '/summary': (context) => DiarySummaryScreen(transcription: '', imageFiles: [])
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final String userId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => HomePage(userId: userId),
          );
        }
        return null;
      },
    );
  }
}
