import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class BgmPlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BGM Player'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: EmotionMusicPlayer(),
    );
  }
}

class EmotionMusicPlayer extends StatefulWidget {
  @override
  _EmotionMusicPlayerState createState() => _EmotionMusicPlayerState();
}

class _EmotionMusicPlayerState extends State<EmotionMusicPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String currentEmotion = '';

  final Map<String, String> emotionTracks = {
    '분노': 'assets/audio/anger_bgm.mp3',
    '당황': 'assets/audio/embarassed_bgm.mp3',
    '감사': 'assets/audio/greatful_bgm.mp3',
    '억울': 'assets/audio/injustice_bgm.mp3',
    '신남': 'assets/audio/joy_bgm.mp3',
    '설렘': 'assets/audio/lovely_bgm.mp3',
    '뿌듯': 'assets/audio/proud_bgm.mp3',
    '편안': 'assets/audio/relax_bgm.mp3',
    '슬픔': 'assets/audio/sad_bgm.mp3',
    '걱정': 'assets/audio/worried_bgm.mp3',
  };

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void playEmotionMusic(String emotion) async {
    if (emotionTracks.containsKey(emotion)) {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset(emotionTracks[emotion]!);
      await _audioPlayer.play();
      setState(() {
        currentEmotion = emotion;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '현재 감정: $currentEmotion',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: emotionTracks.keys.map((emotion) =>
                ElevatedButton(
                  child: Text(emotion),
                  onPressed: () => playEmotionMusic(emotion),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentEmotion == emotion ? Colors.green : null,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                )
            ).toList(),
          ),
        ],
      ),
    );
  }
}