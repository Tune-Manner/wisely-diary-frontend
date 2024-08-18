import 'dart:convert'; // JSON 디코딩을 위해 사용
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

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
                FutureBuilder<Map<String, dynamic>>(
                  future: fetchEmotionData(), // 비동기 데이터 요청
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator()); // 데이터 로딩 중
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}')); // 오류 발생 시
                    } else if (snapshot.hasData) {
                      // 먼저 Map<String, dynamic>으로 받고 변환 작업을 수행
                      Map<String, dynamic> rawYearlyEmotions = snapshot.data!['yearlyEmotions'];

                      // 키와 값을 변환해서 Map<int, int>로 만듦
                      Map<int, int> yearlyEmotions = rawYearlyEmotions.map((key, value) {
                        return MapEntry(int.parse(key), value as int);
                      });

                      return _buildEmotionTable(yearlyEmotions);
                    } else {
                      return Center(child: Text('No Data Available'));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HTTP 요청을 보내서 감정 데이터를 받아오는 함수
  Future<Map<String, dynamic>> fetchEmotionData() async {
    final url = Uri.parse('http://192.168.123.103:8080/api/statistics/inquire');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "memberId": "d199580f-bf69-4559-93b7-fe8a8ff018cf", // 예시로 memberId와 date를 보냅니다.
        "date": "2024-08-18"
      }),
    );

    if (response.statusCode == 200) {
      print("성공");
      print(response.body);
      return json.decode(response.body); // 서버로부터 받은 JSON 데이터를 디코딩
    } else {
      print("실패");
      print(response.body);
      throw Exception('Failed to load emotion data');
    }
  }

  // 감정 달력을 생성하는 함수
  Widget _buildEmotionTable(Map<int, int> yearlyEmotions) {
    // 감정 코드와 이모티콘 이미지 파일을 매핑
    final Map<int, String> emotionImageMap = {
      1: 'assets/emotions/worried.png',
      2: 'assets/emotions/proud.png',
      3: 'assets/emotions/greatful.png',
      4: 'assets/emotions/injustice.png',
      5: 'assets/emotions/anger.png',
      6: 'assets/emotions/sad.png',
      7: 'assets/emotions/joy.png',
      8: 'assets/emotions/lovely.png',
      9: 'assets/emotions/relax.png',
      10: 'assets/emotions/embarrassed.png'
    };

    return Table(
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
            Center(child: _buildEmotionIcon(1, yearlyEmotions, emotionImageMap)),
            Center(child: _buildEmotionIcon(2, yearlyEmotions, emotionImageMap)),
            Center(child: _buildEmotionIcon(3, yearlyEmotions, emotionImageMap)),
            Center(child: _buildEmotionIcon(4, yearlyEmotions, emotionImageMap)),
            Center(child: _buildEmotionIcon(5, yearlyEmotions, emotionImageMap)),
            Center(child: _buildEmotionIcon(6, yearlyEmotions, emotionImageMap)),
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
            Center(child: _buildEmotionIcon(7, yearlyEmotions, emotionImageMap)),
            Center(child: _buildEmotionIcon(8, yearlyEmotions, emotionImageMap)),
            Center(child: _buildEmotionIcon(9, yearlyEmotions, emotionImageMap)),
            Center(child: _buildEmotionIcon(10, yearlyEmotions, emotionImageMap)),
            Center(child: _buildEmotionIcon(11, yearlyEmotions, emotionImageMap)),
            Center(child: _buildEmotionIcon(12, yearlyEmotions, emotionImageMap)),
          ],
        ),
      ],
    );
  }

  // emotion_code에 맞는 이모티콘 이미지를 반환하는 함수
  Widget _buildEmotionIcon(int month, Map<int, int> yearlyEmotions, Map<int, String> emotionImageMap) {
    int? emotionCode = yearlyEmotions[month]; // 해당 월의 감정 코드 가져오기

    if (emotionCode != null && emotionImageMap.containsKey(emotionCode)) {
      return Image.asset(
        emotionImageMap[emotionCode]!, // 감정 코드에 맞는 이미지 경로 반환
        height: 70,
        width: 70,
      );
    } else {
      return SizedBox(height: 70, width: 70); // 감정 코드가 없으면 빈 공간 반환
    }
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
    final radius = size.height - 100;

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
