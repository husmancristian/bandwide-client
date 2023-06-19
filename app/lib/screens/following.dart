import 'package:flutter/material.dart';

class Following extends StatelessWidget {
  const Following({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.favorite),
      label: const Text('Following'),
    );
  }
}
