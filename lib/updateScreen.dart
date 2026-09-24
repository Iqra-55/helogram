import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';  // ThemeProvider ki file

class UpdatesScreen extends StatelessWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Updates'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Updates Screen',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}