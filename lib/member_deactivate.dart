import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';

class MemberDeactivatePage extends StatelessWidget {
  const MemberDeactivatePage({Key? key}) : super(key: key);

  Future<void> _deactivateAccount(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      try {
        // 1. member 테이블에서 해당 사용자의 member_status를 'deactivate'로 수정
        final response = await Supabase.instance.client
            .from('member')
            .update({'member_status': 'deactive'})
            .eq('member_id', user.id);

        print("회원 탈퇴 결과: $response");

        // 2. Supabase 인증에서 사용자 삭제
        final supabaseUrl = 'https://rgsasjlstibbmhvrjoiv.supabase.co';
        final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJnc2FzamxzdGliYm1odnJqb2l2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyMTcwNTYyOSwiZXhwIjoyMDM3MjgxNjI5fQ.KTyocsc_Pdl3v-J0T1O56Z_yeSCvi9G9TrnZ4k0FIlc';
        final deleteUrl = '$supabaseUrl/auth/v1/admin/users/${user.id}';

        final deleteResponse = await http.delete(
          Uri.parse(deleteUrl),
          headers: {
            'apikey': supabaseKey,
            'Authorization': 'Bearer $supabaseKey',
          },
        );

        // if (deleteResponse.statusCode == 204) {
        //   print("사용자 삭제 성공");
        // } else {
        //   print("사용자 삭제 실패: ${deleteResponse.body}");
        //   throw Exception('사용자 삭제 실패');
        // }

        // 3. 로그아웃 처리
        await Supabase.instance.client.auth.signOut();

        print("1-1");
        // 탈퇴 후 메인 페이지로 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainApp()),
              (Route<dynamic> route) => false,
        );
      } catch (e, stackTrace) {
        print("탈퇴 중 오류 발생: $e");
        print("스택트레이스: $stackTrace");
        // 오류 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원 탈퇴 중 오류가 발생했습니다. 다시 시도해주세요.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 탈퇴'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '정말로 회원 탈퇴를 하시겠습니까?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // 버튼 색상
              ),
              onPressed: () => _deactivateAccount(context),
              child: Text('회원 탈퇴'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
