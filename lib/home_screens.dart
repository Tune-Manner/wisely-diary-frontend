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

  Future<bool> _checkTodayDiaryExists() async {
    final supabase = Supabase.instance.client;
    final today = DateTime.now().toUtc().toString().split(' ')[0]; // Get today's date in UTC

    final response = await supabase
        .from('diary')
        .select()
        .eq('member_id', widget.userId)
        .eq('diary_status', 'EXIST')
        .gte('created_at', '$today 00:00:00')
        .lte('created_at', '$today 23:59:59');

    return response.length > 0;
  }

  void _navigateToAddDiaryEntryPage() async {
    bool todayDiaryExists = await _checkTodayDiaryExists();

    if (!todayDiaryExists) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('알림'),
            content: Text('이미 오늘 일기를 작성하셨습니다.'),
            actions: <Widget>[
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CreateDiaryPage(),
        ),
      );
    }
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

    return CustomScaffold(
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 16),
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
                  onDaySelected: _onDaySelected,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _diaryEntries.length,
                  itemBuilder: (context, index) {
                    return _buildDiaryEntry(
                      _diaryEntries[index]['date']!,
                      _diaryEntries[index]['summary']!,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddDiaryEntryPage,
        child: Icon(Icons.edit),
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
