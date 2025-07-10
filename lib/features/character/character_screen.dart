// CharacterScreen: Shows stats, skills, equipment
import 'package:flutter/material.dart';
import 'character_select_data.dart';
import '../../models/character.dart';
import '../combat/combat_screen.dart';
import '../combat/dummy_character.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  int selectedIndex = 0;

  late Future<List<Character>> _charactersFuture;

  @override
  void initState() {
    super.initState();
    _charactersFuture = loadCharacterPrototypes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Always reload characters when the screen is shown
    _charactersFuture = loadCharacterPrototypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Character')),
      body: FutureBuilder<List<Character>>(
        future: _charactersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final characters = snapshot.data!;
          final selected = characters[selectedIndex];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: characters.length,
                  itemBuilder: (context, index) {
                    final c = characters[index];
                    return GestureDetector(
                      onTap: () => setState(() => selectedIndex = index),
                      child: Card(
                        color: selectedIndex == index ? Colors.blue[100] : null,
                        child: SizedBox(
                          width: 140,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                c.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(c.charClass.name),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Stats:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'ATK: ${selected.attack}  DEF: ${selected.defense}  SPD: ${selected.speed}  STA: ${selected.stamina}',
              ),
              const SizedBox(height: 8),
              Text('Skills: ${selected.skills.map((s) => s.name).join(', ')}'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected ${selected.name}!')),
                  );
                },
                child: const Text('Confirm & Play'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Always reload dummy from CSV before battle
                  final dummy = await loadDummyCharacter();
                  // Always reload player from CSV before battle
                  final characters = await loadCharacterPrototypes();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CombatScreen(
                        player: characters[selectedIndex],
                        opponent: dummy,
                      ),
                    ),
                  );
                },
                child: const Text('Test Battle Mode'),
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Instructions & Parameters'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Parameter Explanations:'),
                            const SizedBox(height: 8),
                            const Text(
                              '• auto_attack: Power of automatic attacks (higher = more damage per auto-attack).',
                            ),
                            const Text(
                              '• tap_attack: Power of tap attacks (lower than auto_attack, for manual tapping).',
                            ),
                            const Text('• defense: Reduces incoming damage.'),
                            const Text(
                              '• speed: Increases chance to evade attacks.',
                            ),
                            const Text(
                              '• stamina: Increases auto-attack gauge fill rate.',
                            ),
                            const Text(
                              '• strength: Reduces incoming damage as a percentage.',
                            ),
                            const SizedBox(height: 16),
                            const Text('Skill Buttons & Effects:'),
                            const SizedBox(height: 8),
                            const Text(
                              '• Each character has unique skills, shown as buttons in battle. Tap a skill button to activate its effect. Skills have cooldowns (CD), shown on the button. When on cooldown, the button is disabled and shows remaining time.',
                            ),
                            const Text(
                              '• Some skills grant temporary buffs (e.g., speed up, damage reduction). Active buffs are displayed under your stats with remaining duration.',
                            ),
                            const Text(
                              '• Example buffs: "Shadow Strike" increases speed (evade chance) for 5 seconds. "Shield Wall" reduces all incoming damage for 5 seconds. Healing skills restore HP instantly.',
                            ),
                            const Text(
                              '• Visual feedback: Damage numbers appear in red, healing in blue, and "miss" for evasion. Buffs show as text with a timer.'),
                            const SizedBox(height: 16),
                            const Text('Character Skills:'),
                            const SizedBox(height: 8),
                            ...snapshot.data!.map(
                              (c) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${c.name}:',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (c.skills.isNotEmpty)
                                    ...c.skills.map(
                                      (s) => Text(
                                        '  - ${s.name}: ${s.description} (CD: ${s.cooldown}s)',
                                      ),
                                    )
                                  else
                                    const Text('  - No special skills'),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Instruction'),
              ),
            ],
          );
        },
      ),
    );
  }
}
