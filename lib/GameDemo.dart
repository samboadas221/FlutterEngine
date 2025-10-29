
import 'dart:async';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'DebugOverlay.dart';
import 'levels/level.dart';


class GameDemo extends FlameGame{
  
  @override
  Color backgroundColor() => const Color(0xFF00FF00); // verde brillante
  
  late final CameraComponent camera;
  late DebugOverlay debug;
  final world = Level();
  
  @override 
  FutureOr<void> onLoad() async{
    debug = DebugOverlay(position: Vector2(8, 8), maxLines: 10, lineHeight: 18.0);
    add(debug);
    debug.show('Debug Console added');
    
    camera = CameraComponent.withFixedResolution(world: world, width: 360, height: 600);
    camera.viewfinder.anchor = Anchor.topLeft;
    addAll([ world, camera ]);
    debug.show('Camera and World added to the game');
    return super.onLoad();
  }
}