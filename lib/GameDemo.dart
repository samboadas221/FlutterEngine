
import 'dart::async';

import 'package:flame/game.dart';

import 'level.dart';

class DemoGame extends FlameGame{
  
  @override 
  FutureOr<void> onLoad async{
    add(Level());
    return super.onLoad();
  }
}