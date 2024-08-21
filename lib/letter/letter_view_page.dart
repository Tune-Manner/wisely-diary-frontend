import 'package:flutter/material.dart';
import 'letter_model.dart';
import 'letter_service.dart';

class LetterViewPage extends StatefulWidget {
  final int letterCode;

  LetterViewPage({required this.letterCode});

  @override
  _LetterViewPageState createState() => _LetterViewPageState();
}

class _LetterViewPageState extends State<LetterViewPage> {
  Future<Letter>? _letterDataFuture;
  final LetterService _letterService = LetterService();

  @override
  void initState() {
    super.initState();
    _letterDataFuture = _fetchLetterData();
  }

  Future<Letter> _fetchLetterData() async {
    try {
      return await _letterService.viewLetter(widget.letterCode);
    } catch (e) {
      print('Error fetching letter data: $e');
      rethrow;
    }
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
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          },
          child: Image.asset(
            'assets/wisely-diary-logo.png',
            height: 30,
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Letter>(
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
            final letter = snapshot.data!;
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
                    '작성일: ${letter.createdAt ?? '알 수 없음'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 24),
                  Text(
                    letter.letterContents ?? '내용 없음',
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