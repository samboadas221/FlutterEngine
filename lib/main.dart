
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
      
      Button song1 = Button();
      song1.setText("My Type");
      song1.setAudioOnClick("audio/song1.m4a");
      
      Button song2 = Button();
      song2.setText("Somewhere");
      song2.setAudioOnClick("audio/song2.m4a");
      
      Button song3 = Button();
      song3.setText("Amarte");
      song3.setAudioOnClick("audio/song3.m4a");
      
      Button song4 = Button();
      song4.setText("Matters");
      song4.setAudioOnClick("audio/song4.m4a");
      
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