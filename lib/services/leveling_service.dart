// LevelingService: Handles EXP curve, stat points, and leveling logic
import '../models/character.dart';

class LevelingService {
  static int expForLevel(int level) {
    // Exponential curve: Level 2 = 100, Level 10 = 5000, etc.
    return (100 * (level * level)).toInt();
  }

  void addExp(Character character, int exp) {
    character.exp += exp;
    while (character.exp >= expForLevel(character.level + 1)) {
      character.exp -= expForLevel(character.level + 1);
      character.level++;
      character.attack += 1; // Example: auto-allocate, can be customized
      character.defense += 1;
      character.speed += 1;
      character.stamina += 1;
      // TODO: Grant 5 stat points for manual allocation
    }
  }
}
