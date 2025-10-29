
import 'dart:async';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'levels/level.dart';

class GameDemo extends FlameGame{
  
  @override
  // Color backgroundColor() => const Color(0xFF211F30);
  Color backgroundColor() => const Color(0xFF00FF00); // verde brillante
  
  late final CameraComponent camera;
  final world = Level();
  
  @override 
  FutureOr<void> onLoad() async{
    camera = CameraComponent.withFixedResolution(world: world, width: 360, height: 600);
    camera.viewfinder.anchor = Anchor.topLeft;
    addAll([ world, camera ]);
    return super.onLoad();
  }
}