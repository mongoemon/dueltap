// Warrior prototype with basic stats (null safe, idiomatic Dart)
import 'character.dart';

final warriorPrototype = Character(
  name: 'Warrior',
  charClass: CharacterClass.warrior,
  level: 1,
  exp: 0,
  attack: 15,
  defense: 12,
  speed: 10,
  stamina: 12,
  exhaust: 100,
  exhaustRecovery: 20,
  skills: [Skill('Iron Smash', 'High-damage charge attack', 10)],
  equipment: [],
);
