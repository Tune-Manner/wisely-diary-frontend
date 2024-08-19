import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
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
  String userId="";
  bool _isLoading = false;

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
    _fetchUserId();
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

  Future<void> _fetchUserId() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final memberResponse = await Supabase.instance.client
          .from('member')
          .select('member_id')
          .eq('member_id', user.id)
          .single();

      setState(() {
        userId = memberResponse['member_id'];
      });

    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _createDiary() async {
    setState(() {
      _isLoading = true;
    });

    audioManager.player.setVolume(0);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/cartoon/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'diaryCode': 30,
          'memberId': userId,
        }),
      );

      if (response.statusCode == 200) {
        final result = response.body;
        final urls = result.split(', ');

        if (urls.length >= 2) {
          final cartoonUrl = urls[0].replaceAll("Cartoon URL: ", "").trim();
          final letterCartoonUrl = urls[1].replaceAll("Letter Cartoon URL: ", "").trim();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DiarySummaryScreen(
                transcription: widget.transcription,
                imageFiles: _imageFiles,
                cartoonUrl: cartoonUrl,
                letterCartoonUrl: letterCartoonUrl,
              ),
            ),
          );
        } else {
          _showErrorDialog('Unexpected response format');
        }
      } else {
        _showErrorDialog('Failed to create diary: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

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
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
            color: const Color(0xfffdfbf0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Image.asset(
                    'assets/File plus.png',
                    width: 60,
                    height: 60,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createDiary,
                  child: Text('생성하기'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '당신의 하루에 공감 중입니다...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '잠시만 기다려주세요',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}