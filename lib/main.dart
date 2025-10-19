
import 'package:flutter/material.dart';
import 'CustomButton.dart';
import 'CustomMenu.dart';

void main() {
  runApp(const MyGame());
}

class MyGame extends StatelessWidget {
  const MyGame({super.key});

  @override
  Widget build(BuildContext context) {
    // ==== Crear botones ====
    Button buttonPlay = Button();
    buttonPlay.setText("Jugar");
    buttonPlay.setAudioOnClick("audio/click2.opus");

    Button buttonSettings = Button();
    buttonSettings.setText("Configuración");
    buttonSettings.setAudioOnClick("audio/click2.opus");

    Button buttonExit = Button();
    buttonExit.setText("Salir");
    buttonExit.setAudioOnClick("audio/click2.opus");

    Button backButton = Button();
    backButton.setText("Volver");
    backButton.setAudioOnClick("audio/click2.opus");

    // ==== Crear menús ====
    Menu menuPrincipal = Menu(name: "Principal");
    Menu menuOpciones = Menu(name: "Opciones");

    menuPrincipal.add(buttonPlay);
    menuPrincipal.add(buttonSettings);
    menuPrincipal.add(buttonExit);

    menuOpciones.add(backButton);

    menuPrincipal.setAsDefaultMenu();

    // ==== Configurar acciones de botones ====
    buttonPlay.setOnPressed(() {
      // Nothing yet
    });

    buttonSettings.setOnPressed(() {
      menuPrincipal.hide();
      menuOpciones.show();
    });

    backButton.setOnPressed(() {
      menuOpciones.hide();
      menuPrincipal.show();
    });

    // ==== Mostrar en pantalla ====
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: MenuManager.buildMenusLayer(),
      ),
    );
  }
}