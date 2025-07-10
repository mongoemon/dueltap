// Mage prototype with basic stats
import 'character.dart';

final magePrototype = Character(
  name: 'Mage',
  charClass: CharacterClass.mage,
  level: 1,
  exp: 0,
  attack: 10,
  defense: 8,
  speed: 12,
  stamina: 10,
  exhaust: 100,
  exhaustRecovery: 20,
  skills: [Skill('Arcane Burst', 'Area-effect skill, high mana cost', 10)],
  equipment: [],
);
