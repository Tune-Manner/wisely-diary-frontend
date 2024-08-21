import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'custom_scaffold.dart';

class TodayCartoonPage extends StatefulWidget {
  final int diaryCode;

  TodayCartoonPage({required this.diaryCode});

  @override
  _TodayCartoonPageState createState() => _TodayCartoonPageState();
}

class _TodayCartoonPageState extends State<TodayCartoonPage> {
  String userName = '';
  List<String> cartoonUrls = []; // 만화 URL 리스트
  bool isLoading = true; // 로딩 상태를 관리하는 변수

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchOrCreateCartoon();
  }

  Future<void> _fetchUserName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final memberResponse = await Supabase.instance.client
          .from('member')
          .select('member_name')
          .eq('member_id', user.id)
          .single();
      setState(() {
        userName = memberResponse['member_name'];
      });
    }
  }

  Future<void> _fetchOrCreateCartoon() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final today = DateTime.now().toIso8601String().substring(0, 10);

      try {
        // Step 1: 오늘의 만화가 이미 생성되었는지 확인
        final inquiryResponse = await http.get(
          Uri.parse('http://10.0.2.2:8080/api/cartoon/inquiry?date=$today&memberId=${user.id}'),
        );

        if (inquiryResponse.statusCode == 200) {
          final List<dynamic> cartoons = jsonDecode(inquiryResponse.body);
          final cartoonList = cartoons
              .where((cartoon) => cartoon['type'] == 'Cartoon')
              .toList();

          if (cartoonList.isNotEmpty) {
            setState(() {
              cartoonUrls = cartoonList.map<String>((cartoon) => cartoon['cartoonPath'] ?? '').toList();
            });

            // 이미 만화가 있으므로 새로운 만화를 생성하지 않음
            return;
          }
        }

        // 만화가 없거나 조회 실패 시 새로운 만화를 생성
        await _createCartoon();

      } catch (e) {
        print("Error during cartoon inquiry or creation: $e");
        await _createCartoon(); // 오류 발생 시 만화 생성 요청
      } finally {
        setState(() {
          isLoading = false; // 완료 시 로딩 상태 해제
        });
      }
    }
  }

  Future<void> _createCartoon() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final requestBody = {
        "diaryCode": widget.diaryCode,
        "memberId": user.id,
      };

      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8080/api/cartoon/create'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final result = response.body; // 기존의 String 응답 처리
          setState(() {
            cartoonUrls = [result]; // 새롭게 생성된 만화 URL을 추가
          });
        } else {
          print("Failed to create cartoon: ${response.statusCode}");
        }
      } catch (e) {
        print("Error creating cartoon: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showAppBar: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${userName}님께 도착한\n오늘 하루 만화",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Pretendard',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              if (isLoading)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(), // 로딩 인디케이터
                      SizedBox(height: 16),
                      Text(
                        '만화가 도착 중입니다...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...cartoonUrls.map((url) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: url.isNotEmpty ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ) : Text("만화 URL을 불러오지 못했습니다."),
                )).toList(),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF8B69FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, size: 18),
                    Text(
                      '다른 결과 확인하기',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}