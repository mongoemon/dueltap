import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Holds all global gameplay parameters loaded from battle.csv
class BattleConfig {
  final Map<String, String> _params;
  BattleConfig(this._params);

  int getInt(String key, [int defaultValue = 0]) =>
      int.tryParse(_params[key] ?? '') ?? defaultValue;
  double getDouble(String key, [double defaultValue = 0.0]) =>
      double.tryParse(_params[key] ?? '') ?? defaultValue;
  String getString(String key, [String defaultValue = '']) =>
      _params[key] ?? defaultValue;
}

/// Loads and parses the battle.csv file for global gameplay parameters.
class BattleConfigLoader {
  static Future<BattleConfig> load() async {
    final raw = await rootBundle.loadString('assets/battle.csv');
    final lines = LineSplitter.split(raw).toList();
    final map = <String, String>{};
    for (var i = 1; i < lines.length; i++) {
      final row = lines[i].split(',');
      if (row.length < 2) continue;
      final key = row[0].trim();
      final value = row[1].trim();
      if (key.isNotEmpty) map[key] = value;
    }
    return BattleConfig(map);
  }
}
