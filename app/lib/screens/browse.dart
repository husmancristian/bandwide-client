import 'package:flutter/material.dart';

class Browse extends StatelessWidget {
  const Browse({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'BROWSE',
          style: style,
        ),
      ),
    );
  }
}
