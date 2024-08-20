import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'add_photo_screens.dart';
import 'AudioManager.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class RecordScreen extends StatefulWidget {
  final int emotionNumber;

  RecordScreen({Key? key, required this.emotionNumber}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final audioManager = AudioManager();
  final AudioRecorder audioRecorder = AudioRecorder();
  String? recordingPath;
  bool isRecording = false;

  String? memberId;
  String? memberName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
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

  Future<void> startRecording() async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final String filePath = p.join(appDocumentsDir.path, "recording.wav");

    await audioRecorder.start(RecordConfig(), path: filePath);
    setState(() {
      isRecording = true;
      recordingPath = filePath;
    });
    print('Recording started, file will be saved to: $filePath');
  }

  Future<String?> stopRecording() async {
    String? filePath = await audioRecorder.stop();
    setState(() {
      isRecording = false;
      recordingPath = filePath;
    });
    print('Recording stopped, file saved to: $recordingPath');
    return filePath;
  }

  Future<String> sendFileToBackend(String filePath) async {
    if (memberId == null || memberName == null) {
      throw Exception('Member ID or Name is missing.');
    }
    print('보내진 memberId: $memberId, memberName: $memberName');

    final Uri uri = Uri.parse('http://192.168.0.43:8080/api/transcription');
    final mimeType = lookupMimeType(filePath);

    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      ));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      print('Raw response body: ${responseData.body}');

      var jsonData = jsonDecode(responseData.body);
      print('백엔드 응답: $jsonData');

      String? prompt = jsonData['transcription'] ?? jsonData['text'];  // 백엔드로부터 받은 텍스트를 이용하여 일기 생성
      if (prompt == null) {
        throw Exception('Transcription or text is missing in the response.');
      }
      return await generateDiaryEntry(prompt);
    } else {
      throw Exception('Failed to send file to backend');
    }
  }

  Future<String> generateDiaryEntry(String prompt) async {
    String sanitizedPrompt = prompt.replaceAll(RegExp(r'[\n\r\t]'), ' ');

    String finalPrompt = "위 내용을 포함한 편지 형식이 아닌 일기를 작성해주세요: $sanitizedPrompt";

    final response = await http.post(
      Uri.parse('http://192.168.0.43:8080/api/generate'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'prompt': finalPrompt,
        'memberId': memberId,
        'memberName': memberName,
        'emotionCode': widget.emotionNumber.toString(),
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['diaryEntry'];
    } else {
      throw Exception('Failed to generate diary entry');
    }
  }

  void navigateToAddPhotoScreen(String transcription) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPhotoScreen(transcription: transcription),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recording Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            if (isRecording) {
              String? filePath = await stopRecording();
              if (filePath != null) {
                String transcription = await sendFileToBackend(filePath);
                navigateToAddPhotoScreen(transcription);
              }
            } else {
              await startRecording();
            }
          },
          child: Text(isRecording ? 'Stop Recording' : 'Start Recording'),
        ),
      ),
    );
  }
}
