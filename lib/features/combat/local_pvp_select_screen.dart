import 'package:flutter/material.dart';
import '../character/character_select_data.dart';
import 'combat_screen.dart';

class LocalPvpSelectScreen extends StatefulWidget {
  const LocalPvpSelectScreen({super.key});

  @override
  State<LocalPvpSelectScreen> createState() => _LocalPvpSelectScreenState();
}

class _LocalPvpSelectScreenState extends State<LocalPvpSelectScreen> {
  int? _player1Index;
  int? _player2Index;
  List? _characters;

  @override
  void initState() {
    super.initState();
    loadCharacterPrototypes().then((chars) => setState(() => _characters = chars));
  }

  @override
  Widget build(BuildContext context) {
    if (_characters == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('2P Local - Select Characters')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Player 1: Select your character'),
          _characterPicker(_player1Index, (idx) => setState(() => _player1Index = idx)),
          const Divider(),
          const Text('Player 2: Select your character'),
          _characterPicker(_player2Index, (idx) => setState(() => _player2Index = idx)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _player1Index != null && _player2Index != null
                ? () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => CombatScreen(
                          player: _characters![_player1Index!],
                          opponent: _characters![_player2Index!],
                        ),
                      ),
                    );
                  }
                : null,
            child: const Text('Start Battle'),
          ),
        ],
      ),
    );
  }

  Widget _characterPicker(int? selected, void Function(int) onSelect, {int? disabled}) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _characters!.length,
        itemBuilder: (context, idx) {
          final c = _characters![idx];
          return GestureDetector(
            onTap: () => onSelect(idx),
            child: Card(
              color: selected == idx ? Colors.blue[100] : null,
              child: SizedBox(
                width: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(child: Text(c.name[0])),
                    Text(c.name),
                    Text(c.charClass.toString().split('.').last),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
