import 'package:flutter/material.dart';
import '../../../models/character.dart';
import 'exhaust_gauge.dart';
import 'skill_button.dart';
import '../../../services/combat_layout_loader.dart';

/// Widget displaying the opponent's avatar.
class OpponentAvatar extends StatelessWidget {
  final String name;
  const OpponentAvatar({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 32,
          // TODO: Replace with actual avatar field if available
          child: Icon(Icons.person, size: 32),
        ),
        SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}

/// Widget displaying the opponent's stats.
class OpponentStats extends StatelessWidget {
  final int hp;
  final int atk;
  final int def;
  final int spd;
  final int sta;
  final int str;
  const OpponentStats({
    Key? key,
    required this.hp,
    required this.atk,
    required this.def,
    required this.spd,
    required this.sta,
    required this.str,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('HP: $hp  ATK: $atk  DEF: $def'),
        Text('SPD: $spd  STA: $sta  STR: $str'),
      ],
    );
  }
}

/// Widget displaying the opponent's auto-attack gauge row if applicable.
class OpponentAutoAttackRow extends StatelessWidget {
  final int autoAttack;
  final int? playerAttackGauge;
  final int? attackGauge;
  const OpponentAutoAttackRow({
    Key? key,
    required this.autoAttack,
    this.playerAttackGauge,
    this.attackGauge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (autoAttack <= 0) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.flash_on, color: Colors.orange, size: 18),
        SizedBox(width: 4),
        Text('Auto-Attack: ${playerAttackGauge ?? attackGauge ?? 0}/100'),
      ],
    );
  }
}

/// Widget displaying the opponent's action buttons (Attack, Heal, Special).
class OpponentActionButtons extends StatelessWidget {
  final VoidCallback? onAttack;
  final VoidCallback? onHeal;
  final VoidCallback? onSpecial;
  const OpponentActionButtons({
    Key? key,
    this.onAttack,
    this.onHeal,
    this.onSpecial,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(onPressed: onAttack, child: const Text('Attack (P2)')),
        ElevatedButton(onPressed: onHeal, child: const Text('Heal (P2)')),
        ElevatedButton(onPressed: onSpecial, child: const Text('Special (P2)')),
      ],
    );
  }
}

/// Widget displaying the opponent's skill buttons row.
class OpponentSkillButtonsRow extends StatelessWidget {
  final List<SkillButton> skillButtons;
  const OpponentSkillButtonsRow({Key? key, required this.skillButtons})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: skillButtons,
    );
  }
}

class AnimatedGaugeBar extends StatelessWidget {
  final double value;
  final double maxValue;
  final Color color;
  final String label;
  final double width;
  final double height;
  const AnimatedGaugeBar({
    super.key,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.label,
    this.width = 120,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: width,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: value / maxValue),
            duration: const Duration(milliseconds: 400),
            builder: (context, val, child) {
              return LinearProgressIndicator(
                value: val,
                minHeight: height,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              );
            },
          ),
        ),
        Text('$label: ${value.toInt()}/${maxValue.toInt()}'),
      ],
    );
  }
}

class OpponentColumn extends StatelessWidget {
  final Character opponent;
  final int hp;
  final int gauge;
  final int recoveryPoints;
  final int? attackGauge;
  final bool showDamage;
  final int? damageAmount;
  final bool showMiss;
  final int? playerAttackGauge;
  final bool showHeal;
  final int? healAmount;
  final int exhaustGauge;
  final int maxExhaustGauge;
  final bool isExhausted;
  final VoidCallback? onAttack;
  final VoidCallback? onHeal;
  final VoidCallback? onSpecial;
  final List<SkillButton> skillButtons;
  final int shieldGauge;
  final int maxShieldGauge;

  const OpponentColumn({
    super.key,
    required this.opponent,
    required this.hp,
    required this.gauge,
    required this.recoveryPoints,
    this.attackGauge,
    required this.showDamage,
    this.damageAmount,
    required this.showMiss,
    this.playerAttackGauge,
    required this.showHeal,
    this.healAmount,
    required this.shieldGauge,
    required this.maxShieldGauge,
    required this.exhaustGauge,
    required this.maxExhaustGauge,
    required this.isExhausted,
    this.onAttack,
    this.onHeal,
    this.onSpecial,
    required this.skillButtons,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, Map<String, double?>>>(
      future: CombatLayoutLoader.load(),
      builder: (context, snapshot) {
        final layout = snapshot.data;
        final screenHeight = MediaQuery.of(context).size.height;
        final damageY =
            (layout?['opponent_damage_number']?['y'] ?? 0.05) * screenHeight;
        final healY =
            (layout?['opponent_heal_number']?['y'] ?? 0.10) * screenHeight;
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                const SizedBox(height: 0),
                OpponentAvatar(name: opponent.name),
                OpponentStats(
                  hp: hp,
                  atk: opponent.autoAttack,
                  def: opponent.defense,
                  spd: opponent.speed,
                  sta: opponent.stamina,
                  str: opponent.strength,
                ),
                // Animated auto-attack gauge
                AnimatedGaugeBar(
                  value: (playerAttackGauge ?? attackGauge ?? 0).toDouble(),
                  maxValue: 100,
                  color: Colors.orange,
                  label: 'Auto-Attack',
                ),
                // Animated shield gauge (if available)
                if (maxShieldGauge > 0)
                  AnimatedGaugeBar(
                    value: shieldGauge.toDouble(),
                    maxValue: maxShieldGauge.toDouble(),
                    color: Colors.blueGrey,
                    label: 'Shield',
                  ),
                const SizedBox(height: 8),
                ExhaustGauge(
                  value: exhaustGauge,
                  maxValue: maxExhaustGauge,
                  isExhausted: isExhausted,
                ),
                OpponentActionButtons(
                  onAttack: onAttack,
                  onHeal: onHeal,
                  onSpecial: onSpecial,
                ),
                OpponentSkillButtonsRow(skillButtons: skillButtons),
              ],
            ),
            if (showDamage && damageAmount != null)
              Positioned(
                top: damageY,
                child: AnimatedOpacity(
                  opacity: showDamage ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '-$damageAmount',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
                    ),
                  ),
                ),
              ),
            if (showHeal && healAmount != null)
              Positioned(
                top: healY,
                child: AnimatedOpacity(
                  opacity: showHeal ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '+$healAmount',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
                    ),
                  ),
                ),
              ),
            if (showMiss)
              Positioned(
                top: 48,
                child: AnimatedOpacity(
                  opacity: showMiss ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Text(
                    'Miss',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
