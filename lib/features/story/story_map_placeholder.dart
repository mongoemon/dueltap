import 'package:flutter/material.dart';

class StoryMapPlaceholder extends StatelessWidget {
  const StoryMapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Story Map')),
      body: const Center(
        child: Text('Map Placeholder - Story Mode Coming Soon!', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
