import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เสียงแจ้งเตือน')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            playLocalAsset();
          },
          child: const Text('เล่นเสียงแจ้งเตือน'),
        ),
      ),
    );
  }

    void playLocalAsset() async {
    AudioPlayer player = AudioPlayer();
    await player.setAsset('assets/sound/noti.mp3');
    player.play();
  }
}
