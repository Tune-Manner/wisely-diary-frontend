import 'package:flutter/material.dart';
import 'dart:io';

class DiarySummaryScreen extends StatelessWidget {
  final String transcription;
  final List<File> imageFiles;

  DiarySummaryScreen({required this.transcription, required this.imageFiles});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

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
                          transcription, // 서버에서 받아온 텍스트
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
                  icon: Icons.music_note,
                  label: "노래 선물받기",
                  onPressed: () => Navigator.pushNamed(context, '/songGift'),
                ),
                _buildButton(
                  context,
                  icon: Icons.image,
                  label: "오늘의 네컷만화",
                  onPressed: () => Navigator.pushNamed(context, '/comic'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  context,
                  icon: Icons.email,
                  label: "친구에게 편지받기",
                  onPressed: () => Navigator.pushNamed(context, '/letter'),
                ),
                _buildButton(
                  context,
                  icon: Icons.save,
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

  Widget _buildButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xff8d83ff),
        foregroundColor: Colors.white,
        minimumSize: Size(MediaQuery.of(context).size.width * 0.35, 50),
        padding: EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}