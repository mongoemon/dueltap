// Unit test for AI difficulty scaling in PvE mode
import 'package:flutter_test/flutter_test.dart';
import '../lib/models/character.dart';
import '../lib/models/battle.dart';

void main() {
  test('AI opponent stats scale with player level', () {
    final player = Character(
      name: 'Player',
      charClass: CharacterClass.warrior,
      level: 10,
    );
    final aiOpponent = Character(
      name: 'Bandit',
      charClass: CharacterClass.ninja,
      level: 10,
    );
    expect(aiOpponent.level, equals(player.level));
    // Example: AI stats should be similar or slightly lower than player
    expect(aiOpponent.attack, lessThanOrEqualTo(player.attack + 5));
    expect(aiOpponent.defense, lessThanOrEqualTo(player.defense + 5));
  });

  test('Boss stats are higher at milestone levels', () {
    final player = Character(
      name: 'Player',
      charClass: CharacterClass.warrior,
      level: 20,
    );
    final boss = Character(
      name: 'Dark Knight',
      charClass: CharacterClass.knight,
      level: 20,
      attack: 30,
      defense: 30,
    );
    expect(boss.attack, greaterThan(player.attack));
    expect(boss.defense, greaterThan(player.defense));
  });
}
