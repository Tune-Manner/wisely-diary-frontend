import 'package:flutter/material.dart';

class MonthlyEmotionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF9E2),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFF9E2),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 감정 차트 제목
              Stack(
                children: [
                  // 형광펜 효과
                  Positioned(
                    top: 16,
                    left: 0,
                    child: Container(
                      width: 150,
                      height: 20,
                      color: Colors.yellow.withOpacity(0.5),
                    ),
                  ),
                  // 텍스트
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "이번 달 00님 감정",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // 차트
              Container(
                height: 200,
                child: Placeholder(), // 여기에 차트가 들어갈 예정
              ),
              // 주된 감정 이미지와 텍스트
              Column(
                children: [
                  Image.asset(
                    'assets/emotions/anger.png',
                    height: 180,
                  ),
                  Text(
                    '분노(47%)',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // 감정 달력
              Table(
                border: TableBorder.all(color: Colors.grey, width: 1),
                children: [
                  TableRow(
                    children: [
                      Center(child: Text('1월')),
                      Center(child: Text('2월')),
                      Center(child: Text('3월')),
                      Center(child: Text('4월')),
                      Center(child: Text('5월')),
                      Center(child: Text('6월')),
                    ],
                  ),
                  TableRow(
                    children: [
                      Center(child: Image.asset('assets/emotions/joy.png', height: 70, width: 70)),       // 1월: joy
                      Center(child: Image.asset('assets/emotions/embarrassed.png', height: 70, width: 70)), // 2월: embarrassed
                      Center(child: Image.asset('assets/emotions/worried.png', height: 70, width: 70)),    // 3월: worried
                      Center(child: Image.asset('assets/emotions/anger.png', height: 70, width: 70)),       // 4월: anger
                      Center(child: Image.asset('assets/emotions/sad.png', height: 70, width: 70)),        // 5월: sad
                      Center(child: Image.asset('assets/emotions/relax.png', height: 70, width: 70)),      // 6월: relax
                    ],
                  ),
                  TableRow(
                    children: [
                      Center(child: Text('7월')),
                      Center(child: Text('8월')),
                      Center(child: Text('9월')),
                      Center(child: Text('10월')),
                      Center(child: Text('11월')),
                      Center(child: Text('12월')),
                    ],
                  ),
                  TableRow(
                    children: [
                      Center(child: Image.asset('assets/emotions/proud.png', height: 70, width: 70)),       // 7월: proud
                      Center(child: Image.asset('assets/emotions/lovely.png', height: 70, width: 70)),      // 8월: lovely
                      Center(child: Image.asset('assets/emotions/injustice.png', height: 70, width: 70)),   // 9월: injustice
                      Center(child: Image.asset('assets/emotions/greatful.png', height: 70, width: 70)),    // 10월: greatful
                      Center(child: Image.asset('assets/emotions/embarrassed.png', height: 70, width: 70)), // 11월: embarrassed
                      Center(child: Image.asset('assets/emotions/joy.png', height: 70, width: 70)),         // 12월: joy
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
