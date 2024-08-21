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
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeHomeScreen();
  }

  // Home 화면이 다시 보여질 때마다 초기화
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializationFuture = _initializeHomeScreen();
  }

  Future<void> _initializeHomeScreen() async {
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    await initializeDateFormatting('ko_KR', null);
    await _fetchMonthlyDiaries(_focusedDay);
  }

  Future<void> _fetchMonthlyDiaries(DateTime month) async {
    String date = DateFormat('yyyy-MM-01').format(month);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.123.103:8080/api/diary/monthly'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'date': date,
          'memberId': widget.userId,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _monthlyDiaryEntries = data.map((item) => {
            'date': item['date'],
            'content': item['diaryContents'],
          }).toList();
          _monthlyDiaryEntries.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
        });
      } else {
        print('Error fetching diary content: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception occurred while fetching monthly diaries: $e');
    }
  }

  Future<void> _fetchDiaryContent(DateTime selectedDay) async {
    final response = await http.post(
      Uri.parse('http://192.168.123.103:8080/api/diary/selectdetail'),
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
          'content': data['diaryContents'],
        };
      });
    } else {
      print('Error fetching diary content: ${response.reasonPhrase}');
      setState(() {
        _selectedDayEntry = {
          'date': selectedDay.toIso8601String().split('T').first,
          'content': '일기 내용을 가져오는 중 오류가 발생했습니다.',
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
      _selectedDayEntry = null;
    });
    _fetchDiaryContent(selectedDay);
  }

  void _navigateToDiaryNoImgPage(DateTime selectedDate) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DiaryNoImgPage(selectedDate: selectedDate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: FutureBuilder<void>(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Column(
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
                  child: _monthlyDiaryEntries.isEmpty
                      ? _buildEmptyState()
                      : SingleChildScrollView(
                    child: Column(
                      children: _monthlyDiaryEntries.map((entry) =>
                          _buildDiaryEntry(entry['date'], entry['content'])
                      ).toList(),
                    ),
                  ),
                ),
              ],
            );
          }
        },
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
    return GestureDetector(
      onTap: () => _navigateToDiaryNoImgPage(DateTime.parse(date)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 13,
                  left: 0,
                  child: Container(
                    width: 95,
                    height: 8,
                    color: Color(0x7FFFE76B),
                  ),
                ),
                Text(date, style: TextStyle(fontSize: 15, color: Colors.black)),
              ],
            ),
            SizedBox(height: 15),
            Text(
              content,
              style: TextStyle(fontSize: 13, color: Colors.black),
            ),
            Divider(height: 30),
          ],
        ),
      ),
    );
  }

  // 작성된 일기가 없을때
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.5, // 0.0에서 1.0 사이의 값. 0.0은 완전 투명, 1.0은 완전 불투명
            child: Image.asset(
              'assets/wisely-diary-logo.png',
              height: 80,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '작성한 일기가 없습니다.\n일기를 작성해보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}