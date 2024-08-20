import 'package:flutter/material.dart';
import 'dart:async';
import 'letter_view_page.dart';
import 'letter_service.dart';

class LetterCreationStatusPage extends StatefulWidget {
  final int diaryCode;

  LetterCreationStatusPage({required this.diaryCode});

  @override
  _LetterCreationStatusPageState createState() => _LetterCreationStatusPageState();
}

class _LetterCreationStatusPageState extends State<LetterCreationStatusPage> {
  final LetterService _letterService = LetterService();
  bool _isLoading = true;
  final List<String> _statusMessages = [
    '편지를 가져오고 있어요...',
    '친구가 당신의 하루를 생각하고 있어요...',
    '따뜻한 말을 고르고 있어요...',
    '정성스럽게 편지를 쓰고 있어요...',
    '편지에 마음을 담고 있어요...',
  ];
  int _currentMessageIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startVisualSimulation();
    _getOrCreateLetter();
  }

  void _startVisualSimulation() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _statusMessages.length;
        });
      }
    });
  }

  Future<void> _getOrCreateLetter() async {
    try {
      final letter = await _letterService.getOrCreateLetter(widget.diaryCode);

      // 시각적 효과를 위해 약간의 지연 추가
      await Future.delayed(Duration(seconds: 2));

      _navigateToLetterView(letter.letterCode);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('편지 생성 또는 조회에 실패했습니다: $e')),
      );
      // 오류 발생 시 이전 페이지로 돌아가기
      Navigator.of(context).pop();
    }
  }

  void _navigateToLetterView(int letterCode) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LetterViewPage(letterCode: letterCode),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('편지 생성 중')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(_statusMessages[_currentMessageIndex]),
          ],
        ),
      ),
    );
  }
}