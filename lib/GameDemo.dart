
import 'dart:async';

import 'package:flame/game.dart';

import 'levels/level.dart';

class GameDemo extends FlameGame{
  
  @override 
  FutureOr<void> onLoad() async{
    add(Level());
    return super.onLoad();
  }
}