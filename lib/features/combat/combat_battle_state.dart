import 'dart:math';
import '../../models/character.dart';
import '../../services/battle_config_loader.dart';
import '../../services/status_effects_csv_loader.dart';

class CombatBattleState {
  final BattleConfig config;
  final List<StatusEffectConfig> statusEffects;
  int playerHp;
  int opponentHp;
  final Character player;
  final Character opponent;
  int playerGauge = 0;
  int opponentGauge = 0;
  int get maxGauge => config.getInt('max_gauge', 100);
  int get healAmount => config.getInt('heal_amount', 15);
  int get playerRecoveryPoints => config.getInt('player_recovery_points', 2);
  int get opponentRecoveryPoints =>
      config.getInt('opponent_recovery_points', 2);
  int opponentAttackGauge = 0; // 0-100, fills every 3 seconds for auto attack
  int get maxAttackGauge => config.getInt('max_attack_gauge', 100);

  // Player shield state
  bool playerShieldActive = false;
  int playerShieldGauge = 0; // 0-100, depletes over 10 seconds
  int get maxShieldGauge => config.getInt('max_shield_gauge', 100);

  // Player auto-attack gauge
  int playerAttackGauge = 0; // 0-100, fills based on player speed
  int get maxPlayerAttackGauge => config.getInt('max_player_attack_gauge', 100);
  int _playerAutoAttackIncrements =
      0; // Track how many times gauge has been incremented since last reset

  // Buff/debuff system
  int playerSpeedBuff = 0; // +speed
  int playerSpeedBuffFrames = 0;
  double playerDamageReductionBuff = 0.0; // percent (0.3 = 30% less damage)
  int playerDamageReductionBuffFrames = 0;

  // Exhaust system
  int playerExhaustGauge;
  int opponentExhaustGauge;
  // Remove: final int maxExhaustGauge;

  late final Random _rng;
  int _playerRecoveryPoints;
  int _opponentRecoveryPoints;

  CombatBattleState({
    required this.player,
    required this.opponent,
    required this.config,
    required this.statusEffects,
  }) : playerHp = player.hp,
       opponentHp = opponent.hp,
       playerExhaustGauge = player.exhaust,
       opponentExhaustGauge = opponent.exhaust,
       _playerRecoveryPoints = config.getInt('player_recovery_points', 2),
       _opponentRecoveryPoints = config.getInt('opponent_recovery_points', 2) {
    final seed = config.getInt('rng_seed', 42);
    _rng = Random(seed);
  }

  int get playerExhaustCost =>
      (player.exhaust * player.exhaustCostPercent / 100).ceil();
  int get opponentExhaustCost =>
      (opponent.exhaust * opponent.exhaustCostPercent / 100).ceil();

  bool get isPlayerExhausted => playerExhaustGauge < playerExhaustCost;
  bool get isOpponentExhausted => opponentExhaustGauge < opponentExhaustCost;

  void depletePlayerExhaust() {
    playerExhaustGauge -= playerExhaustCost;
    if (playerExhaustGauge < 0) playerExhaustGauge = 0;
  }

  void recoverPlayerExhaust() {
    if (playerExhaustGauge < playerExhaustCost) {
      playerExhaustGauge += player.exhaustRecoverySlow;
    } else {
      playerExhaustGauge += player.exhaustRecoveryNormal;
    }
    if (playerExhaustGauge > player.exhaust)
      playerExhaustGauge = player.exhaust;
  }

  void depleteOpponentExhaust() {
    opponentExhaustGauge -= opponentExhaustCost;
    if (opponentExhaustGauge < 0) opponentExhaustGauge = 0;
  }

  void recoverOpponentExhaust() {
    if (opponentExhaustGauge < opponentExhaustCost) {
      opponentExhaustGauge += opponent.exhaustRecoverySlow;
    } else {
      opponentExhaustGauge += opponent.exhaustRecoveryNormal;
    }
    if (opponentExhaustGauge > opponent.exhaust)
      opponentExhaustGauge = opponent.exhaust;
  }

  double get critChance => config.getDouble('crit_chance', 0.1);
  double get critMultiplier => config.getDouble('crit_multiplier', 2.0);
  double get missChance => config.getDouble('miss_chance', 0.05);

  bool _isCrit() => _rng.nextDouble() < critChance;
  bool _isMiss() => _rng.nextDouble() < missChance;

  void attackOpponent() {
    if (_isMiss()) return; // Missed attack
    int dmg = player.tapAttack;
    if (_isCrit()) dmg = (dmg * critMultiplier).round();
    // Reduce by opponent's strength percent
    dmg = (dmg * (1 - opponent.strength / 100)).round();
    opponentHp -= dmg;
    if (opponentHp < 0) opponentHp = 0;
    playerGauge += 20;
    if (playerGauge > maxGauge) playerGauge = maxGauge;
    opponentGauge += 10;
    if (opponentGauge > maxGauge) opponentGauge = maxGauge;
  }

  void playerAutoAttack() {
    if (_isMiss()) return;
    int dmg = player.autoAttack;
    if (_isCrit()) dmg = (dmg * critMultiplier).round();
    dmg = (dmg * (1 - opponent.strength / 100)).round();
    opponentHp -= dmg;
    if (opponentHp < 0) opponentHp = 0;
    playerGauge += 20;
    if (playerGauge > maxGauge) playerGauge = maxGauge;
    opponentGauge += 10;
    if (opponentGauge > maxGauge) opponentGauge = maxGauge;
  }

  void attackPlayer() {
    if (_isMiss()) return;
    int dmg = opponent.tapAttack;
    if (_isCrit()) dmg = (dmg * critMultiplier).round();
    if (playerShieldActive) {
      dmg = (dmg * 0.5).round();
    }
    // Reduce by player's strength percent
    dmg = (dmg * (1 - player.strength / 100)).round();
    playerHp -= dmg;
    if (playerHp < 0) playerHp = 0;
    opponentGauge += 20;
    if (opponentGauge > maxGauge) opponentGauge = maxGauge;
    playerGauge += 10;
    if (playerGauge > maxGauge) playerGauge = maxGauge;
  }

  void opponentAutoAttack() {
    if (_isMiss()) return;
    int dmg = opponent.autoAttack;
    if (_isCrit()) dmg = (dmg * critMultiplier).round();
    if (playerShieldActive) {
      dmg = (dmg * 0.5).round();
    }
    dmg = (dmg * (1 - player.strength / 100)).round();
    playerHp -= dmg;
    if (playerHp < 0) playerHp = 0;
    opponentGauge += 20;
    if (opponentGauge > maxGauge) opponentGauge = maxGauge;
    playerGauge += 10;
    if (playerGauge > maxGauge) playerGauge = maxGauge;
  }

  void healPlayer() {
    if (_playerRecoveryPoints > 0 && playerHp < 100) {
      playerHp += healAmount;
      if (playerHp > 100) playerHp = 100;
      _playerRecoveryPoints--;
    }
  }

  void healOpponent() {
    if (_opponentRecoveryPoints > 0 && opponentHp < 100) {
      opponentHp += healAmount;
      if (opponentHp > 100) opponentHp = 100;
      _opponentRecoveryPoints--;
    }
  }

  void specialAttackOpponent() {
    int dmg = (player.attack * 2.2).round();
    opponentHp -= dmg;
    if (opponentHp < 0) opponentHp = 0;
    playerGauge = 0;
  }

  void specialAttackPlayer() {
    int dmg = (opponent.attack * 2.2).round();
    playerHp -= dmg;
    if (playerHp < 0) playerHp = 0;
    opponentGauge = 0;
  }

  // Call this every second to increment the player's attack gauge
  bool incrementPlayerAttackGauge() {
    // Fill rate decays: each increment is slower than the last
    // Example: base = stamina * 7, decay = 1 per increment
    int base = (player.stamina * 7).clamp(1, 100);
    int decay = _playerAutoAttackIncrements;
    int increment = (base - decay).clamp(1, 100);
    playerAttackGauge += increment;
    _playerAutoAttackIncrements++;
    if (playerAttackGauge >= maxPlayerAttackGauge) {
      playerAttackGauge = 0;
      _playerAutoAttackIncrements = 0;
      return true; // Ready to auto-attack
    }
    return false;
  }

  // Call this every second to increment the opponent's attack gauge
  bool incrementOpponentAttackGauge() {
    opponentAttackGauge += (opponent.stamina * 7).clamp(1, 100);
    if (opponentAttackGauge >= maxAttackGauge) {
      opponentAttackGauge = 0;
      return true; // Ready to auto-attack
    }
    return false;
  }

  void activatePlayerShield() {
    if (!playerShieldActive) {
      playerShieldActive = true;
      playerShieldGauge = maxShieldGauge;
    }
  }

  void depletePlayerShieldGauge() {
    if (playerShieldActive) {
      playerShieldGauge -= config.getInt(
        'shield_deplete_per_tick',
        10,
      ); // 10 seconds to deplete (100/10)
      if (playerShieldGauge <= 0) {
        playerShieldGauge = 0;
        playerShieldActive = false;
      }
    }
  }

  void tickBuffs() {
    if (playerSpeedBuffFrames > 0) {
      playerSpeedBuffFrames--;
      if (playerSpeedBuffFrames == 0) playerSpeedBuff = 0;
    }
    if (playerDamageReductionBuffFrames > 0) {
      playerDamageReductionBuffFrames--;
      if (playerDamageReductionBuffFrames == 0) playerDamageReductionBuff = 0.0;
    }
  }

  void applySpeedBuff() {
    final effect = statusEffects.firstWhere(
      (e) => e.effectName == 'speed_buff',
      orElse: () => StatusEffectConfig(
        effectName: 'speed_buff',
        duration: 2,
        strength: 10,
        stackable: false,
        description: 'Default speed buff',
      ),
    );
    playerSpeedBuff = effect.strength.toInt();
    playerSpeedBuffFrames = effect.duration;
  }

  void applyDamageReductionBuff() {
    final effect = statusEffects.firstWhere(
      (e) => e.effectName == 'defense_buff',
      orElse: () => StatusEffectConfig(
        effectName: 'defense_buff',
        duration: 2,
        strength: 0.2,
        stackable: false,
        description: 'Default defense buff',
      ),
    );
    playerDamageReductionBuff = effect.strength;
    playerDamageReductionBuffFrames = effect.duration;
  }

  int get effectivePlayerSpeed => player.speed + playerSpeedBuff;

  double get evadeChancePerSpeed =>
      config.getDouble('evade_chance_per_speed', 0.02);
  double get maxEvadeChance => config.getDouble('max_evade_chance', 0.5);
  bool tryEvade(int speed) {
    // Example: 2% evade chance per speed point, max 50%
    double evadeChance = (speed * evadeChancePerSpeed).clamp(0, maxEvadeChance);
    return _rng.nextDouble() < evadeChance;
  }

  // Returns true if hit, false if evaded
  bool attackOpponentWithEvade() {
    if (tryEvade(opponent.speed)) return false;
    int dmg = player.tapAttack;
    dmg = (dmg * (1 - opponent.strength / 100)).round();
    opponentHp -= dmg;
    if (opponentHp < 0) opponentHp = 0;
    playerGauge += 20;
    if (playerGauge > maxGauge) playerGauge = maxGauge;
    opponentGauge += 10;
    if (opponentGauge > maxGauge) opponentGauge = maxGauge;
    return true;
  }

  bool playerAutoAttackWithEvade() {
    if (tryEvade(opponent.speed)) return false;
    int dmg = player.autoAttack;
    dmg = (dmg * (1 - opponent.strength / 100)).round();
    opponentHp -= dmg;
    if (opponentHp < 0) opponentHp = 0;
    playerGauge += 20;
    if (playerGauge > maxGauge) playerGauge = maxGauge;
    opponentGauge += 10;
    if (opponentGauge > maxGauge) opponentGauge = maxGauge;
    return true;
  }

  bool attackPlayerWithEvade() {
    if (tryEvade(effectivePlayerSpeed)) return false;
    int dmg = opponent.tapAttack;
    if (playerShieldActive) {
      dmg = (dmg * 0.5).round();
    }
    if (playerDamageReductionBuff > 0) {
      dmg = (dmg * (1 - playerDamageReductionBuff)).round();
    }
    dmg = (dmg * (1 - player.strength / 100)).round();
    playerHp -= dmg;
    if (playerHp < 0) playerHp = 0;
    opponentGauge += 20;
    if (opponentGauge > maxGauge) opponentGauge = maxGauge;
    playerGauge += 10;
    if (playerGauge > maxGauge) playerGauge = maxGauge;
    return true;
  }

  bool opponentAutoAttackWithEvade() {
    if (tryEvade(effectivePlayerSpeed)) return false;
    int dmg = opponent.autoAttack;
    if (playerShieldActive) {
      dmg = (dmg * 0.5).round();
    }
    if (playerDamageReductionBuff > 0) {
      dmg = (dmg * (1 - playerDamageReductionBuff)).round();
    }
    dmg = (dmg * (1 - player.strength / 100)).round();
    playerHp -= dmg;
    if (playerHp < 0) playerHp = 0;
    opponentGauge += 20;
    if (opponentGauge > maxGauge) opponentGauge = maxGauge;
    playerGauge += 10;
    if (playerGauge > maxGauge) playerGauge = maxGauge;
    return true;
  }

  int get opponentShieldGauge =>
      0; // TODO: Implement opponent shield logic if needed
}
