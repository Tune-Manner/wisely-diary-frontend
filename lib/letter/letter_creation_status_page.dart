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
  String _statusMessage = '편지를 생성하고 있어요...';
  final List<String> _statusMessages = [
    '친구가 당신의 하루를 생각하고 있어요...',
    '따뜻한 말을 고르고 있어요...',
    '정성스럽게 편지를 쓰고 있어요...',
    '편지에 마음을 담고 있어요...',
  ];
  int _currentMessageIndex = 0;
  late Timer _timer;
  int? _letterCode;

  @override
  void initState() {
    super.initState();
    _createLetterAndCheck();
  }

  Future<void> _createLetterAndCheck() async {
    try {
      _letterCode = await _letterService.createLetter(widget.diaryCode);
      _startVisualSimulation();
      _checkLetterStatus();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '편지 생성 요청에 실패했습니다: $e';
      });
    }
  }

  void _startVisualSimulation() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _currentMessageIndex = (_currentMessageIndex + 1) % _statusMessages.length;
        _statusMessage = _statusMessages[_currentMessageIndex];
      });
    });
  }

  Future<void> _checkLetterStatus() async {
    while (_isLoading) {
      await Future.delayed(Duration(seconds: 5));
      try {
        final isReady = await _letterService.checkLetterStatus(_letterCode!);
        if (isReady) {
          _timer.cancel();
          _navigateToLetterView();
          break;
        }
      } catch (e) {
        print('Error checking letter status: $e');
      }
    }
  }

  void _navigateToLetterView() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LetterViewPage(letterCode: _letterCode!),
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
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }
}