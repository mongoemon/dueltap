import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class StatusEffectConfig {
  final String effectName;
  final int duration;
  final double strength;
  final bool stackable;
  final String description;

  StatusEffectConfig({
    required this.effectName,
    required this.duration,
    required this.strength,
    required this.stackable,
    required this.description,
  });

  static Future<List<StatusEffectConfig>> loadAll() async {
    final raw = await rootBundle.loadString('assets/status_effects.csv');
    final lines = LineSplitter.split(raw).toList();
    final header = lines.first.split(',');
    final configs = <StatusEffectConfig>[];
    for (var i = 1; i < lines.length; i++) {
      final row = lines[i].split(',');
      if (row.length < 5) continue;
      configs.add(
        StatusEffectConfig(
          effectName: row[0].trim(),
          duration: int.tryParse(row[1].trim()) ?? 0,
          strength: double.tryParse(row[2].trim()) ?? 0.0,
          stackable: row[3].trim().toLowerCase() == 'true',
          description: row[4].trim(),
        ),
      );
    }
    return configs;
  }
}
