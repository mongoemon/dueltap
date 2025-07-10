import 'package:flutter/material.dart';

class DebugPanel extends StatelessWidget {
  final List<String> debugLog;
  const DebugPanel({super.key, required this.debugLog});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 8,
      bottom: 8,
      child: Container(
        width: 320,
        height: 180,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView(
          children: debugLog
              .map((e) => Text(e, style: const TextStyle(color: Colors.white, fontSize: 12)))
              .toList(),
        ),
      ),
    );
  }
}
