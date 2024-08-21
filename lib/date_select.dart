import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wisely_diary/edit_diary_screens.dart';

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
        Uri.parse('http://10.0.2.2:8080/api/diary/selectdetail'),
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

    final url = Uri.parse('http://10.0.2.2:8080/api/images/diary/$diaryCode');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
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
            color: Color(0xFFFFF9F2),
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
        ],
      ),
    );
  }
}
