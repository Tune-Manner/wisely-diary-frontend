import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cartoon/CartoonCreationPage.dart';
import 'main.dart';
import 'package:wisely_diary/main.dart' show MainApp;
import 'alarm/alarmSettingPage.dart ';
import 'diary/diaryNoImgPage.dart';


class WelcomePage extends StatefulWidget {
  final String? userId;
  const WelcomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  List<Map<String, dynamic>> diaries = [];
  String? memberCode;

  @override
  void initState() {
    super.initState();
    _loadMemberCode();

    // 알림 권한 요청을 initState에서 바로 호출하도록 변경
    requestNotificationPermissions();

    WidgetsBinding.instance.addPostFrameCallback((_) async{
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        // 사용자가 로그인하지 않은 경우, 메인 페이지로 리다이렉트
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainApp()),
        );
      }else{
        // await setupFCM(); // 사용자가 로그인한 경우,FCM 토큰 가져오기
        await requestNotificationPermissions(); // 권한을 다시 확인할 필요가 있을때 호출
        _loadDiaries();
      }
    });

  }

  Future<void> _loadMemberCode() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final memberResponse = await Supabase.instance.client
          .from('member')
          .select('member_code')
          .eq('member_id', user.id)
          .single();

      if (memberResponse != null) {
        setState(() {
          memberCode = memberResponse['member_code'].toString();
        });
      }
    }
  }

  Future<void> _loadDiaries() async {
    final user = Supabase.instance.client.auth.currentUser;
    print("사용자 확인: ${user != null ? '로그인됨' : '로그인되지 않음'}");

    if (user != null) {
      print("사용자 ID: ${user.id}");
      print("사용자 이메일: ${user.email}");

      try {
        // 1. member 테이블에서 member_code 조회
        final memberResponse = await Supabase.instance.client
            .from('member')
            .select('member_code')
            .eq('member_id', user.id)
            .single();

        print("Member 조회 결과: $memberResponse");

        if (memberResponse != null) {
          final memberCode = memberResponse['member_code'];
          print("Member Code: $memberCode (${memberCode.runtimeType})");

          // 2. diary 테이블에서 일기 조회
          final response = await Supabase.instance.client
              .from('diary')
              .select()
              .eq('member_code', memberCode.toString())
              .eq('diary_status', 'EXIST')
              .order('created_at', ascending: false);

          print("Diary 쿼리 결과: $response");

          setState(() {
            diaries = List<Map<String, dynamic>>.from(response);
          });

          print("조회된 일기 수: ${diaries.length}");
        } else {
          print("회원 정보를 찾을 수 없습니다.");
        }
      } catch (e, stackTrace) {
        print("오류 발생: $e");
        print("스택트레이스: $stackTrace");
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainApp()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${widget.userId ?? 'Guest'}님 환영합니다!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            child: Text('만화 생성'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CartoonCreationPage(
                        diarySummaryCode: diaries.isNotEmpty
                            ? diaries[0]['diary_code']
                            : null,
                      ),
                ),
              );
            },
          ),
          ElevatedButton(  // 알림 설정 버튼 테스트용
            child: Text('알림 설정'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlarmSettingPage(),
                ),
              );
            },
          ),
          ElevatedButton(
            child: Text('일기 보기'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryNoImgPage(selectedDate: DateTime.now()),
                ),
              );
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: diaries.length,
              itemBuilder: (context, index) {
                final diary = diaries[index];
                return ListTile(
                  title: Text(diary['diary_contents'] ?? ''),
                  subtitle: Text(diary['created_at'] ?? ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}