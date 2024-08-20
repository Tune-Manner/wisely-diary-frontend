import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wisely_diary/main.dart';
import 'create_diary_screens.dart'; // CreateDiaryPage를 import합니다.
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'custom_scaffold.dart';
import 'alarm/alarm_setting_page.dart';

import 'date_select.dart';

class HomeScreens extends StatefulWidget {
  final String userId;

  HomeScreens({required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreens> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  final List<Map<String, String>> _diaryEntries = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  Future<void> _fetchDiaryContent(DateTime selectedDay) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.44:8080/api/diary/selectdetail'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'date': selectedDay.toIso8601String().split('T').first,
        'memberId': widget.userId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data != null && data['diaryContents'] != null) {
        setState(() {
          _diaryEntries.clear();
          _diaryEntries.add({
            'date': selectedDay.toIso8601String().split('T').first, // 날짜 형식 정리
            'summary': data['diaryContents'] ?? '내용 없음',
          });
        });
      } else {
        print('Error: No diary content found.');
      }
    } else {
      print('Error fetching diary content: ${response.reasonPhrase}');
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  void _navigateToAddDiaryEntryPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateDiaryPage(),
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DiaryNoImgPage(selectedDate: selectedDay),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Navigated to HomePage with memberId: ${widget.userId}');

    List<Map<String, String>> filteredEntries = _diaryEntries.where((entry) {
      DateTime entryDate = DateTime.parse(
          entry['date']!.split(' ')[0].replaceAll('.', '-'));
      return isSameDay(entryDate, _selectedDay);
    }).toList();

    return CustomScaffold(
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 16),
              // 캘린더 위젯
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: _onDaySelected, // Updated
                ),
              ),
              // 일기 항목들
              Expanded(
                child: ListView.builder(
                  itemCount: filteredEntries.length,
                  itemBuilder: (context, index) {
                    return _buildDiaryEntry(
                      filteredEntries[index]['date']!,
                      filteredEntries[index]['summary']!,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      // 플로팅 액션 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddDiaryEntryPage,
        child: Icon(Icons.edit), // 펜 모양 아이콘으로 변경
        tooltip: '새 일기 추가',
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildDiaryEntry(String date, String summary) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: TextStyle(fontSize: 13, color: Colors.black)),
          SizedBox(height: 10),
          Container(
            width: 139,
            height: 8,
            color: Color(0x7FFFE76B),
          ),
          SizedBox(height: 10),
          Text(
            summary,
            style: TextStyle(fontSize: 13, color: Colors.black),
          ),
          Divider(height: 30),
        ],
      ),
    );
  }
}

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final String? title;
  final bool showAppBar;

  const CustomScaffold({
    Key? key,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.title,
    this.showAppBar = true,
  }) : super(key: key);

  void _navigateToHome(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false, arguments: userId);
  }

  void _navigateToPage(BuildContext context, String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
        backgroundColor: const Color(0xfffffdf9),
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: title != null
            ? Text(title!,
            style: TextStyle(color: Colors.black, fontSize: 15))
            : GestureDetector(
          onTap: () => _navigateToHome(context),
          child: Image.asset(
            'assets/wisely-diary-logo.png',
            height: 30,
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
        actions: [
          ...?actions,
        ],
      )
          : null,
      drawer: Drawer(
        backgroundColor: const Color(0xfffffdf9), // 원래 배경색으로 복원
        child: Stack(
          children: [
            Column(
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xfffffdf9),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/wisely-diary-logo.png',
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '일기로운 슬기생활',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: Icon(Icons.home),
                        title: Text('홈', style: TextStyle(fontSize: 15.0)),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToHome(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('마이페이지', style: TextStyle(fontSize: 15.0)),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToPage(context, '/mypage');
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.analytics),
                        title: Text('감정 통계', style: TextStyle(fontSize: 15.0)),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToPage(context, '/statistics');
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.notifications),
                        title: Text('알림 설정', style: TextStyle(fontSize: 15.0)),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToPage(context, '/notifications');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 로그아웃 버튼을 이모티콘으로 하단에 배치
            Positioned(
              bottom: 16,
              right: 16,
              child: IconButton(
                icon: Icon(Icons.logout, color: Colors.black),
                onPressed: () async {
                  Navigator.pop(context);
                  await _signOut(context);
                },
                tooltip: '로그아웃',
              ),
            ),
          ],
        ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
