import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wisely_diary/edit_diary_screens.dart';
import 'cartoon_inquery.dart';

class DiaryNoImgPage extends StatefulWidget {
  final DateTime selectedDate;

  const DiaryNoImgPage({
    Key? key,
    required this.selectedDate,
  }) : super(key: key);

  @override
  _DiaryNoImgPageState createState() => _DiaryNoImgPageState();
}

class _DiaryNoImgPageState extends State<DiaryNoImgPage> {
  String? diaryContent;
  List<String> imageUrls = [];
  bool isLoading = true;
  int? diaryCode;
  String? memberId;
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;

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
      await _loadDiaryData();
    } else {
      print('User is not authenticated');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadDiaryData() async {
    await _loadImages();
    await _loadDiaryContent();
  }

  Future<void> _loadImages() async {
    if (memberId == null) {
      print('Member ID is null');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://43.203.173.116:8080/api/diary/selectdetail'),
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
        setState(() {
          diaryCode = jsonResponse['diaryCode'];
        });
      } else {
        print('Failed to load diary code. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading diary code: $e');
      return;
    }

    if (diaryCode == null) {
      print('Diary code is null');
      return;
    }

    final url = Uri.parse('http://43.203.173.116:8080/api/images/diary/$diaryCode');
    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          imageUrls = jsonResponse
              .map((image) => image['imagePath'] as String)
              .toList();
        });
      } else {
        print('Failed to load images. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading images: $e');
    }
  }

  Future<void> _loadDiaryContent() async {
    if (memberId == null) {
      print('Member ID is null');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('http://43.203.173.116:8080/api/diary/selectdetail');
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

        if (mounted) {
          setState(() {
            diaryContent = jsonResponse['diaryContents'];
            isLoading = false;
          });
        }
      } else {
        print('Failed to load diary content. Status code: ${response.statusCode}');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading diary content: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _editDiary() async {
    _removeOverlayIfVisible(); // 페이지 이동 전 오버레이 제거
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditDiaryPage(
          diaryCode: diaryCode!,
          initialContent: diaryContent!,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        isLoading = true;
      });

      await _loadDiaryContent();

      setState(() {
        isLoading = false;
      });
    }
  }

  void _showImagePopup(int initialIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.infinity,
            height: 400,
            child: PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Image.network(
                  imageUrls[index],
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
        );
      },
    );
  }

  // 선물 상자 토글
  void _toggleGiftMenu() {
    setState(() {
      if (!_isOverlayVisible) {
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(_overlayEntry!);
        _isOverlayVisible = true;
      } else {
        _removeOverlayIfVisible();
      }
    });
  }

  void _removeOverlayIfVisible() {
    if (_isOverlayVisible) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOverlayVisible = false;
    }
  }

  // 페이지가 닫힐 때 오버레이가 남아있지 않도록 제거
  @override
  void dispose() {
    _removeOverlayIfVisible(); // dispose 시 오버레이 제거
    super.dispose();
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
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
                    _removeOverlayIfVisible(); // 페이지 이동 전 오버레이 제거
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
        backgroundColor: const Color(0xfffdfbf0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            _removeOverlayIfVisible(); // 뒤로 가기 전 오버레이 제거
            Navigator.pop(context);
          },
        ),
        title: GestureDetector(
          onTap: () {
            _removeOverlayIfVisible(); // 홈으로 가기 전 오버레이 제거
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: Image.asset(
            'assets/wisely-diary-logo.png',
            height: 30,
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/Edit.png',
              height: 30,
              width: 30,
            ),
            onPressed: _editDiary,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (imageUrls.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _showImagePopup(0);
                    },
                    child: Container(
                      height: 200,
                      child: Stack(
                        children: [
                          Image.network(
                            imageUrls.first,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          if (imageUrls.length > 1)
                            Positioned(
                              right: 10,
                              bottom: 10,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '+${imageUrls.length - 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 16.0),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Text(
                              diaryContent ?? '일기 내용을 불러올 수 없습니다.',
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
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
