import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';

class MusicPlayerPage extends StatefulWidget {
  final int musicCode;

  MusicPlayerPage({required this.musicCode});

  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  Future<Map<String, dynamic>>? _musicDataFuture;
  VideoPlayerController? _controller;
  bool _isVideoGenerating = false;

  @override
  void initState() {
    super.initState();
    _musicDataFuture = _fetchMusicData();
  }

  Future<Map<String, dynamic>> _fetchMusicData() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/music/${widget.musicCode}/play'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded data: $data');

        final videoUrl = data['clipResponse']?['clips']?[0]?['video_url'];
        if (videoUrl != null && videoUrl.isNotEmpty) {
          _initializeVideoPlayer(videoUrl);
          _isVideoGenerating = false;
        } else {
          print('Video URL is null or empty');
          _isVideoGenerating = true;
          // 5초 후에 데이터를 다시 불러옵니다.
          Future.delayed(Duration(seconds: 5), () {
            if (mounted) {
              setState(() {
                _musicDataFuture = _fetchMusicData();
              });
            }
          });
        }

        return data;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching music data: $e');
      rethrow;
    }
  }

  void _initializeVideoPlayer(String videoUrl) {
    print('Initializing video player with URL: $videoUrl');
    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      }).catchError((error) {
        print('Error initializing video player: $error');
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _musicDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _musicDataFuture = _fetchMusicData();
                      });
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final musicData = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Title: ${musicData['musicTitle'] ?? 'No Title'}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Created At: ${musicData['createdAt'] ?? 'Unknown'}'),
                    SizedBox(height: 16),
                    if (_controller != null && _controller!.value.isInitialized)
                      AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                    else if (_isVideoGenerating)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              '음악을 생성 중입니다.\n잠시만 기다려 주세요.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      Center(
                        child: Text(
                          '음악을 로드할 수 없습니다.\n잠시 후 다시 시도해 주세요.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(height: 16),
                    if (_controller != null && _controller!.value.isInitialized)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _controller!.value.isPlaying
                                ? _controller!.pause()
                                : _controller!.play();
                          });
                        },
                        child: Icon(
                          _controller!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                      ),
                    SizedBox(height: 16),
                    Text('Lyrics:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(musicData['musicLyrics'] ?? 'No lyrics available'),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
