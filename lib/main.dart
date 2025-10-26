
import 'package:flutter/material.dart';

import 'package:flame/game.dart';
import 'package:flame/flame.dart';

import 'GameDemo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();
  
  GameDemo game = GameDemo();
  runApp(GameWidget game : game);
}



/*

class MyGame extends StatefulWidget {
  const MyGame({super.key});

  @override
  State<MyGame> createState() => _MyGameState();
}

class _MyGameState extends State<MyGame> {
  @override
  void initState() {
    super.initState();
    setupAudio();
  }
  
  Future<void> setupAudio() async {
    await SoundManager.init();
    await SoundManager.preloadFastEffect("audio/click.mp3");
    await SoundManager.playMusic("audio/song.m4a", loop: true, volume: 0.9);
  }
  
  @override
  void dispose(){
    SoundManager.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    
    // ======= Crear botones =======
    Button song1 = Button();
    song1.setText("JUGAR");
    song1.setAudioOnClick("audio/click.mp3");

    Button song2 = Button();
    song2.setText("AJUSTES");
    song2.setAudioOnClick("audio/click.mp3");

    Button song3 = Button();
    song3.setText("OPCIONES");
    song3.setAudioOnClick("audio/click.mp3");

    Button song4 = Button();
    song4.setText("SALIR");
    song4.setAudioOnClick("audio/click.mp3");
    
    CustomList myList = CustomList();
    myList.setHeadingText("My Custom List");
    myList.setTopMargin(10.0);
    myList.setBottomMargin(10.0);
    myList.setRightMargin(10.0);
    myList.setLeftMargin(10.0);
    
    myList.addItem("Pool");
    myList.addItem("Rock");
    myList.addItem("Water");
    myList.addItem("Oil");
    myList.addItem("Milk");
    myList.addItem("Milf");
    myList.addItem("Car");

    Menu menu = Menu(name: "Principal");
    menu.add(song1);
    menu.add(song2);
    menu.add(song3);
    menu.add(song4);
    menu.add(myList.build());

    menu.matchButtonWidths();
    menu.setAsDefaultMenu();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: MenuManager.buildMenusLayer(),
      ),
    );
  }
}

*/


/*
// WORKING DUAL AUDIO

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: AudioPlayerDemo(),
      ),
    );
  }
}

class AudioPlayerDemo extends StatefulWidget {
  const AudioPlayerDemo({super.key});

  @override
  State<AudioPlayerDemo> createState() => _AudioPlayerDemoState();
}

class _AudioPlayerDemoState extends State<AudioPlayerDemo> {
  late AudioPlayer _player1;
  late AudioPlayer _player2;

  @override
  void initState() {
    super.initState();
    _player1 = AudioPlayer();
    _player2 = AudioPlayer();
    _configureAudioContext();
  }

  Future<void> _configureAudioContext() async {
    // Set context to allow mixing (no audio focus request on Android to prevent interruptions)
    final config = AudioContextConfig(
      focus: AudioContextConfigFocus.mixWithOthers,
      respectSilence: false,  // Play even if device is silent
    );
    final audioContext = config.build();

    await _player1.setAudioContext(audioContext);
    await _player2.setAudioContext(audioContext);
  }

  @override
  void dispose() {
    _player1.dispose();
    _player2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              _player1.play(AssetSource('audio/song.m4a'));  // Starts immediately
            },
            child: const Text('Play Sound 1'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _player2.play(AssetSource('audio/music.m4a'));  // Starts immediately, overlaps with Sound 1
            },
            child: const Text('Play Sound 2'),
          ),
        ],
      ),
    );
  }
}

*/