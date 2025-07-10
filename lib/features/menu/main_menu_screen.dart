// MainMenuScreen: Main navigation menu
import 'package:flutter/material.dart';
import '../../features/combat/combat_screen.dart';
import '../../features/character/character_screen.dart';
import '../../features/shop/shop_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/character/character_select_data.dart';
import '../combat/dummy_character.dart';
import '../story/story_save_slot_screen.dart';
import '../combat/local_pvp_select_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DuelTap')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Always reload dummy from CSV before battle
                final dummy = await loadDummyCharacter();
                // Always reload player from CSV before battle
                final characters = await loadCharacterPrototypes();
                final warrior = characters.firstWhere(
                  (c) => c.name.toLowerCase() == 'warrior',
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        CombatScreen(player: warrior, opponent: dummy),
                  ),
                );
              },
              child: const Text('Play'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CharacterScreen()),
                );
              },
              child: const Text('Character'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ShopScreen()));
              },
              child: const Text('Shop'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              child: const Text('Settings'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StorySaveSlotScreen()),
                );
              },
              child: const Text('Story Mode'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LocalPvpSelectScreen()),
                );
              },
              child: const Text('2P Local'),
            ),
          ],
        ),
      ),
    );
  }
}
