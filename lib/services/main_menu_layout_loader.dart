import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class MainMenuElementConfig {
  final String element;
  final double x;
  final double y;
  final double width;
  final double height;
  final String animationType;

  MainMenuElementConfig({
    required this.element,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.animationType,
  });

  static Future<List<MainMenuElementConfig>> loadAll() async {
    final raw = await rootBundle.loadString('assets/main_menu_layout.csv');
    final lines = LineSplitter.split(raw).toList();
    final header = lines.first.split(',');
    final configs = <MainMenuElementConfig>[];
    for (var i = 1; i < lines.length; i++) {
      final row = lines[i].split(',');
      if (row.length < 6) continue;
      configs.add(
        MainMenuElementConfig(
          element: row[0].trim(),
          x: double.tryParse(row[1].trim()) ?? 0.5,
          y: double.tryParse(row[2].trim()) ?? 0.5,
          width: double.tryParse(row[3].trim()) ?? 200,
          height: double.tryParse(row[4].trim()) ?? 48,
          animationType: row[5].trim(),
        ),
      );
    }
    return configs;
  }
}
