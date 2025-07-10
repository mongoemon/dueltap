// Unit test for combat balance (tap/charge, skills, stats)
import 'package:flutter_test/flutter_test.dart';
import '../lib/models/character.dart';
import '../lib/models/battle.dart';
import '../lib/services/battle_service.dart';

void main() {
  test('Tap and charge attack balance', () {
    final player = Character(name: 'Test', charClass: CharacterClass.warrior);
    final opponent = Character(name: 'Enemy', charClass: CharacterClass.mage);
    final battle = Battle(
      player: player,
      opponent: opponent,
      type: BattleType.pve,
    );
    final service = BattleService();

    final initialOpponentHealth = battle.opponentHealth;
    service.normalAttack(battle);
    expect(battle.opponentHealth, lessThan(initialOpponentHealth));
    service.chargedAttack(battle);
    expect(battle.opponentHealth, lessThan(initialOpponentHealth - 1));
  });

  test('Skill usage balance', () {
    final player = Character(name: 'Test', charClass: CharacterClass.warrior);
    final opponent = Character(name: 'Enemy', charClass: CharacterClass.mage);
    final battle = Battle(
      player: player,
      opponent: opponent,
      type: BattleType.pve,
    );
    final service = BattleService();
    final skill = Skill('Iron Smash', 'High-damage charge attack', 10);
    final initialOpponentHealth = battle.opponentHealth;
    service.useSkill(battle, skill);
    expect(battle.opponentHealth, lessThan(initialOpponentHealth));
  });
}
