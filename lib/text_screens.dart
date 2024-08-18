import 'package:flutter/material.dart';
import 'AudioManager.dart';
import 'add_photo_screens.dart';

class TextPage extends StatefulWidget {
  final int emotionNumber;

  TextPage({Key? key, required this.emotionNumber}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TextPageState();
}
class _TextPageState extends State<TextPage> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // 텍스트 상자 포커스 관리

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

  void _navigateToAddPhotoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPhotoScreen(
          transcription: _textEditingController.text,
        ),
      ),
    );
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 텍스트 상자 외부 클릭 시 키보드 숨김
        },
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: const Color(0xfffdfbf0), // 전체 배경색을 0xfffdfbf0로 통일
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15), // 상단 여백
                Text(
                  '${widget.emotionNumber}가장 기억에 남는 상황이 있었나요?\n언제, 어떤 상황이었나요?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 20,
                    color: const Color(0xff2c2c2c),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(height: 20), // 텍스트와 이미지 사이의 간격 추가
                Image.asset(
                  'assets/text_img.png',
                  width: 120,
                  height: 120,
                ),
                SizedBox(height: 40), // 이미지와 입력 상자 사이의 간격 추가
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xffffffff),
                      border: Border.all(color: const Color(0xff000000), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _textEditingController,
                      focusNode: _focusNode, // 포커스 노드 추가
                      maxLines: 5,
                      decoration: InputDecoration.collapsed(
                        hintText: '이곳에 상황을 입력해주세요',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20), // 입력 상자와 버튼 사이의 간격 추가
                GestureDetector(
                  onTap: _navigateToAddPhotoScreen, // 생성하기 버튼 클릭 시 사진 추가 화면으로 이동
                  child: Container(
                    width: 221,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xff8d83ff),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '생성하기',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 20,
                          color: const Color(0xffffffff),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
