
import 'dart::async';

import 'package:flame/game.dart';

import 'levels/level.dart';

class DemoGame extends FlameGame{
  
  @override 
  FutureOr<void> onLoad() async{
    add(Level());
    return super.onLoad();
  }
}