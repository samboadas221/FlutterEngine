
import 'package:audioplayers/audioplayers.dart';

class SoundManager{
  
  final music = AudioPlayer();
  final effect = AudioPlayer();
  
  SoundManager();
  
  Future <void> playMusic(String path) async {
    try {
      await music.play(AssetSource(path));
    } catch (e){
      // We do shit
    }
  }
  
  Future <void> playEffect(String path) async {
    try {
      await effect.play(AssetSource(path));
    } catch (e){
      // We do shit
    }
  }
  
}