import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class SkillConfig {
  final String character;
  final String skillName;
  final int cooldown;
  final double multiplier;
  final String effectType;
  final double effectValue;
  final String description;

  SkillConfig({
    required this.character,
    required this.skillName,
    required this.cooldown,
    required this.multiplier,
    required this.effectType,
    required this.effectValue,
    required this.description,
  });

  static Future<List<SkillConfig>> loadAll() async {
    final raw = await rootBundle.loadString('assets/skills.csv');
    final lines = LineSplitter.split(raw).toList();
    final header = lines.first.split(',');
    final configs = <SkillConfig>[];
    for (var i = 1; i < lines.length; i++) {
      final row = lines[i].split(',');
      if (row.length < 7) continue;
      configs.add(
        SkillConfig(
          character: row[0].trim(),
          skillName: row[1].trim(),
          cooldown: int.tryParse(row[2].trim()) ?? 0,
          multiplier: double.tryParse(row[3].trim()) ?? 1.0,
          effectType: row[4].trim(),
          effectValue: double.tryParse(row[5].trim()) ?? 0.0,
          description: row[6].trim(),
        ),
      );
    }
    return configs;
  }
}
