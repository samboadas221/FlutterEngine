
import 'package:flutter/material.dart';
import 'CustomButton.dart';
import 'CustomMenu.dart';
import 'SoundManager.dart';

void main() {
  runApp(const MyGame());
}

class MyGame extends StatelessWidget {
  const MyGame({super.key});

  @override
  Widget build(BuildContext context) {
    SoundManager.instance.playBackground('audio/music.opus');

    Button buttonPlay = Button();
    buttonPlay.setText("Jugar");
    buttonPlay.setAudioOnClick("audio/click.mp3");

    Button buttonSettings = Button();
    buttonSettings.setText("Opciones");
    buttonSettings.setAudioOnClick("audio/click.mp3");

    Button buttonExit = Button();
    buttonExit.setText("Salir");
    buttonExit.setAudioOnClick("audio/click.mp3");
    
    Menu menuPrincipal = Menu(name: "Principal");
    menuPrincipal.add(buttonPlay);
    menuPrincipal.add(buttonSettings);
    menuPrincipal.add(buttonExit);

    menuPrincipal.matchButtonWidths();

    menuPrincipal.setAsDefaultMenu();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: MenuManager.buildMenusLayer(),
      ),
    );
  }
}