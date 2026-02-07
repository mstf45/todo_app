import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Text(
          'Help & Support Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}