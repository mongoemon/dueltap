// SfxController: Handles playing sound effects (placeholder)
import 'package:audioplayers/audioplayers.dart';

class SfxController {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playTap() async {
    await _player.play(AssetSource('audio/tap.wav'));
  }

  Future<void> playCharge() async {
    await _player.play(AssetSource('audio/charge.wav'));
  }

  Future<void> playSkill() async {
    await _player.play(AssetSource('audio/skill.wav'));
  }

  Future<void> playVictory() async {
    await _player.play(AssetSource('audio/victory.wav'));
  }

  Future<void> playLoss() async {
    await _player.play(AssetSource('audio/loss.wav'));
  }
}
