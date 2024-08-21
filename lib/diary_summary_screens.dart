import 'dart:ffi' as ffi;

import 'package:flutter/material.dart';
import 'package:wisely_diary/music/music_creation_page.dart';
import 'package:wisely_diary/today_cartoon.dart';
import 'dart:io';
import 'cartoon_creation_status.dart';
import 'custom_scaffold.dart';
import 'package:wisely_diary/letter/letter_creation_status_page.dart';

class DiarySummaryScreen extends StatelessWidget {
  final String transcription;
  final List<File> imageFiles;
  final int diaryCode;


  DiarySummaryScreen({
    required this.transcription,
    required this.imageFiles,
    required this.diaryCode,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return CustomScaffold(
      body: Container(
        color: const Color(0xfffdfbf0),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              "오늘의 일기에요",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 20),
            Container(
              width: screenWidth * 0.8,
              height: screenHeight * 0.4,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '일기 코드: $diaryCode', // diaryCode 출력, 추후에 삭제해야함
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        SizedBox(height: 10),
                        Text(
                          transcription,
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        SizedBox(height: 10),
                        if (imageFiles.isNotEmpty)
                          Column(
                            children: imageFiles.map((file) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Image.file(file, width: screenWidth * 0.7),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/wisely-diary-logo.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  context,
                  iconPath: 'assets/music_icon.png',
                  label: "노래 선물 받기",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MusicCreationStatusPage(diaryCode: diaryCode),
                    ),
                  ),
                  ),
                _buildButton(
                  context,
                  iconPath: 'assets/cuttoon_icon.png',
                  label: "오늘의 만화",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartoonCreationStatusPage(diaryCode: diaryCode),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  context,
                  iconPath: 'assets/letter_icon.png',
                  label: "친구에게 편지 받기",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LetterCreationStatusPage(diaryCode: diaryCode),
                    ),
                  ),
                ),
                _buildButton(
                  context,
                  iconPath: 'assets/diary_icon.png',
                  label: "일기만 저장하기",
                  onPressed: () => Navigator.pushNamed(context, '/saveDiary'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required String iconPath, required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFE5E1FF),
        foregroundColor: Colors.black,
        minimumSize: Size(MediaQuery.of(context).size.width * 0.35, 50),
        padding: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, width: 30, height: 30),
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
