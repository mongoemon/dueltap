import 'package:flutter/material.dart';

class ExhaustGauge extends StatelessWidget {
  final int value;
  final int maxValue;
  final bool isExhausted;
  const ExhaustGauge({super.key, required this.value, required this.maxValue, required this.isExhausted});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 120,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0.0,
              end: value / maxValue,
            ),
            duration: const Duration(milliseconds: 400),
            builder: (context, val, child) {
              return LinearProgressIndicator(
                value: val,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
              );
            },
          ),
        ),
        Text('Exhaust: $value/$maxValue'),
        if (isExhausted)
          const Text('Exhaust', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
