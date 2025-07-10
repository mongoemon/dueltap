// BattleService: Handles combat logic (tap, charge, combo, stamina)
import '../models/character.dart';
import '../models/battle.dart';

class BattleService {
  void normalAttack(Battle battle) {
    if (battle.playerStamina > 0) {
      // Perform attack logic
      battle.playerStamina--;
      // TODO: Calculate and apply damage
    }
    // else: not enough stamina
  }

  void chargedAttack(Battle battle) {
    if (battle.playerStamina >= 3) {
      // Perform charged attack logic
      battle.playerStamina -= 3;
      // TODO: Calculate and apply charged damage
    }
    // else: not enough stamina
  }

  void useSkill(Battle battle, Skill skill) {
    // Example: apply skill effect if not on cooldown
    if (skill.name == 'Iron Smash') {
      // High-damage charge attack
      if (battle.playerStamina >= 3) {
        battle.playerStamina -= 3;
        battle.opponentHealth -= (battle.player.attack * 2);
      }
    } else if (skill.name == 'Arcane Burst') {
      // Area-effect skill
      if (battle.playerStamina >= 4) {
        battle.playerStamina -= 4;
        battle.opponentHealth -= (battle.player.attack * 2);
      }
    } else if (skill.name == 'Shadow Strike') {
      // Increase crit chance (not implemented)
    } else if (skill.name == 'Shield Wall') {
      // Reduce incoming damage (not implemented)
    } else if (skill.name == 'Divine Heal') {
      // Heal self
      if (battle.playerStamina >= 2) {
        battle.playerStamina -= 2;
        battle.playerHealth += 20;
      }
    }
    // TODO: Add cooldown logic
  }

  void updateCombo(Battle battle) {
    // TODO: Implement combo meter logic
  }

  void updateStamina(Battle battle, double dt) {
    // Regenerate stamina over time
    battle.playerStamina += (battle.staminaRegenRate * dt).toInt();
    if (battle.playerStamina > battle.maxStamina) {
      battle.playerStamina = battle.maxStamina;
    }
  }

  void equip(Character character, Equipment equipment) {
    character.equipment.add(equipment);
    equipment.statBoosts.forEach((stat, value) {
      if (stat == 'attack') character.attack += value;
      if (stat == 'defense') character.defense += value;
      if (stat == 'speed') character.speed += value;
      if (stat == 'stamina') character.stamina += value;
    });
  }
}
