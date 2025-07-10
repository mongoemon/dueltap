import 'package:flutter/material.dart';
import '../character/character_select_data.dart';
import 'story_map_placeholder.dart';

class StorySaveSlotScreen extends StatefulWidget {
  const StorySaveSlotScreen({super.key});

  @override
  State<StorySaveSlotScreen> createState() => _StorySaveSlotScreenState();
}

class _StorySaveSlotScreenState extends State<StorySaveSlotScreen> {
  // In-memory save slot info for demo
  final List<_SaveSlotInfo?> _slots = List.filled(3, null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Save Slot')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: _slots[i] == null
                    ? ElevatedButton(
                        onPressed: () async {
                          final characters = await loadCharacterPrototypes();
                          final selected = await Navigator.of(context).push<_SaveSlotInfo>(
                            MaterialPageRoute(
                              builder: (_) => _StoryCharacterSelectScreen(slot: i, onSelected: (c) {
                                final now = DateTime.now();
                                Navigator.of(context).pop(_SaveSlotInfo(
                                  name: c.name,
                                  job: c.charClass.toString().split('.').last,
                                  level: c.level,
                                  image: null, // Placeholder for image
                                  timestamp: now,
                                ));
                              }),
                            ),
                          );
                          if (selected != null) {
                            setState(() => _slots[i] = selected);
                          }
                        },
                        child: Text('Save Slot ${i + 1} (Empty)'),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const StoryMapPlaceholder(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[200],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(child: Text(_slots[i]!.name[0])),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_slots[i]!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Job: ${_slots[i]!.job}'),
                                Text('Level: ${_slots[i]!.level}'),
                                Text('Saved: ${_slots[i]!.timestamp.toLocal().toString().substring(0, 19)}'),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SaveSlotInfo {
  final String name;
  final String job;
  final int level;
  final dynamic image; // Placeholder for image asset
  final DateTime timestamp;
  _SaveSlotInfo({required this.name, required this.job, required this.level, required this.image, required this.timestamp});
}

class _StoryCharacterSelectScreen extends StatelessWidget {
  final int slot;
  final void Function(dynamic) onSelected;
  const _StoryCharacterSelectScreen({required this.slot, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: loadCharacterPrototypes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final characters = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: Text('Select Character (Slot ${slot + 1})')),
          body: ListView.builder(
            itemCount: characters.length,
            itemBuilder: (context, idx) {
              final c = characters[idx];
              return ListTile(
                leading: CircleAvatar(child: Text(c.name[0])),
                title: Text(c.name),
                subtitle: Text('Job: ${c.charClass.toString().split('.').last}, Level: ${c.level}'),
                onTap: () => onSelected(c),
              );
            },
          ),
        );
      },
    );
  }
}
