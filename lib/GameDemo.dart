
import 'dart:async';
import 'package:flame/game.dart';
import 'levels/level.dart';

class GameDemo extends FlameGame{
  
  late final CameraComponent camera;
  final world = Level();
  
  @override 
  FutureOr<void> onLoad() async{
    camera = CameraComponent.withFixedResolution(world: world, width: 360, height: 600);
    camera.viewFinder.anchor = Anchor.topLeft;
    addAll([ camera, world ]);
    return super.onLoad();
  }
}