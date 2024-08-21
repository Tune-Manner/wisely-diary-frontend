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

  HomeScreens({required this.userId}) : assert(userId.isNotEmpty, 'userId cannot be empty');

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreens> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  List<Map<String, dynamic>> _monthlyDiaryEntries = [];
  Map<String, dynamic>? _selectedDayEntry;
  late Future<void> _initializationFuture;  // Future 타입 변수 선언

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();

    initializeDateFormatting('ko_KR', null).then((_) {
      setState(() {});
    });

    // 페이지가 로드될 때 데이터를 초기화하는 Future 실행
    _initializationFuture = _fetchMonthlyDiaries(_focusedDay);
  }

  // 매달 일기 데이터를 가져오는 Future 함수
  Future<void> _fetchMonthlyDiaries(DateTime month) async {
    String date = DateFormat('yyyy-MM-01').format(month);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.184:8080/api/diary/monthly'),
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

  // 특정 날짜의 일기 내용을 가져오는 Future 함수
  Future<void> _fetchDiaryContent(DateTime selectedDay) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.184:8080/api/diary/selectdetail'),
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

  // 로그아웃 함수
  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  // 새 일기 추가 페이지로 이동하는 함수
  void _navigateToAddDiaryEntryPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateDiaryPage(),
      ),
    );
  }

  // 날짜를 선택할 때마다 해당 날짜의 일기 데이터를 가져오는 함수
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedDayEntry = null;
    });
    _fetchDiaryContent(selectedDay);
  }

  // 일기 상세 페이지로 이동하는 함수
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
      // FutureBuilder로 페이지 초기화 및 데이터를 다시 로드
      body: FutureBuilder<void>(
        future: _initializationFuture,
        builder: (context, snapshot) {
          // 비동기 작업이 완료되기 전 로딩 표시
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // 오류 발생 시 메시지 표시
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // 비동기 작업이 완료되면 UI 구성
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
                      _initializationFuture = _fetchMonthlyDiaries(focusedDay);  // 페이지 변경 시 월간 데이터를 다시 로드
                    },
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // 일기 목록을 위한 Expanded와 ListView.builder 사용
                Expanded(
                  child: _monthlyDiaryEntries.isEmpty
                      ? _buildEmptyState()
                      : SingleChildScrollView(
                    child: _selectedDayEntry != null
                        ? _buildDiaryEntry(_selectedDayEntry!['date'], _selectedDayEntry!['content'])
                        : Column(
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
      // 새 일기 추가 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddDiaryEntryPage,
        child: Icon(Icons.edit),
        tooltip: '새 일기 추가',
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.white,
      ),
    );
  }

  // 일기 항목을 생성하는 위젯
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

  // 작성된 일기가 없을 때 보여줄 UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.5, // 투명도 설정
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
