import 'dart:async';
import 'package:flutter/foundation.dart';
import 'combat_battle_state.dart';
import 'widgets/skill_button.dart';

/// Handles all combat logic, timers, and state updates for the combat screen.
class CombatController {
  final CombatBattleState state;
  final bool localPvp;
  Timer? _recoveryTimer;
  int frameCount = 0;
  int? lastPlayerAttackFrame;
  bool paused = false;
  bool playerAutoAttackEnabled = true;
  bool opponentAutoAttackEnabled = true;
  static const int frameMs = 16;
  static const double framesPerSecond = 1000 / frameMs;
  int _autoAttackFrameCounter = 0;

  CombatController({required this.state, this.localPvp = false}) {
    // In localPvp, do NOT disable opponentAutoAttackEnabled, so auto-attack gauge still works for player 2.
    // Only tap attacks are manual for both players.
  }

  VoidCallback? _onUpdate;

  void setOnUpdate(VoidCallback onUpdate) {
    _onUpdate = onUpdate;
  }

  // --- Attack logic ---
  int _playerAttackCooldown = 0;
  int _opponentAttackCooldown = 0;
  double _playerTapAttackCooldown = 0;
  double _opponentTapAttackCooldown = 0;

  void _notify() {
    if (_onUpdate != null) _onUpdate!();
  }

  // Animation state for player
  bool _playerShowDamage = false;
  int? _playerDamageAmount;
  bool _playerShowHeal = false;
  int? _playerHealAmount;
  Timer? _playerDamageTimer;
  Timer? _playerHealTimer;

  bool get playerShowDamage => _playerShowDamage;
  int? get playerDamageAmount => _playerDamageAmount;
  bool get playerShowHeal => _playerShowHeal;
  int? get playerHealAmount => _playerHealAmount;

  // Miss animation state (stubbed for now)
  bool get playerShowMiss => false;
  bool get opponentShowMiss => false;

  // Animation state for opponent
  bool _opponentShowDamage = false;
  int? _opponentDamageAmount;
  bool _opponentShowHeal = false;
  int? _opponentHealAmount;
  Timer? _opponentDamageTimer;
  Timer? _opponentHealTimer;

  bool get opponentShowDamage => _opponentShowDamage;
  int? get opponentDamageAmount => _opponentDamageAmount;
  bool get opponentShowHeal => _opponentShowHeal;
  int? get opponentHealAmount => _opponentHealAmount;

  void _showPlayerDamage(int amount) {
    _playerShowDamage = true;
    _playerDamageAmount = amount;
    _playerDamageTimer?.cancel();
    _playerDamageTimer = Timer(const Duration(milliseconds: 800), () {
      _playerShowDamage = false;
      _playerDamageAmount = null;
      _notify();
    });
    _notify();
  }

  void _showPlayerHeal(int amount) {
    _playerShowHeal = true;
    _playerHealAmount = amount;
    _playerHealTimer?.cancel();
    _playerHealTimer = Timer(const Duration(milliseconds: 800), () {
      _playerShowHeal = false;
      _playerHealAmount = null;
      _notify();
    });
    _notify();
  }

  void _showOpponentDamage(int amount) {
    _opponentShowDamage = true;
    _opponentDamageAmount = amount;
    _opponentDamageTimer?.cancel();
    _opponentDamageTimer = Timer(const Duration(milliseconds: 800), () {
      _opponentShowDamage = false;
      _opponentDamageAmount = null;
      _notify();
    });
    _notify();
  }

  void _showOpponentHeal(int amount) {
    _opponentShowHeal = true;
    _opponentHealAmount = amount;
    _opponentHealTimer?.cancel();
    _opponentHealTimer = Timer(const Duration(milliseconds: 800), () {
      _opponentShowHeal = false;
      _opponentHealAmount = null;
      _notify();
    });
    _notify();
  }

  void _doPlayerAttack() {
    if (_playerTapAttackCooldown > 0) return;
    if (state.isPlayerExhausted || state.opponentHp <= 0) return;
    state.depletePlayerExhaust();
    int damage = (state.player.tapAttack - state.opponent.defense).clamp(
      1,
      999,
    );
    state.opponentHp -= damage;
    if (state.opponentHp < 0) state.opponentHp = 0;
    lastPlayerAttackFrame = frameCount;
    _playerTapAttackCooldown = state.player.tapAttackCooldown;
    _showOpponentDamage(damage);
    _notify();
  }

  void _doPlayerAutoAttack() {
    if (state.opponentHp <= 0) return;
    int damage = (state.player.autoAttack - state.opponent.defense).clamp(
      1,
      999,
    );
    state.opponentHp -= damage;
    if (state.opponentHp < 0) state.opponentHp = 0;
    _showOpponentDamage(damage);
    _notify();
  }

  void _doOpponentAttack() {
    if (_opponentTapAttackCooldown > 0) return;
    if (state.isOpponentExhausted || state.playerHp <= 0) return;
    state.depleteOpponentExhaust();
    int damage = (state.opponent.tapAttack - state.player.defense).clamp(
      1,
      999,
    );
    state.playerHp -= damage;
    if (state.playerHp < 0) state.playerHp = 0;
    _opponentTapAttackCooldown = state.opponent.tapAttackCooldown;
    _showPlayerDamage(damage);
    _notify();
  }

  void onPlayerAttack() {
    _doPlayerAttack();
  }

  void onOpponentAttack() {
    _doOpponentAttack();
  }

  void onPlayerHeal() {
    if (state.playerHp > 0) {
      int heal = state.healAmount;
      state.playerHp += heal;
      if (state.playerHp > state.player.hp) state.playerHp = state.player.hp;
      _showPlayerHeal(heal);
      _notify();
    }
  }

  void onOpponentHeal() {
    if (state.opponentHp > 0) {
      int heal = state.healAmount;
      state.opponentHp += heal;
      if (state.opponentHp > state.opponent.hp)
        state.opponentHp = state.opponent.hp;
      _showOpponentHeal(heal);
      _notify();
    }
  }

  void onPlayerSpecial() {
    // Example: double damage
    if (state.isPlayerExhausted || state.opponentHp <= 0) return;
    state.depletePlayerExhaust();
    int damage = ((state.player.autoAttack * 2) - state.opponent.defense).clamp(
      1,
      999,
    );
    state.opponentHp -= damage;
    if (state.opponentHp < 0) state.opponentHp = 0;
    _showOpponentDamage(damage);
    _notify();
  }

  void onOpponentSpecial() {
    if (state.isOpponentExhausted || state.playerHp <= 0) return;
    state.depleteOpponentExhaust();
    int damage = ((state.opponent.autoAttack * 2) - state.player.defense).clamp(
      1,
      999,
    );
    state.playerHp -= damage;
    if (state.playerHp < 0) state.playerHp = 0;
    _showPlayerDamage(damage);
    _notify();
  }

  void onPlayerShield() {
    if (!state.playerShieldActive && state.playerShieldGauge > 0) {
      state.playerShieldActive = true;
      state.playerShieldGauge -= 20;
      if (state.playerShieldGauge < 0) state.playerShieldGauge = 0;
      _notify();
    }
  }

  void start(VoidCallback onTick) {
    _recoveryTimer = Timer.periodic(const Duration(milliseconds: frameMs), (_) {
      if (paused) return;
      frameCount++;
      // --- Exhaust recovery logic ---
      if (shouldRecoverExhaust()) {
        state.recoverPlayerExhaust();
      }
      // --- Auto-attack gauge logic (throttled to once per second) ---
      _autoAttackFrameCounter++;
      if (_autoAttackFrameCounter >= 60) {
        // ~1 second at 60 FPS
        _autoAttackFrameCounter = 0;
        if (state.incrementPlayerAttackGauge()) {
          // When gauge is full, perform auto-attack and reset gauge.
          _doPlayerAutoAttack();
        }
      }
      // --- Tap attack cooldown logic ---
      if (_playerTapAttackCooldown > 0) {
        _playerTapAttackCooldown -= frameMs / 1000.0;
        if (_playerTapAttackCooldown < 0) _playerTapAttackCooldown = 0;
      }
      if (_opponentTapAttackCooldown > 0) {
        _opponentTapAttackCooldown -= frameMs / 1000.0;
        if (_opponentTapAttackCooldown < 0) _opponentTapAttackCooldown = 0;
      }
      // --- Existing auto/manual attack logic ---
      // REMOVE: if (playerAutoAttackEnabled && _playerAttackCooldown <= 0) { _doPlayerAttack(); ... }
      // Manual attacks are only triggered by onPlayerAttack (tap), not in the timer loop.
      if (_playerAttackCooldown > 0) {
        _playerAttackCooldown--;
      }
      if (opponentAutoAttackEnabled && _opponentAttackCooldown <= 0) {
        _doOpponentAttack();
      } else if (_opponentAttackCooldown > 0) {
        _opponentAttackCooldown--;
      }
      onTick();
    });
  }

  void stop() {
    _recoveryTimer?.cancel();
  }

  void dispose() {
    stop();
  }

  bool shouldRecoverExhaust() {
    return lastPlayerAttackFrame == null ||
        frameCount - lastPlayerAttackFrame! >= (2 * framesPerSecond).round();
  }

  // Skill buttons for player and opponent
  List<SkillButton> get playerSkillButtons => [];
  List<SkillButton> get opponentSkillButtons => [];
}
