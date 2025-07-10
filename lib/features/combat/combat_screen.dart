// CombatScreen: Handles tap/charge combat UI and logic
import 'package:flutter/material.dart';
import '../../models/character.dart';
import 'combat_battle_state.dart';
import 'combat_controller.dart';
import 'widgets/player_column.dart';
import 'widgets/opponent_column.dart';
import 'widgets/debug_panel.dart';
import '../../services/battle_config_loader.dart';
import '../../services/status_effects_csv_loader.dart';

class CombatScreen extends StatefulWidget {
  final Character player;
  final Character opponent;
  final bool localPvp;
  const CombatScreen({
    super.key,
    required this.player,
    required this.opponent,
    this.localPvp = false,
  });

  @override
  State<CombatScreen> createState() => _CombatScreenState();
}

class _CombatScreenState extends State<CombatScreen> {
  CombatBattleState? state;
  CombatController? controller;
  // UI state only
  bool _debugMenuOpen = false;
  final List<String> _debugLog = [];
  bool _paused = false;
  bool _gameEnded = false;
  late DateTime _battleStartTime;
  Duration? _battleDuration;
  int _playerDamageDealt = 0;
  int _playerDamageTaken = 0;
  int _opponentDamageDealt = 0;
  int _opponentDamageTaken = 0;

  @override
  void initState() {
    super.initState();
    _initBattleState();
  }

  Future<void> _initBattleState() async {
    final config = await BattleConfigLoader.load();
    final statusEffects = await StatusEffectConfig.loadAll();
    setState(() {
      state = CombatBattleState(
        player: widget.player,
        opponent: widget.opponent,
        config: config,
        statusEffects: statusEffects,
      );
      controller = CombatController(state: state!, localPvp: widget.localPvp);
      controller!.setOnUpdate(_trackDamageStats);
      controller!.start(() {
        setState(() {});
      });
      _battleStartTime = DateTime.now();
      _battleDuration = null;
      _playerDamageDealt = 0;
      _playerDamageTaken = 0;
      _opponentDamageDealt = 0;
      _opponentDamageTaken = 0;
    });
  }

  void _trackDamageStats() {
    // Called after every update
    if (controller == null) return;
    // Player deals damage to opponent
    if (controller!.opponentShowDamage &&
        controller!.opponentDamageAmount != null) {
      _playerDamageDealt += controller!.opponentDamageAmount!;
      _opponentDamageTaken += controller!.opponentDamageAmount!;
    }
    // Opponent deals damage to player
    if (controller!.playerShowDamage &&
        controller!.playerDamageAmount != null) {
      _opponentDamageDealt += controller!.playerDamageAmount!;
      _playerDamageTaken += controller!.playerDamageAmount!;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _checkEndGame() {
    if (_gameEnded || state == null) return;
    if (state!.playerHp <= 0 && state!.opponentHp <= 0) {
      _gameEnded = true;
      controller?.stop();
      _battleDuration = DateTime.now().difference(_battleStartTime);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultModal('Draw');
      });
    } else if (state!.playerHp <= 0) {
      _gameEnded = true;
      controller?.stop();
      _battleDuration = DateTime.now().difference(_battleStartTime);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultModal('Defeat');
      });
    } else if (state!.opponentHp <= 0) {
      _gameEnded = true;
      controller?.stop();
      _battleDuration = DateTime.now().difference(_battleStartTime);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultModal('Victory');
      });
    }
  }

  void _showResultModal(String result) {
    String winner;
    if (result == 'Draw') {
      winner = 'Draw';
    } else if (result == 'Victory') {
      winner = widget.player.name;
    } else {
      winner = widget.opponent.name;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Battle Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Winner: $winner'),
            if (_battleDuration != null)
              Text(
                'Time: ${_battleDuration!.inSeconds}.${(_battleDuration!.inMilliseconds % 1000) ~/ 100}s',
              ),
            const SizedBox(height: 8),
            Text('${widget.player.name} Damage Dealt: $_playerDamageDealt'),
            Text('${widget.player.name} Damage Taken: $_playerDamageTaken'),
            Text('${widget.opponent.name} Damage Dealt: $_opponentDamageDealt'),
            Text('${widget.opponent.name} Damage Taken: $_opponentDamageTaken'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _checkEndGame();
    if (state == null || controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Battle')),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.player == widget.opponent)
                // Test Battle mode: show both player and opponent columns centered
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlayerColumn(
                      player: state!.player,
                      hp: state!.playerHp,
                      gauge: state!.playerGauge,
                      recoveryPoints: state!.playerRecoveryPoints,
                      attackGauge: state!.playerAttackGauge,
                      showDamage: controller!
                          .playerShowDamage, // connect to controller animation state
                      damageAmount: controller!
                          .playerDamageAmount, // connect to controller animation state
                      showMiss: controller!
                          .playerShowMiss, // connect to controller animation state
                      playerAttackGauge: state!.playerAttackGauge,
                      showHeal: controller!
                          .playerShowHeal, // connect to controller animation state
                      healAmount: controller!
                          .playerHealAmount, // connect to controller animation state
                      shieldActive: state!.playerShieldActive,
                      shieldGauge: state!.playerShieldGauge,
                      maxShieldGauge: state!.maxShieldGauge,
                      exhaustGauge: state!.playerExhaustGauge,
                      maxExhaustGauge: state!.player.exhaust,
                      isExhausted: state!.isPlayerExhausted,
                      onAttack: controller!.onPlayerAttack,
                      onHeal: controller!.onPlayerHeal,
                      onSpecial: controller!.onPlayerSpecial,
                      onShield: controller!.onPlayerShield,
                      skillButtons: controller!.playerSkillButtons,
                    ),
                    const SizedBox(width: 32),
                    OpponentColumn(
                      opponent: state!.opponent,
                      hp: state!.opponentHp,
                      gauge: state!.opponentGauge,
                      recoveryPoints: state!.opponentRecoveryPoints,
                      attackGauge: state!.opponentAttackGauge,
                      showDamage: controller!.opponentShowDamage,
                      damageAmount: controller!.opponentDamageAmount,
                      showMiss: controller!.opponentShowMiss,
                      playerAttackGauge: state!.opponentAttackGauge,
                      showHeal: controller!.opponentShowHeal,
                      healAmount: controller!.opponentHealAmount,
                      shieldGauge: state!.opponentShieldGauge,
                      maxShieldGauge: state!.maxShieldGauge,
                      exhaustGauge: state!.opponentExhaustGauge,
                      maxExhaustGauge: state!.opponent.exhaust,
                      isExhausted: state!.isOpponentExhausted,
                      onAttack: controller!.onOpponentAttack,
                      onHeal: controller!.onOpponentHeal,
                      onSpecial: controller!.onOpponentSpecial,
                      skillButtons: controller!.opponentSkillButtons,
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlayerColumn(
                      player: state!.player,
                      hp: state!.playerHp,
                      gauge: state!.playerGauge,
                      recoveryPoints: state!.playerRecoveryPoints,
                      attackGauge: state!.playerAttackGauge,
                      showDamage: controller!
                          .playerShowDamage, // connect to controller animation state
                      damageAmount: controller!
                          .playerDamageAmount, // connect to controller animation state
                      showMiss: controller!
                          .playerShowMiss, // connect to controller animation state
                      playerAttackGauge: state!.playerAttackGauge,
                      showHeal: controller!
                          .playerShowHeal, // connect to controller animation state
                      healAmount: controller!
                          .playerHealAmount, // connect to controller animation state
                      shieldActive: state!.playerShieldActive,
                      shieldGauge: state!.playerShieldGauge,
                      maxShieldGauge: state!.maxShieldGauge,
                      exhaustGauge: state!.playerExhaustGauge,
                      maxExhaustGauge: state!.player.exhaust,
                      isExhausted: state!.isPlayerExhausted,
                      onAttack: controller!.onPlayerAttack,
                      onHeal: controller!.onPlayerHeal,
                      onSpecial: controller!.onPlayerSpecial,
                      onShield: controller!.onPlayerShield,
                      skillButtons: controller!.playerSkillButtons,
                    ),
                    OpponentColumn(
                      opponent: state!.opponent,
                      hp: state!.opponentHp,
                      gauge: state!.opponentGauge,
                      recoveryPoints: state!.opponentRecoveryPoints,
                      attackGauge: state!.opponentAttackGauge,
                      showDamage: controller!.opponentShowDamage,
                      damageAmount: controller!.opponentDamageAmount,
                      showMiss: controller!.opponentShowMiss,
                      playerAttackGauge: state!.opponentAttackGauge,
                      showHeal: controller!.opponentShowHeal,
                      healAmount: controller!.opponentHealAmount,
                      shieldGauge: state!.opponentShieldGauge,
                      maxShieldGauge: state!.maxShieldGauge,
                      exhaustGauge: state!.opponentExhaustGauge,
                      maxExhaustGauge: state!.opponent.exhaust,
                      isExhausted: state!.isOpponentExhausted,
                      onAttack: controller!.onOpponentAttack,
                      onHeal: controller!.onOpponentHeal,
                      onSpecial: controller!.onOpponentSpecial,
                      skillButtons: controller!.opponentSkillButtons,
                    ),
                  ],
                ),
            ],
          ),
          if (_debugMenuOpen) DebugPanel(debugLog: _debugLog),
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
            tooltip: 'Debug Log',
            child: const Icon(Icons.bug_report),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'param',
            onPressed: _showParamModal,
            tooltip: 'Parameter Debug',
            child: const Icon(Icons.settings),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'pause',
            onPressed: () => setState(() => _paused = !_paused),
            tooltip: _paused ? 'Resume Game' : 'Pause Game',
            child: Icon(_paused ? Icons.play_arrow : Icons.pause),
          ),
        ],
      ),
    );
  }

  void _log(String msg) {
    setState(() {
      _debugLog.add(msg);
      if (_debugLog.length > 50) _debugLog.removeAt(0);
    });
  }

  void _showParamModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        int tempPlayerHp = state!.playerHp;
        int tempOpponentHp = state!.opponentHp;
        int tempPlayerAtk = state!.player.autoAttack;
        int tempOpponentAtk = state!.opponent.autoAttack;
        int tempPlayerDef = state!.player.defense;
        int tempOpponentDef = state!.opponent.defense;
        int tempPlayerSpd = state!.player.speed;
        int tempOpponentSpd = state!.opponent.speed;
        int tempPlayerSta = state!.player.stamina;
        int tempOpponentSta = state!.opponent.stamina;
        int tempPlayerStr = state!.player.strength;
        int tempOpponentStr = state!.opponent.strength;
        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              shrinkWrap: true,
              children: [
                const Text(
                  'Parameter Debug',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SwitchListTile(
                  title: const Text('Player Auto-Attack'),
                  value: controller!.playerAutoAttackEnabled,
                  onChanged: (v) =>
                      setState(() => controller!.playerAutoAttackEnabled = v),
                ),
                SwitchListTile(
                  title: const Text('Opponent Auto-Attack'),
                  value: controller!.opponentAutoAttackEnabled,
                  onChanged: (v) =>
                      setState(() => controller!.opponentAutoAttackEnabled = v),
                ),
                const Divider(),
                const Text('Force Player Parameters:'),
                _debugParamField(
                  'HP',
                  tempPlayerHp,
                  (v) => setModalState(() => tempPlayerHp = v),
                ),
                _debugParamField(
                  'ATK',
                  tempPlayerAtk,
                  (v) => setModalState(() => tempPlayerAtk = v),
                ),
                _debugParamField(
                  'DEF',
                  tempPlayerDef,
                  (v) => setModalState(() => tempPlayerDef = v),
                ),
                _debugParamField(
                  'SPD',
                  tempPlayerSpd,
                  (v) => setModalState(() => tempPlayerSpd = v),
                ),
                _debugParamField(
                  'STA',
                  tempPlayerSta,
                  (v) => setModalState(() => tempPlayerSta = v),
                ),
                _debugParamField(
                  'STR',
                  tempPlayerStr,
                  (v) => setModalState(() => tempPlayerStr = v),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      state!.playerHp = tempPlayerHp;
                      state!.player.autoAttack = tempPlayerAtk;
                      state!.player.defense = tempPlayerDef;
                      state!.player.speed = tempPlayerSpd;
                      state!.player.stamina = tempPlayerSta;
                      state!.player.strength = tempPlayerStr;
                    });
                  },
                  child: const Text('Apply to Player'),
                ),
                const Divider(),
                const Text('Force Opponent Parameters:'),
                _debugParamField(
                  'HP',
                  tempOpponentHp,
                  (v) => setModalState(() => tempOpponentHp = v),
                ),
                _debugParamField(
                  'ATK',
                  tempOpponentAtk,
                  (v) => setModalState(() => tempOpponentAtk = v),
                ),
                _debugParamField(
                  'DEF',
                  tempOpponentDef,
                  (v) => setModalState(() => tempOpponentDef = v),
                ),
                _debugParamField(
                  'SPD',
                  tempOpponentSpd,
                  (v) => setModalState(() => tempOpponentSpd = v),
                ),
                _debugParamField(
                  'STA',
                  tempOpponentSta,
                  (v) => setModalState(() => tempOpponentSta = v),
                ),
                _debugParamField(
                  'STR',
                  tempOpponentStr,
                  (v) => setModalState(() => tempOpponentStr = v),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      state!.opponentHp = tempOpponentHp;
                      state!.opponent.autoAttack = tempOpponentAtk;
                      state!.opponent.defense = tempOpponentDef;
                      state!.opponent.speed = tempOpponentSpd;
                      state!.opponent.stamina = tempOpponentSta;
                      state!.opponent.strength = tempOpponentStr;
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

  Widget _debugParamField(
    String label,
    int value,
    void Function(int) onChanged,
  ) {
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
}
