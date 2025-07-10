import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class AIConfig {
  final String character;
  final int aggression;
  final int skillUsageFreq;
  final String targetPriority;
  final String description;

  AIConfig({
    required this.character,
    required this.aggression,
    required this.skillUsageFreq,
    required this.targetPriority,
    required this.description,
  });

  static Future<List<AIConfig>> loadAll() async {
    final raw = await rootBundle.loadString('assets/ai.csv');
    final lines = LineSplitter.split(raw).toList();
    final header = lines.first.split(',');
    final configs = <AIConfig>[];
    for (var i = 1; i < lines.length; i++) {
      final row = lines[i].split(',');
      if (row.length < 5) continue;
      configs.add(
        AIConfig(
          character: row[0].trim(),
          aggression: int.tryParse(row[1].trim()) ?? 0,
          skillUsageFreq: int.tryParse(row[2].trim()) ?? 0,
          targetPriority: row[3].trim(),
          description: row[4].trim(),
        ),
      );
    }
    return configs;
  }
}
