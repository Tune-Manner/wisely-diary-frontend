import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LetterViewPage extends StatefulWidget {
  final int letterCode;

  LetterViewPage({required this.letterCode});

  @override
  _LetterViewPageState createState() => _LetterViewPageState();
}

class _LetterViewPageState extends State<LetterViewPage> {
  Future<Map<String, dynamic>>? _letterDataFuture;

  @override
  void initState() {
    super.initState();
    _letterDataFuture = _fetchLetterData();
  }

  Future<Map<String, dynamic>> _fetchLetterData() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/letter/${widget.letterCode}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load letter: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching letter data: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('편지 보기'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _letterDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _letterDataFuture = _fetchLetterData();
                      });
                    },
                    child: Text('다시 시도'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final letterData = snapshot.data!;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 편지',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '작성일: ${letterData['createdAt'] ?? '알 수 없음'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 24),
                  Text(
                    letterData['letterContents'] ?? '내용 없음',
                    style: TextStyle(fontSize: 16),
                  ),
                  // 여기에 추가적인 편지 정보를 표시할 수 있습니다.
                ],
              ),
            );
          } else {
            return Center(child: Text('편지를 찾을 수 없습니다.'));
          }
        },
      ),
    );
  }
}