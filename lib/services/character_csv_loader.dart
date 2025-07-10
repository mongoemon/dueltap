import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/character.dart';

Future<List<Character>> loadCharactersFromCsv(String assetPath) async {
  final csvString = await rootBundle.loadString(assetPath);
  final lines = LineSplitter.split(csvString).toList();
  final header = lines.first.split(',');
  final nameIdx = header.indexOf('name');
  final autoAtkIdx = header.indexOf('auto_attack');
  final tapAtkIdx = header.indexOf('tap_attack');
  final defIdx = header.indexOf('defense');
  final spdIdx = header.indexOf('speed');
  final staIdx = header.indexOf('stamina');
  final strIdx = header.indexOf('strength');
  final hpIdx = header.indexOf('hp');
  final exhaustIdx = header.indexOf('exhaust');
  final exhaustCostPercentIdx = header.indexOf('exhaust_cost_percent');
  final exhaustRecoverySlowIdx = header.indexOf('exhaust_recovery_slow');
  final exhaustRecoveryNormalIdx = header.indexOf('exhaust_recovery_normal');
  final tapAttackCooldownIdx = header.indexOf('tap_attack_cooldown');

  return lines.skip(1).map((line) {
    final fields = line.split(',');
    final name = fields[nameIdx];
    final charClass = CharacterClass.values.firstWhere(
      (e) => e.name.toLowerCase() == name.toLowerCase(),
      orElse: () => CharacterClass.knight,
    );
    return Character(
      name: name,
      charClass: charClass,
      autoAttack: int.parse(fields[autoAtkIdx]),
      tapAttack: int.parse(fields[tapAtkIdx]),
      defense: int.parse(fields[defIdx]),
      speed: int.parse(fields[spdIdx]),
      stamina: int.parse(fields[staIdx]),
      strength: int.parse(fields[strIdx]),
      hp: int.parse(fields[hpIdx]),
      exhaust: int.parse(fields[exhaustIdx]),
      exhaustCostPercent: int.parse(fields[exhaustCostPercentIdx]),
      exhaustRecoverySlow: int.parse(fields[exhaustRecoverySlowIdx]),
      exhaustRecoveryNormal: int.parse(fields[exhaustRecoveryNormalIdx]),
      tapAttackCooldown: double.parse(fields[tapAttackCooldownIdx]),
    );
  }).toList();
}
