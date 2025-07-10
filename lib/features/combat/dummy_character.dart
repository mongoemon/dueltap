import '../../models/character.dart';
import '../../services/character_csv_loader.dart';

Future<Character> loadDummyCharacter() async {
  final characters = await loadCharactersFromCsv('assets/characters.csv');
  return characters.firstWhere((c) => c.name.toLowerCase() == 'dummy');
}
