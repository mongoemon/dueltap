// BattleService: Handles combat logic (tap, charge, combo, stamina)
import '../models/character.dart';
import '../models/battle.dart';
import 'skills_csv_loader.dart';
import 'combo_csv_loader.dart';

class BattleService {
  List<SkillConfig>? _skillConfigs;
  List<ComboConfig>? _comboConfigs;

  Future<void> loadSkills() async {
    _skillConfigs = await SkillConfig.loadAll();
  }

  Future<void> loadCombos() async {
    _comboConfigs = await ComboConfig.loadAll();
  }

  ComboConfig? getComboConfig(String comboName) {
    if (_comboConfigs == null) return null;
    for (final c in _comboConfigs!) {
      if (c.comboName == comboName) {
        return c;
      }
    }
    return null;
  }

  SkillConfig? getSkillConfig(String character, String skillName) {
    if (_skillConfigs == null) return null;
    for (final s in _skillConfigs!) {
      if (s.character == character && s.skillName == skillName) {
        return s;
      }
    }
    return null;
  }

  void normalAttack(Battle battle) {
    if (battle.playerStamina > 0) {
      // Perform attack logic
      battle.playerStamina--;
      // TODO: Calculate and apply damage
    }
    // else: not enough stamina
  }

  void chargedAttack(Battle battle) {
    final combo = getComboConfig('charge_attack');
    if (combo != null && battle.playerStamina >= combo.threshold) {
      battle.playerStamina -= combo.threshold;
      // Apply charged attack logic using combo.multiplier, combo.bonusType, combo.bonusValue
      battle.opponentHealth -= (battle.player.attack * combo.multiplier)
          .toInt();
      // TODO: Apply bonus effect if needed
    } else if (battle.playerStamina >= 3) {
      // Fallback: original logic
      battle.playerStamina -= 3;
      // TODO: Calculate and apply charged damage
    }
    // else: not enough stamina
  }

  void useSkill(Battle battle, Skill skill, String characterName) {
    final config = getSkillConfig(characterName, skill.name);
    if (config == null) return;
    // Use config.cooldown, config.multiplier, config.effectType, config.effectValue, etc.
    if (config.effectType == 'stun') {
      if (battle.playerStamina >= config.cooldown) {
        battle.playerStamina -= config.cooldown;
        battle.opponentHealth -= (battle.player.attack * config.multiplier)
            .toInt();
        // TODO: Apply stun effect for config.effectValue turns
      }
    } else if (config.effectType == 'aoe') {
      if (battle.playerStamina >= config.cooldown) {
        battle.playerStamina -= config.cooldown;
        battle.opponentHealth -= (battle.player.attack * config.multiplier)
            .toInt();
        // TODO: Apply AOE logic
      }
    } else if (config.effectType == 'defense_buff') {
      if (battle.playerStamina >= config.cooldown) {
        battle.playerStamina -= config.cooldown;
        // TODO: Apply defense buff for config.effectValue
      }
    } else if (config.effectType == 'shield') {
      if (battle.playerStamina >= config.cooldown) {
        battle.playerStamina -= config.cooldown;
        // TODO: Apply shield for config.effectValue
      }
    }
    // TODO: Add cooldown logic, more effect types as needed
  }

  void updateCombo(Battle battle) {
    final combo = getComboConfig('basic_combo');
    if (combo != null && battle.combo >= combo.threshold) {
      // Apply combo bonus using combo.bonusType, combo.bonusValue
      if (combo.bonusType == 'extra_damage') {
        battle.opponentHealth -= combo.bonusValue.toInt();
      }
      // TODO: Handle other bonus types
    }
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
