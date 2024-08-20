import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wisely_diary/main.dart';
import 'create_diary_screens.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'custom_scaffold.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  List<Map<String, dynamic>> _monthlyDiaryEntries = [];
  Map<String, dynamic>? _selectedDayEntry;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();

    initializeDateFormatting('ko_KR', null).then((_) {
      setState(() {});
    });

    _fetchMonthlyDiaries(_focusedDay);
  }

  Future<void> _fetchMonthlyDiaries(DateTime month) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/diary/selectmonth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'year': month.year,
        'month': month.month,
        'memberId': widget.userId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null && data['diaries'] != null) {
        setState(() {
          _monthlyDiaryEntries = List<Map<String, dynamic>>.from(data['diaries']);
          _monthlyDiaryEntries.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
        });
      } else {
        print('Error: No diary content found.');
      }
    } else {
      print('Error fetching diary content: ${response.reasonPhrase}');
    }
  }

  Future<void> _fetchDiaryContent(DateTime selectedDay) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/diary/selectdetail'),
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

      setState(() {
        _selectedDayEntry = {
          'date': selectedDay.toIso8601String().split('T').first,
          'content': data != null && data['diaryContents'] != null
              ? data['diaryContents']
              : '해당 날짜에 해당하는 일기가 없습니다.',
        };
      });
    } else {
      print('Error fetching diary content: ${response.reasonPhrase}');
      setState(() {
        _selectedDayEntry = {
          'date': selectedDay.toIso8601String().split('T').first,
          'content': '해당 날짜에 해당하는 일기가 없습니다.',
        };
      });
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
      _selectedDayEntry = null;
    });
    _fetchDiaryContent(selectedDay);
  }

  void _navigateToDiaryNoImgPage(DateTime selectedDate) {
    if (_selectedDayEntry != null && _selectedDayEntry!['content'] != '해당 날짜에 해당하는 일기가 없습니다.') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DiaryNoImgPage(selectedDate: selectedDate),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Column(
        children: [
          SizedBox(height: 16),
          // 달력 부분
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
              locale: 'ko_KR',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                  _selectedDayEntry = null;
                });
                _fetchMonthlyDiaries(focusedDay);
              },
            ),
          ),
          SizedBox(height: 16),

          // 일기 목록을 위한 Expanded와 ListView.builder 사용
          Expanded(
            child: SingleChildScrollView(
              child: _selectedDayEntry != null
                  ? GestureDetector(
                onTap: () => _navigateToDiaryNoImgPage(DateTime.parse(_selectedDayEntry!['date'])),
                child: _buildDiaryEntry(_selectedDayEntry!['date'], _selectedDayEntry!['content']),
              )
                  : Column(
                children: _monthlyDiaryEntries.map((entry) =>
                    _buildDiaryEntry(entry['date'], entry['content'])
                ).toList(),
              ),
            ),
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

  // 일기 항목을 생성
  Widget _buildDiaryEntry(String date, String content) {
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
            content,
            style: TextStyle(fontSize: 13, color: Colors.black),
          ),
          Divider(height: 30),
        ],
      ),
    );
  }
}
