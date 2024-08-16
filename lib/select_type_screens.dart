import 'package:flutter/material.dart';

class SelectTypePage extends StatefulWidget {
  SelectTypePage({super.key});

  @override
  State<StatefulWidget> createState() => _SelectTypePageState();
}

class _SelectTypePageState extends State<SelectTypePage> {
  void _navigateToNextPage(String type) {
    if (type == 'voice') {
      Navigator.pushNamed(context, '/record');
    } else if (type == 'text') {
      Navigator.pushNamed(context, '/text');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double buttonWidth = screenWidth * 0.8;
    final double buttonHeight = 60.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfffdfbf0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Image.asset(
          'assets/wisely-diary-logo.png',
          height: 30,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xfffdfbf0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // 위쪽으로 배치
          children: [
            SizedBox(height: screenHeight * 0.30), // 화면 위쪽에서 25% 위치로 이동
            ElevatedButton(
              onPressed: () => _navigateToNextPage('voice'),
              child: Text('음성 일기'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(buttonWidth, buttonHeight),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToNextPage('text'),
              child: Text('텍스트 일기'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(buttonWidth, buttonHeight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
