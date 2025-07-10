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
import '../../services/main_menu_layout_loader.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  List<MainMenuElementConfig>? _layout;

  @override
  void initState() {
    super.initState();
    _loadLayout();
  }

  Future<void> _loadLayout() async {
    final layout = await MainMenuElementConfig.loadAll();
    setState(() {
      _layout = layout;
    });
  }

  Widget _buildAnimated({
    required Widget child,
    required String animationType,
    required int index,
  }) {
    switch (animationType) {
      case 'fade_in':
        return AnimatedOpacity(
          opacity: 1.0,
          duration: Duration(milliseconds: 500 + index * 100),
          curve: Curves.easeIn,
          child: child,
        );
      case 'slide_up':
        return TweenAnimationBuilder<Offset>(
          tween: Tween(begin: const Offset(0, 0.2), end: Offset.zero),
          duration: Duration(milliseconds: 500 + index * 100),
          curve: Curves.easeOut,
          builder: (context, offset, c) =>
              Transform.translate(offset: Offset(0, offset.dy * 100), child: c),
          child: child,
        );
      default:
        return child;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_layout == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // Helper to get config by element name
    MainMenuElementConfig? cfg(String name) => _layout!.firstWhere(
      (e) => e.element == name,
      orElse: () => MainMenuElementConfig(
        element: name,
        x: 0.5,
        y: 0.5,
        width: 200,
        height: 48,
        animationType: 'fade_in',
      ),
    );
    final logoCfg = cfg('logo')!;
    final storyCfg = cfg('story_button')!;
    final playCfg = cfg('play_button')!;
    final charCfg = cfg('character_button')!;
    final pvpCfg = cfg('local_pvp_button')!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('DuelTap')),
      body: Stack(
        children: [
          // Logo
          Positioned(
            left: logoCfg.x * screenWidth - logoCfg.width / 2,
            top: logoCfg.y * screenHeight - logoCfg.height / 2,
            width: logoCfg.width,
            height: logoCfg.height,
            child: _buildAnimated(
              animationType: logoCfg.animationType,
              index: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.black26, width: 2),
                ),
                child: const Center(
                  child: Text(
                    'LOGO',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Story Mode Button
          Positioned(
            left: storyCfg.x * screenWidth - storyCfg.width / 2,
            top: storyCfg.y * screenHeight - storyCfg.height / 2,
            width: storyCfg.width,
            height: storyCfg.height,
            child: _buildAnimated(
              animationType: storyCfg.animationType,
              index: 1,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const StorySaveSlotScreen(),
                    ),
                  );
                },
                child: const Text('Story Mode'),
              ),
            ),
          ),
          // Play Button
          Positioned(
            left: playCfg.x * screenWidth - playCfg.width / 2,
            top: playCfg.y * screenHeight - playCfg.height / 2,
            width: playCfg.width,
            height: playCfg.height,
            child: _buildAnimated(
              animationType: playCfg.animationType,
              index: 2,
              child: ElevatedButton(
                onPressed: () async {
                  final dummy = await loadDummyCharacter();
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
            ),
          ),
          // Character Button
          Positioned(
            left: charCfg.x * screenWidth - charCfg.width / 2,
            top: charCfg.y * screenHeight - charCfg.height / 2,
            width: charCfg.width,
            height: charCfg.height,
            child: _buildAnimated(
              animationType: charCfg.animationType,
              index: 3,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CharacterScreen()),
                  );
                },
                child: const Text('Character'),
              ),
            ),
          ),
          // 2P Local Button
          Positioned(
            left: pvpCfg.x * screenWidth - pvpCfg.width / 2,
            top: pvpCfg.y * screenHeight - pvpCfg.height / 2,
            width: pvpCfg.width,
            height: pvpCfg.height,
            child: _buildAnimated(
              animationType: pvpCfg.animationType,
              index: 4,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LocalPvpSelectScreen(),
                    ),
                  );
                },
                child: const Text('2P Local'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
