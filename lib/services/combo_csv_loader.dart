import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ComboConfig {
  final String comboName;
  final int threshold;
  final double multiplier;
  final String bonusType;
  final double bonusValue;
  final String description;

  ComboConfig({
    required this.comboName,
    required this.threshold,
    required this.multiplier,
    required this.bonusType,
    required this.bonusValue,
    required this.description,
  });

  static Future<List<ComboConfig>> loadAll() async {
    final raw = await rootBundle.loadString('assets/combo.csv');
    final lines = LineSplitter.split(raw).toList();
    final header = lines.first.split(',');
    final configs = <ComboConfig>[];
    for (var i = 1; i < lines.length; i++) {
      final row = lines[i].split(',');
      if (row.length < 6) continue;
      configs.add(
        ComboConfig(
          comboName: row[0].trim(),
          threshold: int.tryParse(row[1].trim()) ?? 0,
          multiplier: double.tryParse(row[2].trim()) ?? 1.0,
          bonusType: row[3].trim(),
          bonusValue: double.tryParse(row[4].trim()) ?? 0.0,
          description: row[5].trim(),
        ),
      );
    }
    return configs;
  }
}
