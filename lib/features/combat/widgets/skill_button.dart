import 'package:flutter/material.dart';

class SkillButton extends StatelessWidget {
  final String name;
  final int cooldown;
  final bool enabled;
  final VoidCallback? onPressed;

  const SkillButton({
    super.key,
    required this.name,
    required this.cooldown,
    required this.enabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name),
          if (cooldown > 0)
            Text('CD: $cooldown s', style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
