// CombatScreen: Handles tap/charge combat UI and logic
import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/character.dart';
import 'combat_battle_state.dart';

class CombatScreen extends StatefulWidget {
  final Character player;
  final Character opponent;
  const CombatScreen({super.key, required this.player, required this.opponent});

  @override
  State<CombatScreen> createState() => _CombatScreenState();
}

class _CombatScreenState extends State<CombatScreen> {
  late CombatBattleState state;
  Timer? _recoveryTimer;

  // For damage number animation
  int? _playerDamage;
  int? _opponentDamage;
  bool _showPlayerDamage = false;
  bool _showOpponentDamage = false;

  // For miss animation
  bool _showPlayerMiss = false;
  bool _showOpponentMiss = false;

  // For healing number animation
  int? _playerHeal;
  int? _opponentHeal;
  bool _showPlayerHeal = false;
  bool _showOpponentHeal = false;

  // Skill cooldowns
  Map<String, int> _skillCooldowns = {};

  // Debug controls
  bool _debugMenuOpen = false;
  bool _playerAutoAttackEnabled = true;
  bool _opponentAutoAttackEnabled = true;

  // Debug log
  final List<String> _debugLog = [];

  // Pause state
  bool _paused = false;

  // Battle summary tracking
  DateTime? _battleStartTime;
  int _playerTotalDamageDealt = 0;
  int _playerTotalDamageReceived = 0;
  int _goldEarned = 0;
  int _expEarned = 0;
  bool _summaryShown = false;

  static const int frameMs = 16; // ~60 FPS
  static const double framesPerSecond = 1000 / frameMs;

  void _log(String msg) {
    if (_debugMenuOpen) {
      setState(() {
        _debugLog.add(msg);
        if (_debugLog.length > 50) _debugLog.removeAt(0);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    state = CombatBattleState(player: widget.player, opponent: widget.opponent);
    _battleStartTime = DateTime.now();
    _recoveryTimer = Timer.periodic(const Duration(milliseconds: frameMs), (_) {
      if (_paused) return;
      setState(() {
        _autoRecoverHealth(frame: true);
        _autoOpponentAttack(frame: true);
        _autoPlayerAttack(frame: true);
        _autoDepleteShield(frame: true);
        _tickSkillCooldowns();
        state.tickBuffs(); // Tick buffs each frame
        _checkBattleEnd();
        _recoverExhaust(frame: true);
      });
    });
  }

  @override
  void dispose() {
    _recoveryTimer?.cancel();
    super.dispose();
  }

  void _autoRecoverHealth({bool frame = false}) {
    // Stop all real-time actions if game is over
    if (state.playerHp == 0 || state.opponentHp == 0) {
      _recoveryTimer?.cancel();
      return;
    }
    // Only recover HP every second, not every frame
    if (!frame) {
      if (state.playerHp < state.player.hp) {
        state.playerHp += 2;
        if (state.playerHp > state.player.hp) state.playerHp = state.player.hp;
      }
      if (state.opponentHp < state.opponent.hp) {
        state.opponentHp += 2;
        if (state.opponentHp > state.opponent.hp)
          state.opponentHp = state.opponent.hp;
      }
    }
  }

  void _autoOpponentAttack({bool frame = false}) {
    if (!_opponentAutoAttackEnabled) return;
    if (state.playerHp == 0 || state.opponentHp == 0) {
      _recoveryTimer?.cancel();
      return;
    }
    double fillPerSecond = (state.opponent.stamina * 7).toDouble();
    double fillPerFrame = fillPerSecond / framesPerSecond;
    state.opponentAttackGauge += fillPerFrame.round();
    _log('Opponent gauge +${fillPerFrame.round()} (now ${state.opponentAttackGauge})');
    if (state.opponentAttackGauge >= state.maxAttackGauge) {
      state.opponentAttackGauge = 0;
      int before = state.playerHp;
      bool hit = state.opponentAutoAttackWithEvade();
      int dmg = before - state.playerHp;
      if (hit && dmg > 0) {
        _log('Opponent auto attacks Player for $dmg');
        _showDamage(toPlayer: true, amount: dmg);
      } else if (!hit) {
        _log('Opponent auto attack missed');
        _showMiss(toPlayer: true);
      }
    }
  }

  void _autoPlayerAttack({bool frame = false}) {
    if (!_playerAutoAttackEnabled) return;
    if (state.playerHp == 0 || state.opponentHp == 0) return;
    double fillPerSecond = (state.player.stamina * 7).toDouble();
    double fillPerFrame = fillPerSecond / framesPerSecond;
    state.playerAttackGauge += fillPerFrame.round();
    _log('Player gauge +${fillPerFrame.round()} (now ${state.playerAttackGauge})');
    if (state.playerAttackGauge >= state.maxPlayerAttackGauge) {
      state.playerAttackGauge = 0;
      int before = state.opponentHp;
      bool hit = state.playerAutoAttackWithEvade();
      int dmg = before - state.opponentHp;
      if (hit && dmg > 0) {
        _log('Player auto attacks Opponent for $dmg');
        _showDamage(toPlayer: false, amount: dmg);
      } else if (!hit) {
        _log('Player auto attack missed');
        _showMiss(toPlayer: false);
      }
    }
  }

  void _autoDepleteShield({bool frame = false}) {
    if (state.playerShieldActive) {
      // Deplete shield every second, not every frame
      if (!frame) state.depletePlayerShieldGauge();
    }
  }

  void _checkBattleEnd() {
    if (!_summaryShown && (state.playerHp == 0 || state.opponentHp == 0)) {
      _summaryShown = true;
      _showBattleSummary();
    }
  }

  void _showBattleSummary() {
    final duration = DateTime.now().difference(_battleStartTime!);
    _goldEarned = (state.opponent.hp / 10).round() + (_playerTotalDamageDealt / 20).round();
    _expEarned = (state.opponent.hp / 5).round() + (_playerTotalDamageDealt / 10).round();
    bool canDismiss = false;
    final String winner = state.playerHp > 0 ? 'Player 1 Wins!' : 'Player 2 Wins!';
    showGeneralDialog(
      context: context,
      barrierDismissible: false, // block dismiss until transition done
      barrierLabel: 'Summary',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        if (anim1.status == AnimationStatus.completed && !canDismiss) {
          Future.delayed(Duration.zero, () => canDismiss = true);
        }
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              title: const Text('Battle Summary'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(winner, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Time Spent: ${duration.inSeconds}s'),
                  Text('Total Damage Dealt: $_playerTotalDamageDealt'),
                  Text('Total Damage Received: $_playerTotalDamageReceived'),
                  Text('Gold Earned: $_goldEarned'),
                  Text('Experience Earned: $_expEarned'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (canDismiss) Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Track damage for summary
  void _showDamage({
    required bool toPlayer,
    required int amount,
    bool isHeal = false,
  }) {
    if (isHeal) {
      if (toPlayer) {
        setState(() {
          _playerHeal = amount;
          _showPlayerHeal = true;
        });
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) setState(() => _showPlayerHeal = false);
        });
      } else {
        setState(() {
          _opponentHeal = amount;
          _showOpponentHeal = true;
        });
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) setState(() => _showOpponentHeal = false);
        });
      }
      return;
    }
    if (!isHeal) {
      if (toPlayer) {
        _playerTotalDamageReceived += amount;
      } else {
        _playerTotalDamageDealt += amount;
      }
    }
    if (toPlayer) {
      setState(() {
        _playerDamage = amount;
        _showPlayerDamage = true;
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _showPlayerDamage = false);
      });
    } else {
      setState(() {
        _opponentDamage = amount;
        _showOpponentDamage = true;
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _showOpponentDamage = false);
      });
    }
  }

  void _showMiss({required bool toPlayer}) {
    if (toPlayer) {
      setState(() => _showPlayerMiss = true);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _showPlayerMiss = false);
      });
    } else {
      setState(() => _showOpponentMiss = true);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _showOpponentMiss = false);
      });
    }
  }

  void _useSkill(Skill skill) {
    if ((_skillCooldowns[skill.name] ?? 0) > 0) return;
    setState(() {
      if (skill.name == 'Iron Smash') {
        int dmg = (state.player.autoAttack * 2.5).round();
        dmg = (dmg * (1 - state.opponent.strength / 100)).round();
        state.opponentHp -= dmg;
        if (state.opponentHp < 0) state.opponentHp = 0;
        _log('Player uses Iron Smash for $dmg damage');
        _showDamage(toPlayer: false, amount: dmg);
      } else if (skill.name == 'Arcane Burst') {
        int dmg = (state.player.autoAttack * 2.0).round();
        dmg = (dmg * (1 - state.opponent.strength / 100)).round();
        state.opponentHp -= dmg;
        if (state.opponentHp < 0) state.opponentHp = 0;
        _log('Player uses Arcane Burst for $dmg damage');
        _showDamage(toPlayer: false, amount: dmg);
      } else if (skill.name == 'Shadow Strike') {
        state.applySpeedBuff(10, (5 * framesPerSecond).toInt());
        _log('Player uses Shadow Strike (Speed +10 for 5s)');
      } else if (skill.name == 'Shield Wall') {
        state.applyDamageReductionBuff(0.3, (5 * framesPerSecond).toInt());
        _log('Player uses Shield Wall (30% damage reduction for 5s)');
      } else if (skill.name == 'Divine Heal') {
        int before = state.playerHp;
        state.playerHp += 30;
        if (state.playerHp > state.player.hp) state.playerHp = state.player.hp;
        int heal = state.playerHp - before;
        if (heal > 0) _log('Player uses Divine Heal (+$heal HP)');
        if (heal > 0) _showDamage(toPlayer: true, amount: heal);
      }
      _skillCooldowns[skill.name] = skill.cooldown * 60; // cooldown in frames
    });
  }

  void _useOpponentSkill(Skill skill) {
    if ((_skillCooldowns['op_${skill.name}'] ?? 0) > 0) return;
    setState(() {
      if (skill.name == 'Iron Smash') {
        int dmg = (state.opponent.autoAttack * 2.5).round();
        dmg = (dmg * (1 - state.player.strength / 100)).round();
        state.playerHp -= dmg;
        if (state.playerHp < 0) state.playerHp = 0;
        _log('Opponent uses Iron Smash for $dmg damage');
        _showDamage(toPlayer: true, amount: dmg);
      } else if (skill.name == 'Arcane Burst') {
        int dmg = (state.opponent.autoAttack * 2.0).round();
        dmg = (dmg * (1 - state.player.strength / 100)).round();
        state.playerHp -= dmg;
        if (state.playerHp < 0) state.playerHp = 0;
        _log('Opponent uses Arcane Burst for $dmg damage');
        _showDamage(toPlayer: true, amount: dmg);
      } else if (skill.name == 'Shadow Strike') {
        // Buff: increase opponent speed by 10 for 5 seconds (not implemented for opponent)
        _log('Opponent uses Shadow Strike (no effect in demo)');
      } else if (skill.name == 'Shield Wall') {
        // Buff: reduce all incoming damage by 30% for 5 seconds (not implemented for opponent)
        _log('Opponent uses Shield Wall (no effect in demo)');
      } else if (skill.name == 'Divine Heal') {
        int before = state.opponentHp;
        state.opponentHp += 30;
        if (state.opponentHp > state.opponent.hp) state.opponentHp = state.opponent.hp;
        int heal = state.opponentHp - before;
        if (heal > 0) _log('Opponent uses Divine Heal (+$heal HP)');
        if (heal > 0) _showDamage(toPlayer: false, amount: heal);
      }
      _skillCooldowns['op_${skill.name}'] = skill.cooldown * 60; // cooldown in frames
    });
  }

  void _tickSkillCooldowns() {
    setState(() {
      _skillCooldowns.updateAll((key, value) => value > 0 ? value - 1 : 0);
    });
  }

  void _showParamModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        int tempPlayerHp = state.playerHp;
        int tempOpponentHp = state.opponentHp;
        int tempPlayerAtk = state.player.autoAttack;
        int tempOpponentAtk = state.opponent.autoAttack;
        int tempPlayerDef = state.player.defense;
        int tempOpponentDef = state.opponent.defense;
        int tempPlayerSpd = state.player.speed;
        int tempOpponentSpd = state.opponent.speed;
        int tempPlayerSta = state.player.stamina;
        int tempOpponentSta = state.opponent.stamina;
        int tempPlayerStr = state.player.strength;
        int tempOpponentStr = state.opponent.strength;
        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              shrinkWrap: true,
              children: [
                const Text('Parameter Debug', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SwitchListTile(
                  title: const Text('Player Auto-Attack'),
                  value: _playerAutoAttackEnabled,
                  onChanged: (v) => setState(() => _playerAutoAttackEnabled = v),
                ),
                SwitchListTile(
                  title: const Text('Opponent Auto-Attack'),
                  value: _opponentAutoAttackEnabled,
                  onChanged: (v) => setState(() => _opponentAutoAttackEnabled = v),
                ),
                const Divider(),
                const Text('Force Player Parameters:'),
                _debugParamField('HP', tempPlayerHp, (v) => setModalState(() => tempPlayerHp = v)),
                _debugParamField('ATK', tempPlayerAtk, (v) => setModalState(() => tempPlayerAtk = v)),
                _debugParamField('DEF', tempPlayerDef, (v) => setModalState(() => tempPlayerDef = v)),
                _debugParamField('SPD', tempPlayerSpd, (v) => setModalState(() => tempPlayerSpd = v)),
                _debugParamField('STA', tempPlayerSta, (v) => setModalState(() => tempPlayerSta = v)),
                _debugParamField('STR', tempPlayerStr, (v) => setModalState(() => tempPlayerStr = v)),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      state.playerHp = tempPlayerHp;
                      state.player.autoAttack = tempPlayerAtk;
                      state.player.defense = tempPlayerDef;
                      state.player.speed = tempPlayerSpd;
                      state.player.stamina = tempPlayerSta;
                      state.player.strength = tempPlayerStr;
                    });
                  },
                  child: const Text('Apply to Player'),
                ),
                const Divider(),
                const Text('Force Opponent Parameters:'),
                _debugParamField('HP', tempOpponentHp, (v) => setModalState(() => tempOpponentHp = v)),
                _debugParamField('ATK', tempOpponentAtk, (v) => setModalState(() => tempOpponentAtk = v)),
                _debugParamField('DEF', tempOpponentDef, (v) => setModalState(() => tempOpponentDef = v)),
                _debugParamField('SPD', tempOpponentSpd, (v) => setModalState(() => tempOpponentSpd = v)),
                _debugParamField('STA', tempOpponentSta, (v) => setModalState(() => tempOpponentSta = v)),
                _debugParamField('STR', tempOpponentStr, (v) => setModalState(() => tempOpponentStr = v)),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      state.opponentHp = tempOpponentHp;
                      state.opponent.autoAttack = tempOpponentAtk;
                      state.opponent.defense = tempOpponentDef;
                      state.opponent.speed = tempOpponentSpd;
                      state.opponent.stamina = tempOpponentSta;
                      state.opponent.strength = tempOpponentStr;
                    });
                  },
                  child: const Text('Apply to Opponent'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _debugParamField(String label, int value, void Function(int) onChanged) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 200,
            divisions: 200,
            label: value.toString(),
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(width: 40, child: Text(value.toString())),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battle')),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Player 1 area
                  Column(
                    children: [
                      _characterColumn(
                        state.player,
                        state.playerHp,
                        gauge: state.playerGauge,
                        recoveryPoints: state.playerRecoveryPoints,
                        playerAttackGauge: state.playerAttackGauge,
                        showDamage: _showPlayerDamage,
                        damageAmount: _playerDamage,
                        showMiss: _showPlayerMiss,
                      ),
                      const SizedBox(height: 8),
                      // Exhaust gauge and status
                      SizedBox(
                        width: 120,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0.0,
                            end: state.playerExhaustGauge / state.maxExhaustGauge,
                          ),
                          duration: const Duration(milliseconds: 400),
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 8,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                            );
                          },
                        ),
                      ),
                      Text('Exhaust: ${state.playerExhaustGauge}/${state.maxExhaustGauge}'),
                      if (state.isPlayerExhausted)
                        const Text('Exhaust', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: state.opponentHp > 0 && !state.isPlayerExhausted
                            ? () {
                                int before = state.opponentHp;
                                bool hit = state.attackOpponentWithEvade();
                                int dmg = before - state.opponentHp;
                                if (hit && dmg > 0) {
                                  _showDamage(toPlayer: false, amount: dmg);
                                } else if (!hit) {
                                  _showMiss(toPlayer: false);
                                }
                                state.depletePlayerExhaust();
                              }
                            : null,
                        child: const Text('Attack'),
                      ),
                      ElevatedButton(
                        onPressed:
                            (state.playerRecoveryPoints > 0 &&
                                state.playerHp < state.player.hp &&
                                state.opponentHp > 0)
                        ? () {
                            int before = state.playerHp;
                            setState(() {
                              state.healPlayer();
                            });
                            int heal = state.playerHp - before;
                            if (heal > 0)
                              _showDamage(toPlayer: true, amount: heal, isHeal: true);
                        }
                        : null,
                        child: const Text('Heal'),
                      ),
                      ElevatedButton(
                        onPressed: (state.playerGauge >= 100 && state.opponentHp > 0)
                            ? () {
                                int before = state.opponentHp;
                                setState(() {
                                  state.specialAttackOpponent();
                                });
                                int dmg = before - state.opponentHp;
                                if (dmg > 0) _showDamage(toPlayer: false, amount: dmg);
                              }
                            : null,
                        child: const Text('Special Attack'),
                      ),
                      if (widget.player.name.toLowerCase() == 'warrior' &&
                          !state.playerShieldActive &&
                          state.playerHp > 0 &&
                          state.opponentHp > 0)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              state.activatePlayerShield();
                            });
                          },
                          child: const Text('Shield'),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (state.player.skills.isNotEmpty)
                              for (final skill in state.player.skills)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: ElevatedButton(
                                    onPressed: (_skillCooldowns[skill.name] ?? 0) == 0 && state.opponentHp > 0
                                        ? () => _useSkill(skill)
                                        : null,
                                    child: Column(
                                      children: [
                                        Text(skill.name),
                                        if ((_skillCooldowns[skill.name] ?? 0) > 0)
                                          Text('CD: \\${(_skillCooldowns[skill.name]! / 60).ceil()}s', style: const TextStyle(fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                )
                            else
                              ElevatedButton(
                                onPressed: null,
                                child: const Text('No Skills'),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Player 2 area
                  if (widget.player != widget.opponent)
                    Column(
                      children: [
                        _characterColumn(
                          state.opponent,
                          state.opponentHp,
                          gauge: state.opponentGauge,
                          recoveryPoints: state.opponentRecoveryPoints,
                          attackGauge: state.opponentAttackGauge,
                          showDamage: _showOpponentDamage,
                          damageAmount: _opponentDamage,
                          showMiss: _showOpponentMiss,
                        ),
                        const SizedBox(height: 8),
                        // Exhaust gauge and status for opponent
                        SizedBox(
                          width: 120,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0.0,
                              end: state.opponentExhaustGauge / state.maxExhaustGauge,
                            ),
                            duration: const Duration(milliseconds: 400),
                            builder: (context, value, child) {
                              return LinearProgressIndicator(
                                value: value,
                                minHeight: 8,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                              );
                            },
                          ),
                        ),
                        Text('Exhaust: ${state.opponentExhaustGauge}/${state.maxExhaustGauge}'),
                        if (state.isOpponentExhausted)
                          const Text('Exhaust', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                        ElevatedButton(
                          onPressed: state.playerHp > 0 && !state.isOpponentExhausted
                              ? () {
                                  int before = state.playerHp;
                                  bool hit = state.attackPlayerWithEvade();
                                  int dmg = before - state.playerHp;
                                  if (hit && dmg > 0) {
                                    _showDamage(toPlayer: true, amount: dmg);
                                  } else if (!hit) {
                                    _showMiss(toPlayer: true);
                                  }
                                  state.depleteOpponentExhaust();
                            }
                              : null,
                          child: const Text('Attack (P2)'),
                        ),
                        ElevatedButton(
                          onPressed: (state.opponentRecoveryPoints > 0 && state.opponentHp < state.opponent.hp && state.playerHp > 0)
                              ? () {
                                  int before = state.opponentHp;
                                  setState(() {
                                    state.healOpponent();
                                  });
                                  int heal = state.opponentHp - before;
                                  if (heal > 0) _showDamage(toPlayer: false, amount: heal, isHeal: true);
                                }
                              : null,
                          child: const Text('Heal (P2)'),
                        ),
                        ElevatedButton(
                          onPressed: (state.opponentGauge >= 100 && state.playerHp > 0)
                              ? () {
                                  int before = state.playerHp;
                                  setState(() {
                                    state.specialAttackPlayer();
                                  });
                                  int dmg = before - state.playerHp;
                                  if (dmg > 0) _showDamage(toPlayer: true, amount: dmg);
                                }
                              : null,
                          child: const Text('Special (P2)'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (state.opponent.skills.isNotEmpty)
                                for (final skill in state.opponent.skills)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: ElevatedButton(
                                      onPressed: (_skillCooldowns['op_${skill.name}'] ?? 0) == 0 && state.playerHp > 0
                                          ? () => _useOpponentSkill(skill)
                                          : null,
                                      child: Column(
                                        children: [
                                          Text(skill.name),
                                          if ((_skillCooldowns['op_${skill.name}'] ?? 0) > 0)
                                            Text('CD: \\${(_skillCooldowns['op_${skill.name}']! / 60).ceil()}s', style: const TextStyle(fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                  )
                              else
                                ElevatedButton(
                                  onPressed: null,
                                  child: const Text('No Skills'),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              // PvE (Test Battle) mode: show player controls centered below both columns
              if (widget.player == widget.opponent)
                Column(
                  children: [
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: state.opponentHp > 0
                          ? () {
                              int before = state.opponentHp;
                              bool hit = state.attackOpponentWithEvade();
                              int dmg = before - state.opponentHp;
                              if (hit && dmg > 0) {
                                _showDamage(toPlayer: false, amount: dmg);
                              } else if (!hit) {
                                _showMiss(toPlayer: false);
                              }
                            }
                          : null,
                      child: const Text('Attack'),
                    ),
                    ElevatedButton(
                      onPressed:
                          (state.playerRecoveryPoints > 0 &&
                              state.playerHp < state.player.hp &&
                              state.opponentHp > 0)
                      ? () {
                          int before = state.playerHp;
                          setState(() {
                            state.healPlayer();
                          });
                          int heal = state.playerHp - before;
                          if (heal > 0)
                            _showDamage(toPlayer: true, amount: heal, isHeal: true);
                        }
                      : null,
                      child: const Text('Heal'),
                    ),
                    ElevatedButton(
                      onPressed: (state.playerGauge >= 100 && state.opponentHp > 0)
                          ? () {
                              int before = state.opponentHp;
                              setState(() {
                                state.specialAttackOpponent();
                              });
                              int dmg = before - state.opponentHp;
                              if (dmg > 0) _showDamage(toPlayer: false, amount: dmg);
                            }
                          : null,
                      child: const Text('Special Attack'),
                    ),
                    if (widget.player.name.toLowerCase() == 'warrior' &&
                        !state.playerShieldActive &&
                        state.playerHp > 0 &&
                        state.opponentHp > 0)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            state.activatePlayerShield();
                          });
                        },
                        child: const Text('Shield'),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (state.player.skills.isNotEmpty)
                            for (final skill in state.player.skills)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ElevatedButton(
                                  onPressed: (_skillCooldowns[skill.name] ?? 0) == 0 && state.opponentHp > 0
                                      ? () => _useSkill(skill)
                                      : null,
                                  child: Column(
                                    children: [
                                      Text(skill.name),
                                      if ((_skillCooldowns[skill.name] ?? 0) > 0)
                                        Text('CD: \\${(_skillCooldowns[skill.name]! / 60).ceil()}s', style: const TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                ),
                              )
                          else
                            ElevatedButton(
                              onPressed: null,
                              child: const Text('No Skills'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_debugMenuOpen)
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                width: 320,
                height: 180,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView(
                  children: _debugLog.map((e) => Text(e, style: const TextStyle(color: Colors.white, fontSize: 12))).toList(),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'log',
            onPressed: () {
              setState(() => _debugMenuOpen = !_debugMenuOpen);
              if (_debugMenuOpen) _log('Debug log opened');
            },
            child: const Icon(Icons.bug_report),
            tooltip: 'Debug Log',
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'param',
            onPressed: _showParamModal,
            child: const Icon(Icons.settings),
            tooltip: 'Parameter Debug',
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'pause',
            onPressed: () => setState(() => _paused = !_paused),
            child: Icon(_paused ? Icons.play_arrow : Icons.pause),
            tooltip: _paused ? 'Resume Game' : 'Pause Game',
          ),
        ],
      ),
    );
  }

  void _recoverExhaust({bool frame = false}) {
    // Only recover if exhausted
    if (state.isPlayerExhausted) {
      state.recoverPlayerExhaust();
    }
    if (state.isOpponentExhausted) {
      state.recoverOpponentExhaust();
    }
  }

  Widget _characterColumn(
    Character c,
    int hp, {
    required int gauge,
    required int recoveryPoints,
    int? attackGauge, // Optional for opponent
    bool showDamage = false,
    int? damageAmount,
    int? playerAttackGauge, // Optional for player
    bool showMiss = false,
  }) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          children: [
            const SizedBox(height: 8),
            CircleAvatar(child: Text(c.name[0]), radius: 32),
            const SizedBox(height: 8),
            Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('HP: $hp'),
            Text('ATK: ${c.autoAttack}'),
            Text('DEF: ${c.defense}'),
            Text('SPD: ${c.speed}'),
            Text('STA: ${c.stamina}'),
            Text('STR: ${c.strength}'),
            const SizedBox(height: 8),
            SizedBox(
              width: 120,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0.0,
                  end: (gauge.clamp(0, 100)) / 100.0,
                ),
                duration: const Duration(milliseconds: 400),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blueAccent,
                    ),
                  );
                },
              ),
            ),
            Text('Gauge: $gauge/100'),
            Text('Heals: $recoveryPoints'),
            if (playerAttackGauge != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: 120,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0.0,
                    end: (playerAttackGauge.clamp(0, 100)) / 100.0,
                  ),
                  duration: const Duration(milliseconds: 400),
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.orange,
                      ),
                    );
                  },
                ),
              ),
              Text('Attack Gauge: $playerAttackGauge/100'),
            ],
            if (c.name.toLowerCase() == 'warrior' &&
                state.playerShieldActive) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: 120,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0.0,
                    end: (state.playerShieldGauge.clamp(0, 100)) / 100.0,
                  ),
                  duration: const Duration(milliseconds: 400),
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.green,
                      ),
                    );
                  },
                ),
              ),
              Text('Shield: ${state.playerShieldGauge}/100'),
            ],
            if (attackGauge != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: 120,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0.0,
                    end: (attackGauge.clamp(0, 100)) / 100.0,
                  ),
                  duration: const Duration(milliseconds: 400),
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.redAccent,
                      ),
                    );
                  },
                ),
              ),
              Text('Attack Gauge: $attackGauge/100'),
            ],
            if (c == state.player && state.playerSpeedBuffFrames > 0)
              Text('Speed Buff: +${state.playerSpeedBuff} (${(state.playerSpeedBuffFrames / framesPerSecond).ceil()}s)'),
            if (c == state.player && state.playerDamageReductionBuffFrames > 0)
              Text('DMG Reduction: ${(state.playerDamageReductionBuff * 100).round()}% (${(state.playerDamageReductionBuffFrames / framesPerSecond).ceil()}s)'),
          ],
        ),
        if (showDamage && damageAmount != null)
          Positioned(
            top: 32,
            child: AnimatedOpacity(
              opacity: showDamage ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: Text(
                (damageAmount > 0
                    ? '-$damageAmount'
                    : '+${damageAmount.abs()}'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: (damageAmount > 0) ? Colors.red : Colors.blue,
                  shadows: const [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black26,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if ((c == state.player && _showPlayerHeal && _playerHeal != null) ||
            (c == state.opponent && _showOpponentHeal && _opponentHeal != null))
          Positioned(
            top: 0,
            child: AnimatedOpacity(
              opacity: (c == state.player ? _showPlayerHeal : _showOpponentHeal) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: Text(
                '+${(c == state.player ? _playerHeal : _opponentHeal) ?? 0}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black26,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (showMiss)
          Positioned(
            top: 0,
            child: AnimatedOpacity(
              opacity: showMiss ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: Text(
                'miss',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black26,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
