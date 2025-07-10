// Character model: stats, class, skills, equipment
class Character {
  String name;
  CharacterClass charClass;
  int level;
  int exp;
  int attack; // legacy, not used, for compatibility
  int defense;
  int speed;
  int stamina;
  int autoAttack;
  int tapAttack;
  int strength;
  int hp;
  int exhaust;
  int exhaustRecovery;
  List<Skill> skills;
  List<Equipment> equipment;

  Character({
    required this.name,
    required this.charClass,
    this.level = 1,
    this.exp = 0,
    this.attack = 0, // legacy, not used
    this.autoAttack = 10,
    this.tapAttack = 3,
    this.defense = 10,
    this.speed = 10,
    this.stamina = 10,
    this.strength = 0,
    this.hp = 100,
    this.exhaust = 100,
    this.exhaustRecovery = 20,
    this.skills = const [],
    this.equipment = const [],
  });
}

enum CharacterClass { warrior, mage, ninja, knight, priest }

class Skill {
  final String name;
  final String description;
  final int cooldown;
  Skill(this.name, this.description, this.cooldown);
}

class Equipment {
  final String name;
  final String type;
  final Map<String, int> statBoosts;
  Equipment(this.name, this.type, this.statBoosts);
}
