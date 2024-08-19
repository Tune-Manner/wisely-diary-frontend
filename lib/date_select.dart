import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cartoon_inquery.dart';

class DiaryNoImgPage extends StatefulWidget {
  final DateTime selectedDate;

  const DiaryNoImgPage({
    Key? key,
    required this.selectedDate
  }) : super(key: key);

  @override
  _DiaryNoImgPageState createState() => _DiaryNoImgPageState();
}

class _DiaryNoImgPageState extends State<DiaryNoImgPage> {
  String? diarySummaryContents;
  bool isLoading = true;
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;
  String? memberId;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        memberId = user.id;
      });
      _loadDiarySummary();
    } else {
      print('User is not authenticated');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadDiarySummary() async {
    if (memberId == null) {
      print('Member ID is null');
      setState(() {
        isLoading = false;
      });
      return;
    }

    // final url = Uri.parse('http://localhost:8080/api/diary/selectdetail');
    final url = Uri.parse('http://10.0.2.2:8080/api/diary/selectdetail');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'memberId': memberId,
          'date': DateFormat('yyyy-MM-dd').format(widget.selectedDate),
        }),
      );


      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // 이 부분에서 if (mounted) 체크를 추가합니다.
        if (mounted) {
          setState(() {
            diarySummaryContents = jsonResponse['diary_summary_contents'];
            isLoading = false;
          });
        }
      } else {
        print('Failed to load diary summary. Status code: ${response.statusCode}');

        // 여기에도 if (mounted) 체크를 추가합니다.
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading diary summary: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  void _toggleGiftMenu() {
    setState(() {
      if (!_isOverlayVisible) {
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context)!.insert(_overlayEntry!);
        _isOverlayVisible = true;
      } else {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _isOverlayVisible = false;
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: 90,
        right: 25,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 75,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Image.asset('assets/music_icon.png'),
                    SizedBox(height: 4),
                    Text('맞춤노래', style: TextStyle(fontSize: 10)),
                  ],
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    _overlayEntry?.remove();
                    _overlayEntry = null;
                    _isOverlayVisible = false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartoonInquiryScreen(selectedDate: widget.selectedDate),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Image.asset('assets/cuttoon_icon.png'),
                      SizedBox(height: 4),
                      Text('하루만화', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Column(
                  children: [
                    Image.asset('assets/letter_icon.png'),
                    SizedBox(height: 4),
                    Text('위로의 편지', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFF9F2),
        elevation: 0,
        leadingWidth: 100,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                // 햄버거 메뉴 클릭 시 동작 정의
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: Color(0xFFFFF9F2),
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                DateFormat('yyyy.MM.dd EEEE').format(widget.selectedDate),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.insert_emoticon, color: Color(0xFFE9D899)),
                                SizedBox(width: 4),
                                Icon(Icons.edit, color: Colors.black),
                                SizedBox(width: 4),
                                Icon(Icons.delete, color: Colors.black),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        Expanded(
                          child: Text(
                            diarySummaryContents ?? '일기 요약을 불러올 수 없습니다.',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            right: 25,
            child: GestureDetector(
              onTap: _toggleGiftMenu,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(0xFF8D83FF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      'assets/gift_icon.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}