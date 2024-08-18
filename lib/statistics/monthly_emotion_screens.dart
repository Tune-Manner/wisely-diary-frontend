import 'package:flutter/material.dart';

class MonthlyEmotionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이번 달 감정 통계'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.black),
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 18),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 감정 차트
            Text(
              "이번 달 00님 감정",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // 차트는 나중에 구현할 수 있습니다
            Container(
              height: 200,
              child: Placeholder(),
            ),
            SizedBox(height: 32),
            // 주된 감정 이미지와 텍스트
            Column(
              children: [
                Image.asset(
                  'assets/angry_face.png',
                  height: 100,
                ),
                SizedBox(height: 16),
                Text(
                  '7월 00님의 메인 감정은',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '분노',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            SizedBox(height: 32),
            // 감정 달력
            Text(
              "감정 달력",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: 12,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Expanded(
                        child: Image.asset(
                          'assets/emotion_${index + 1}.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${index + 1}월',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
