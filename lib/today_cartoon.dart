import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'custom_scaffold.dart';

class TodayCartoonPage extends StatefulWidget {
  @override
  _TodayCartoonPageState createState() => _TodayCartoonPageState();
}

class _TodayCartoonPageState extends State<TodayCartoonPage> {
  String userName = '';
  String cartoonUrl = '';
  bool isLoading = true; // 로딩 상태를 관리하는 변수

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _createCartoon();
  }

  Future<void> _fetchUserName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final memberResponse = await Supabase.instance.client
          .from('member')
          .select('member_name,member_email')
          .eq('member_id', user.id)
          .single();
      setState(() {
        userName = memberResponse['member_name'];
      });
    }
  }

  Future<void> _createCartoon() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final requestBody = {
        "diaryCode": 30,
        "memberId": user.id
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
          final result = response.body;
          setState(() {
            cartoonUrl = result; // Assuming the API returns the cartoon URL as plain text
          });
        } else {
          print("Failed to create cartoon: ${response.statusCode}");
        }
      } catch (e) {
        print("Error creating cartoon: $e");
      } finally {
        setState(() {
          isLoading = false; // 만화 생성이 완료되면 로딩 상태를 해제합니다.
        });
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
                        '만화를 생성 중입니다...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: cartoonUrl.isNotEmpty
                      ? Image.network(
                    cartoonUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                      : Text('No image available'),
                ),
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
