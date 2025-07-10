// Ninja prototype with basic stats
import 'character.dart';

final ninjaPrototype = Character(
  name: 'Ninja',
  charClass: CharacterClass.ninja,
  level: 1,
  exp: 0,
  attack: 12,
  defense: 9,
  speed: 15,
  stamina: 11,
  exhaust: 100,
  exhaustRecovery: 20,
  skills: [], // TODO: Load skills from SkillConfig (CSV) at runtime
  equipment: [],
);
