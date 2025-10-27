
import 'package:flutter/material.dart';

import 'package:flame/game.dart';
import 'package:flame/flame.dart';

import 'GameDemo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();
  
  GameDemo game = GameDemo();
  runApp(GameWidget(game: game));
}