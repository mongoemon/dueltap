// Battle model: PvP/PvE battle state
import 'character.dart';

enum BattleType { pvp, pve }

enum BattleResult { win, lose, draw }

class Battle {
  final Character player;
  final Character opponent;
  final BattleType type;
  int playerHealth;
  int opponentHealth;
  int combo;
  int timer;
  int playerStamina;
  int opponentStamina;
  final int maxStamina;
  double staminaRegenRate; // per second
  int playerGauge; // 0-100, fills on attack/hit
  int opponentGauge;
  int playerRecoveryPoints; // Number of times player can heal
  int opponentRecoveryPoints;

  Battle({
    required this.player,
    required this.opponent,
    required this.type,
    this.playerHealth = 100,
    this.opponentHealth = 100,
    this.combo = 0,
    this.timer = 60,
    this.maxStamina = 10,
    this.staminaRegenRate = 2.0,
    this.playerGauge = 0,
    this.opponentGauge = 0,
    this.playerRecoveryPoints = 2,
    this.opponentRecoveryPoints = 2,
  }) : playerStamina = 10,
       opponentStamina = 10;

  bool get isPlayerSpecialAvailable => playerGauge >= 100;
  bool get isOpponentSpecialAvailable => opponentGauge >= 100;

  void resetPlayerGauge() => playerGauge = 0;
  void resetOpponentGauge() => opponentGauge = 0;
}
