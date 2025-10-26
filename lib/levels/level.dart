
import 'dart::async';

import 'package:flutter/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World{
  
  late TiledComponent level;
  
  @override
  FutureOr<void> onLoad() async{
    level = await TiledComponent.load('level01.tmx', Vector2.all(16));
    add(level);
    return super.onLoad();
  }
}