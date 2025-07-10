import 'dart:math';
import '../../models/character.dart';

class CombatBattleState {
  int playerHp;
  int opponentHp;
  final Character player;
  final Character opponent;
  int playerGauge = 0;
  int opponentGauge = 0;
  final int maxGauge = 100;
  final int healAmount = 15;
  int playerRecoveryPoints = 2;
  int opponentRecoveryPoints = 2;
  int opponentAttackGauge = 0; // 0-100, fills every 3 seconds for auto attack
  final int maxAttackGauge = 100;

  // Player shield state
  bool playerShieldActive = false;
  int playerShieldGauge = 0; // 0-100, depletes over 10 seconds
  final int maxShieldGauge = 100;

  // Player auto-attack gauge
  int playerAttackGauge = 0; // 0-100, fills based on player speed
  final int maxPlayerAttackGauge = 100;

  // Buff/debuff system
  int playerSpeedBuff = 0; // +speed
  int playerSpeedBuffFrames = 0;
  double playerDamageReductionBuff = 0.0; // percent (0.3 = 30% less damage)
  int playerDamageReductionBuffFrames = 0;

  // Exhaust system
  int playerExhaustGauge;
  int opponentExhaustGauge;
  final int maxExhaustGauge;

  final Random _rand = Random();

  CombatBattleState({required this.player, required this.opponent})
    : playerHp = player.hp,
      opponentHp = opponent.hp,
      playerExhaustGauge = player.exhaust,
      opponentExhaustGauge = opponent.exhaust,
      maxExhaustGauge = player.exhaust;

  int get exhaustCost => (maxExhaustGauge * 0.25).ceil();

  bool get isPlayerExhausted => playerExhaustGauge < exhaustCost;
  bool get isOpponentExhausted => opponentExhaustGauge < exhaustCost;

  void depletePlayerExhaust() {
    playerExhaustGauge -= exhaustCost;
    if (playerExhaustGauge < 0) playerExhaustGauge = 0;
  }

  void recoverPlayerExhaust() {
    if (playerExhaustGauge < exhaustCost) {
      playerExhaustGauge += 1; // Slow recovery until enough for one attack
    } else {
      playerExhaustGauge += player.exhaustRecovery;
    }
    if (playerExhaustGauge > maxExhaustGauge) playerExhaustGauge = maxExhaustGauge;
  }

  void depleteOpponentExhaust() {
    opponentExhaustGauge -= exhaustCost;
    if (opponentExhaustGauge < 0) opponentExhaustGauge = 0;
  }

  void recoverOpponentExhaust() {
    if (opponentExhaustGauge < exhaustCost) {
      opponentExhaustGauge += 1;
    } else {
      opponentExhaustGauge += opponent.exhaustRecovery;
    }
    if (opponentExhaustGauge > maxExhaustGauge) opponentExhaustGauge = maxExhaustGauge;
  }

  void attackOpponent() {
    int dmg = player.tapAttack;
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
    int dmg = player.autoAttack;
    dmg = (dmg * (1 - opponent.strength / 100)).round();
    opponentHp -= dmg;
    if (opponentHp < 0) opponentHp = 0;
    playerGauge += 20;
    if (playerGauge > maxGauge) playerGauge = maxGauge;
    opponentGauge += 10;
    if (opponentGauge > maxGauge) opponentGauge = maxGauge;
  }

  void attackPlayer() {
    int dmg = opponent.tapAttack;
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
    int dmg = opponent.autoAttack;
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
    if (playerRecoveryPoints > 0 && playerHp < 100) {
      playerHp += healAmount;
      if (playerHp > 100) playerHp = 100;
      playerRecoveryPoints--;
    }
  }

  void healOpponent() {
    if (opponentRecoveryPoints > 0 && opponentHp < 100) {
      opponentHp += healAmount;
      if (opponentHp > 100) opponentHp = 100;
      opponentRecoveryPoints--;
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
    // Fill rate = stamina * 7 (higher stamina = faster auto-attack)
    playerAttackGauge += (player.stamina * 7).clamp(1, 100);
    if (playerAttackGauge >= maxPlayerAttackGauge) {
      playerAttackGauge = 0;
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
      playerShieldGauge -= 10; // 10 seconds to deplete (100/10)
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

  void applySpeedBuff(int amount, int frames) {
    playerSpeedBuff = amount;
    playerSpeedBuffFrames = frames;
  }

  void applyDamageReductionBuff(double percent, int frames) {
    playerDamageReductionBuff = percent;
    playerDamageReductionBuffFrames = frames;
  }

  int get effectivePlayerSpeed => player.speed + playerSpeedBuff;

  bool tryEvade(int speed) {
    // Example: 2% evade chance per speed point, max 50%
    double evadeChance = (speed * 0.02).clamp(0, 0.5);
    return _rand.nextDouble() < evadeChance;
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
}
