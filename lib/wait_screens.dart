import 'package:flutter/material.dart';
import 'package:wisely_diary/select_type_screens.dart';
import 'dart:async';
import 'AudioManager.dart';

class WaitPage extends StatefulWidget {
  final int emotionNumber;

  const WaitPage({Key? key, required this.emotionNumber}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WaitPageState();
}

class _WaitPageState extends State<WaitPage> {
  int _counter = 5;
  Timer? _timer;
  final audioManager = AudioManager();
  late bool isPlaying;
  late double volume;

  @override
  void initState() {
    super.initState();
    _startCountdown();
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

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_counter > 1) {
        setState(() {
          _counter--;
        });
      } else {
        _timer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SelectTypePage(emotionNumber: widget.emotionNumber),
          ),
        );
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        color: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: const Color(0xfffdfbf0),
          ),
          child: Stack(
            children: [
              Positioned(
                left: MediaQuery.of(context).size.width * 0.1,
                top: MediaQuery.of(context).size.height * 0.10,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  '눈을 감고 \n오늘 하루를 돌아봅시다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 30,
                    color: const Color(0xff2c2c2c),
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 9999,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width * 0.45,
                top: MediaQuery.of(context).size.height * 0.35,
                child: Text(
                  '$_counter',
                  style: TextStyle(
                    fontSize: 60,
                    color: const Color(0xff2c2c2c),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}