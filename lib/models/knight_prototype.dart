// Knight prototype with basic stats
import 'character.dart';

final knightPrototype = Character(
  name: 'Knight',
  charClass: CharacterClass.knight,
  level: 1,
  exp: 0,
  attack: 11,
  defense: 15,
  speed: 9,
  stamina: 12,
  exhaust: 100,
  exhaustRecovery: 20,
  skills: [Skill('Shield Wall', 'Reduces incoming damage', 10)],
  equipment: [],
);
