
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const FootballMenuDemo());
}

class FootballMenuDemo extends StatefulWidget {
  const FootballMenuDemo({super.key});

  @override
  State<FootballMenuDemo> createState() => _FootballMenuDemoState();
}

class _FootballMenuDemoState extends State<FootballMenuDemo> {
  late final AudioPlayer _bgMusicPlayer;
  final AudioPlayer _sfxPlayer = AudioPlayer();
  Color _button1Color = Colors.blue;
  Color _button2Color = Colors.green;
  Color _button3Color = Colors.red;

  @override
  void initState() {
    super.initState();
    _bgMusicPlayer = AudioPlayer();
    _playBackgroundMusic();
  }

  Future<void> _playBackgroundMusic() async {
    await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgMusicPlayer.play(AssetSource('audio/music.opus'));
  }

  Future<void> _playButtonSound(String fileName) async {
    await _sfxPlayer.play(AssetSource('audio/$fileName'));
  }

  @override
  void dispose() {
    _bgMusicPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  Widget _buildButton(String label, Color color, String soundFile, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      ),
      onPressed: () async {
        await _playButtonSound(soundFile);
        onPressed();
      },
      child: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Menu Demo',
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton("Botón 1", _button1Color, "click1.opus", () {
                setState(() {
                  _button1Color = _button1Color == Colors.blue ? Colors.orange : Colors.blue;
                });
              }),
              const SizedBox(height: 20),
              _buildButton("Botón 2", _button2Color, "click2.opus", () {
                setState(() {
                  _button2Color = _button2Color == Colors.green ? Colors.purple : Colors.green;
                });
              }),
              const SizedBox(height: 20),
              _buildButton("Botón 3", _button3Color, "click3.opus", () {
                setState(() {
                  _button3Color = _button3Color == Colors.red ? Colors.yellow : Colors.red;
                });
              }),
            ],
          ),
        ),
      ),
    );
  }
}