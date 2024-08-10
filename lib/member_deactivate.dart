import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class MemberDeactivatePage extends StatefulWidget {
  const MemberDeactivatePage({Key? key}) : super(key: key);

  @override
  _MemberDeactivatePageState createState() => _MemberDeactivatePageState();
}

class _MemberDeactivatePageState extends State<MemberDeactivatePage> {
  bool _isAgreed = false;

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('회원 탈퇴 확인'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('정말 탈퇴하시겠습니까?'),
                Text('이 작업은 되돌릴 수 없습니다.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deactivateAccount(context);
              },
            ),
          ],
        );
      },
    );
  }

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

        // 3. 로그아웃 처리
        await Supabase.instance.client.auth.signOut();

        // 탈퇴 후 메인 페이지로 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainApp()),
              (Route<dynamic> route) => false,
        );
      } catch (e, stackTrace) {
        print("탈퇴 중 오류 발생: $e");
        print("스택트레이스: $stackTrace");
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // 메뉴 동작 구현
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/emotions/sad.png',
                  width: 150,
                  height: 150,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '회원탈퇴',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '서비스 탈퇴 전 아래의 안내 사항을 꼭 확인해주세요.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              _buildInfoTable('탈퇴 후 아래 정보는 모두 삭제됩니다'),
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _isAgreed,
                    onChanged: (bool? value) {
                      setState(() {
                        _isAgreed = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      '위의 내용을 모두 확인하였으며, 회원 탈퇴에 동의합니다.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAgreed ? Colors.grey : Colors.grey.shade300,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isAgreed ? () => _showConfirmationDialog(context) : null,
                  child: Text('회원탈퇴', style: TextStyle(color: _isAgreed ? Colors.white : Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTable(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('✓', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('프로필 정보', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('계정, 이메일, 이름'),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('활동 내역', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('작성 컨텐츠(일기, 만화, 편지, 음악)'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}