import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
        child: SingleChildScrollView(
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
                // 커스텀 반원 차트
                SizedBox(
                  height: 200,
                  child: CustomSemiDonutChart(),
                ),
                // 주된 감정 이미지와 텍스트
                Column(
                  children: [
                    Image.asset(
                      'assets/emotions/anger.png',
                      height: 200,
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(fontSize: 18, color: Colors.black),
                        children: [
                          TextSpan(text: '7월 00님의 메인 감정은\n'),
                          TextSpan(
                            text: '분노(47%)',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          TextSpan(text: '입니다',
                              style: TextStyle(fontSize: 18)),
                        ],
                      ),
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

      ),
    );
  }
}

class CustomSemiDonutChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(300, 150), // 차트의 크기 조정
      painter: SemiDonutPainter(),
    );
  }
}

class SemiDonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height;
    final radius = size.height -100;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 100.0;

    final List<EmotionData> emotions = [
      EmotionData('분노', 0.47, Colors.red),
      EmotionData('슬픔', 0.30, Colors.blue),
      EmotionData('역움', 0.10, Colors.green),
      EmotionData('기쁨', 0.08, Colors.yellow),
      EmotionData('설렘', 0.05, Colors.purple),
    ];

    double startAngle = pi;
    for (var emotion in emotions) {
      final sweepAngle = emotion.percentage * pi;
      paint.color = emotion.color;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      // 텍스트 추가
      final textAngle = startAngle + (sweepAngle / 2);
      final textX = centerX + radius * cos(textAngle);
      final textY = centerY + radius * sin(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: emotion.name,
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(textX - textPainter.width / 2, textY - textPainter.height / 2));

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EmotionData {
  final String name;
  final double percentage;
  final Color color;

  EmotionData(this.name, this.percentage, this.color);
}