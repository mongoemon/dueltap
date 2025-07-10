// Priest prototype with basic stats
import 'character.dart';

final priestPrototype = Character(
  name: 'Priest',
  charClass: CharacterClass.priest,
  level: 1,
  exp: 0,
  attack: 8,
  defense: 10,
  speed: 10,
  stamina: 13,
  exhaust: 100,
  exhaustRecovery: 20,
  skills: [], // TODO: Load skills from SkillConfig (CSV) at runtime
  equipment: [],
);
