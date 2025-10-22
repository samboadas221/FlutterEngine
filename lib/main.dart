
import 'package:flutter/material.dart';
import 'CustomButton.dart';
import 'CustomMenu.dart';
import 'SoundManager.dart';

void main() {
  runApp(const MyGame());
}

class MyGame extends StatefulWidget {
  const MyGame({super.key});

  @override
  State<MyGame> createState() => _MyGameState();
}

class _MyGameState extends State<MyGame> {
  @override
  void initState() {
    super.initState();
    // Iniciamos la música una sola vez al montar el widget
    // SoundManager().playBackgroundMusic("audio/song1.m4a");
  }

  @override
  Widget build(BuildContext context) {
    
    SoundManager audioPlayer = SoundManager();
    
    audioPlayer.playMusic("audio/song1.m4a");
    
    // ======= Crear botones =======
    Button song1 = Button();
    song1.setText("JUGAR");
    song1.setAudioOnClick("audio/click.mp3");

    Button song2 = Button();
    song2.setText("AjusTEs");
    song2.setAudioOnClick("audio/click.mp3");

    Button song3 = Button();
    song3.setText("opciones");
    song3.setAudioOnClick("audio/click.mp3");

    Button song4 = Button();
    song4.setText("sAliR");
    song4.setAudioOnClick("audio/click.mp3");

    Menu menu = Menu(name: "Principal");
    menu.add(song1);
    menu.add(song2);
    menu.add(song3);
    menu.add(song4);

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