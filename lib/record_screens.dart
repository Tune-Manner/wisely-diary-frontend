import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:wisely_diary/diary_summary_screens.dart';

import 'AudioManager.dart'; // JSON 인코딩 및 디코딩을 위해 필요

class RecordScreen extends StatefulWidget {
  final int emotionNumber; // Add this line

  RecordScreen({Key? key, required this.emotionNumber}) : super(key: key); // Update constructor


  @override
  _RecordScreenState createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
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

  Future<void> _startRecording() async {
    final response = await http.post(
      Uri.parse('http://192.168.0.45:8080/api/speech/start-recording'),
    );

    if (response.statusCode == 200) {
      print('Recording started: ${response.body}');
    } else {
      print('Failed to start recording: ${response.statusCode}');
    }
  }

  Future<void> _stopRecording() async {
    final response = await http.post(
      Uri.parse('http://192.168.0.45:8080/api/speech/stop-recording'),
    );

    if (response.statusCode == 200) {
      String transcription = jsonDecode(response.body)['transcription']; // JSON 형식으로 변환된 텍스트 받기
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiarySummaryScreen(
            transcription: transcription,
            imageFiles: [], // 이미지 파일이 있다면 여기 추가
            cartoonUrl: '',
            letterCartoonUrl: '',
          ),
        ),
      );
    } else {
      print('Failed to stop recording: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.emotionNumber}Start Backend Recording'),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _startRecording,
              child: Text('Start Recording'),
            ),
            ElevatedButton(
              onPressed: _stopRecording,
              child: Text('Stop Recording'),
            ),
          ],
        ),
      ),
    );
  }
}
