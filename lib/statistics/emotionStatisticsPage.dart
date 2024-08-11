import 'package:flutter/material.dart';

class EmotionStatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFBF0), // 전체 배경색 설정
      appBar: AppBar(
        title: Text(
          '이번 달 00님 감정',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // 감정 도넛 차트 이미지
                Image.asset('assets/emotion_donut_chart.png'), // 여기에 이미지를 불러옵니다.
                SizedBox(height: 16),
                // 메인 감정 이미지 및 텍스트
                Image.asset('assets/main_emotion_image.png'), // 여기에 메인 감정 이미지를 불러옵니다.
                SizedBox(height: 16),
                Text(
                  '7월 00님의 메인 감정은',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  '분노',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                Text(
                  '입니다.',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 16),
                // 월별 감정 통계 테이블
                Table(
                  border: TableBorder.all(color: Colors.black),
                  children: [
                    TableRow(children: _buildTableCells(['1월', '2월', '3월', '4월', '5월', '6월'])),
                    TableRow(children: _buildTableCellsWithImages(['happy.png', 'sad.png', 'neutral.png', 'angry.png', 'angry.png', 'neutral.png'])),
                    TableRow(children: _buildTableCells(['7월', '8월', '9월', '10월', '11월', '12월'])),
                    TableRow(children: _buildTableCellsWithImages(['', '', '', '', '', ''])),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 함수: 텍스트 셀을 생성합니다.
  List<Widget> _buildTableCells(List<String> texts) {
    return texts.map((text) => Center(child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: TextStyle(fontSize: 16)),
    ))).toList();
  }

  // 함수: 이미지를 포함한 셀을 생성합니다.
  List<Widget> _buildTableCellsWithImages(List<String> imageNames) {
    return imageNames.map((imageName) {
      if (imageName.isEmpty) {
        return Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text('')));
      } else {
        return Center(child: Image.asset('assets/$imageName', height: 50, width: 50));
      }
    }).toList();
  }
}
