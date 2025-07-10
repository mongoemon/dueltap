// BattleHUD: Widget overlay for health, stamina, combo
import 'package:flutter/material.dart';

class BattleHUD extends StatelessWidget {
  final int playerHealth;
  final int opponentHealth;
  final int playerStamina;
  final int combo;
  final int timer;

  const BattleHUD({
    super.key,
    required this.playerHealth,
    required this.opponentHealth,
    required this.playerStamina,
    required this.combo,
    required this.timer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('HP: $playerHealth'),
            const SizedBox(width: 16),
            Text('Enemy HP: $opponentHealth'),
          ],
        ),
        Row(
          children: [
            Text('Stamina: $playerStamina'),
            const SizedBox(width: 16),
            Text('Combo: $combo'),
            const SizedBox(width: 16),
            Text('Time: $timer'),
          ],
        ),
      ],
    );
  }
}
