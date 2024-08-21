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

class _WaitPageState extends State<WaitPage> with TickerProviderStateMixin {
  int _counter = 5;
  Timer? _timer;
  final audioManager = AudioManager();
  late bool isPlaying;
  late double volume;
  bool _showButton = false;
  bool _showCounter = false;

  late AnimationController _backgroundController;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;

  late AnimationController _fadeController1;
  late AnimationController _fadeController2;
  late Animation<double> _fadeAnimation1;
  late Animation<double> _fadeAnimation2;
  String _currentText = '';

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

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation1 = ColorTween(
      begin: Color(0xffFFB703),
      end: Color(0xffFEFAE0),
    ).animate(_backgroundController);

    _colorAnimation2 = ColorTween(
      begin: Color(0xffF6BD60),
      end: Color(0xffEAE2B7),
    ).animate(_backgroundController);

    _fadeController1 = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController2 = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation1 = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController1);
    _fadeAnimation2 = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController2);

    _startAnimation();
  }

  void _startAnimation() async {
    // First text
    setState(() => _currentText = '당신의 하루는 오늘 어땠나요?');
    _fadeController1.forward();
    await Future.delayed(Duration(seconds: 3));
    _fadeController1.reverse();
    await Future.delayed(Duration(seconds: 2));

    // Second text
    setState(() => _currentText = '눈을 감고 \n오늘 하루를 돌아봅시다.');
    _fadeController2.forward();
    await Future.delayed(Duration(seconds: 3));
    _fadeController2.reverse();
    await Future.delayed(Duration(seconds: 2));

    // Show counter and start countdown
    setState(() => _showCounter = true);
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_counter > 1) {
        setState(() {
          _counter--;
        });
      } else {
        setState(() {
          _counter--;
          _showCounter = false;
        });
        timer.cancel();
        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            _showButton = true;
          });
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

  @override
  void dispose() {
    _timer?.cancel();
    _backgroundController.dispose();
    _fadeController1.dispose();
    _fadeController2.dispose();
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
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_colorAnimation1.value!, _colorAnimation2.value!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_fadeAnimation1, _fadeAnimation2]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation1.value + _fadeAnimation2.value,
                        child: Text(
                          _currentText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            color: const Color(0xff2c2c2c),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_showCounter)
                  Center(
                    child: Text(
                      '$_counter',
                      style: TextStyle(
                        fontSize: 60,
                        color: const Color(0xff2c2c2c),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (_showButton)
                  Center(
                    child: Transform.translate(
                      offset: Offset(0, -20),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectTypePage(emotionNumber: widget.emotionNumber),
                            ),
                          );
                        },
                        child: Text('준비됐어요'),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}