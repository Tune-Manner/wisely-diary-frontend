import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'letter_model.dart';
import 'letter_service.dart';

class LetterInquiryPage extends StatefulWidget {
  final String date;

  LetterInquiryPage({Key? key, required this.date}) : super(key: key);

  @override
  _LetterInquiryPageState createState() => _LetterInquiryPageState();
}

class _LetterInquiryPageState extends State<LetterInquiryPage> {
  List<Letter> letters = [];
  bool isLoading = true;
  String? error;
  final LetterService _letterService = LetterService();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchLetterData();
  }

  Future<void> fetchLetterData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        error = '사용자 인증에 실패했습니다.';
        isLoading = false;
      });
      return;
    }

    try {
      final fetchedLetters = await _letterService.inquiryLetter(widget.date, user.id);
      setState(() {
        letters = fetchedLetters;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = '편지를 불러오는 데 실패했습니다: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfffdfbf0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/wisely-diary-logo.png',
          height: 30,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : letters.isEmpty
          ? Center(child: Text('해당 날짜의 편지가 없습니다.'))
          : PageView.builder(
        itemCount: letters.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final letter = letters[index];
          final formattedDate = DateFormat('yyyy년 M월 d일').format(letter.createdAt);
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formattedDate}\n당신에게 도착한 편지',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
                Text(
                  letter.letterContents ?? '내용 없음',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: letters.length > 1
          ? BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          for (int i = 0; i < letters.length; i++)
            BottomNavigationBarItem(
              icon: Icon(Icons.mail),
              label: '편지 ${i + 1}',
            ),
        ],
      )
          : null,
    );
  }
}