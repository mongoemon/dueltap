import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

/// Loads and parses the combat_layout.csv file for responsive UI layout.
class CombatLayoutLoader {
  /// Loads the layout and returns a map of element name to layout values.
  /// Each value is a map with keys: x, y, width, height (as doubles, or null if not set).
  static Future<Map<String, Map<String, double?>>> load() async {
    final raw = await rootBundle.loadString('assets/combat_layout.csv');
    final rows = const CsvToListConverter(eol: '\n').convert(raw, eol: '\n');
    final header = rows.first as List;
    final map = <String, Map<String, double?>>{};
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i] as List;
      if (row.isEmpty || row[0] == null || row[0].toString().trim().isEmpty)
        continue;
      final name = row[0].toString().trim();
      final x = _parseDouble(row.length > 1 ? row[1] : null);
      final y = _parseDouble(row.length > 2 ? row[2] : null);
      final width = _parseDouble(row.length > 3 ? row[3] : null);
      final height = _parseDouble(row.length > 4 ? row[4] : null);
      map[name] = {'x': x, 'y': y, 'width': width, 'height': height};
    }
    return map;
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }
}
