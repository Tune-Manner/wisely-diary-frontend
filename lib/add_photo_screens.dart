import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'AudioManager.dart';
import 'diary_summary_screens.dart';

class AddPhotoScreen extends StatefulWidget {
  final String transcription;

  AddPhotoScreen({required this.transcription});

  @override
  _AddPhotoScreenState createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  final List<File> _imageFiles = [];

  final audioManager = AudioManager();
  late bool isPlaying;
  late double volume;

  @override
  void initState() {
    super.initState();
    isPlaying = audioManager.player.playing;
    volume = audioManager.player.volume;
    audioManager.player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state.playing;
        });
      }
    });
  }

  void togglePlayPause() {
    if (isPlaying) {
      audioManager.player.pause();
    } else {
      audioManager.player.play();
    }
  }

  void changeVolume(double newVolume) {
    setState(() {
      volume = newVolume;
      audioManager.player.setVolume(newVolume);
    });
  }


  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path));
      });
    }
  }

  void _createDiary() {
    audioManager.player.stop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiarySummaryScreen(
          transcription: widget.transcription,
          imageFiles: _imageFiles,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfffdfbf0), // 배경색 통일
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
        actions: [
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: togglePlayPause,
          ),
          Container(
            width: 100,
            child: Slider(
              value: volume,
              min: 0.0,
              max: 1.0,
              onChanged: changeVolume,
            ),
          ),
        ],
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: const Color(0xfffdfbf0), // 전체 배경색 통일
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 파일 추가 버튼과 생성하기 버튼을 화면 중앙에 위치시킴
          children: [
            GestureDetector(
              onTap: _pickImage, // 이미지를 클릭하면 사진 선택
              child: Image.asset(
                'assets/File plus.png', // plus.png 이미지 사용
                width: 60, // 원하는 크기로 조정
                height: 60,
              ),
            ),
            SizedBox(height: 20), // 이미지와 생성하기 버튼 사이의 간격
            ElevatedButton(
              onPressed: _createDiary, // 생성하기 버튼 클릭 시 다이어리 생성
              child: Text('생성하기'),
            ),
          ],
        ),
      ),
    );
  }
}