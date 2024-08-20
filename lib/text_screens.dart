import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'AudioManager.dart';
import 'add_photo_screens.dart';
import 'package:http/http.dart' as http; // HTTP 요청을 위해 추가
import 'dart:convert';

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

  String? memberId;
  String? memberName;

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

    _fetchUserName(); // 사용자 이름 및 ID를 가져오는 메소드 호출
  }

  Future<void> _fetchUserName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final memberResponse = await Supabase.instance.client
          .from('member')
          .select('member_id, member_name')
          .eq('member_id', user.id)
          .single();

      setState(() {
        memberId = memberResponse['member_id'];
        memberName = memberResponse['member_name'];
      });
    }
  }

  Future<String> generateDiaryEntry(String prompt) async {
    // 모든 줄바꿈 및 특수 제어 문자를 공백으로 대체
    String sanitizedPrompt = prompt.replaceAll(RegExp(r'[\n\r\t]'), ' ');

    final response = await http.post(
      Uri.parse('http://192.168.0.43:8080/api/generate'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'prompt': sanitizedPrompt,
        'memberId': memberId,
        'memberName': memberName,
        'emotionCode': widget.emotionNumber.toString(), // 감정 코드 추가
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['diaryEntry'];
    } else {
      throw Exception('Failed to generate diary entry');
    }
  }

  void _navigateToAddPhotoScreen() async {
    if (memberId == null || memberName == null) {
      // 사용자 정보가 로드되지 않았을 경우 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요.')),
      );
      return;
    }

    final prompt = '이 내용으로 정성스러운 하루 일기를 작성해주세요: ${_textEditingController.text}';

    try {
      final diaryEntry = await generateDiaryEntry(prompt);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPhotoScreen(
            transcription: diaryEntry,
          ),
        ),
      );
    } catch (e) {
      print('Failed to generate diary entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일기 생성에 실패했습니다. 나중에 다시 시도해주세요.')),
      );
    }
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
                  '가장 기억에 남는 상황이 있었나요?\n언제, 어떤 상황이었나요?',
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
