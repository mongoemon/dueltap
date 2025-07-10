import '../../models/character.dart';
import '../../services/character_csv_loader.dart';

Future<List<Character>> loadCharacterPrototypes() async {
  return await loadCharactersFromCsv('assets/characters.csv');
}

final List<Character> characterPrototypes = [];
