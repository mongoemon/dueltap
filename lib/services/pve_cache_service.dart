// PvECacheService: Handles offline PvE progress caching using SharedPreferences
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';

class PvECacheService {
  static const _keyLevel = 'player_level';
  static const _keyExp = 'player_exp';

  Future<void> saveProgress(Character character) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLevel, character.level);
    await prefs.setInt(_keyExp, character.exp);
  }

  Future<void> loadProgress(Character character) async {
    final prefs = await SharedPreferences.getInstance();
    character.level = prefs.getInt(_keyLevel) ?? character.level;
    character.exp = prefs.getInt(_keyExp) ?? character.exp;
  }
}
