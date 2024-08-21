import 'package:flutter/material.dart';
import 'letter_model.dart';
import 'letter_service.dart';

class LetterViewPage extends StatefulWidget {
  final int letterCode;
  final String? cartoonUrl;

  LetterViewPage({required this.letterCode, this.cartoonUrl});

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
                  SizedBox(height: 24),
                  Divider(thickness: 2), // Add a dividing line
                  SizedBox(height: 24),
                  if (widget.cartoonUrl != null) ...[
                    Text(
                      '당신의 감정을 그려보았어요.', // Change text
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic, // Make it distinct from the letter font
                      ),
                    ),
                    SizedBox(height: 10),
                    FadeInImage(
                      placeholder: AssetImage('assets/loading_spinner.gif'),
                      image: NetworkImage(widget.cartoonUrl!),
                      fit: BoxFit.contain,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Text('이미지를 불러오지 못했습니다.', style: TextStyle(color: Colors.red));
                      },
                    ),
                  ],
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
