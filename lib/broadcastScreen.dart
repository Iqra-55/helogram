import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <--- Import for date formatting

class BroadcastListScreen extends StatelessWidget {
  const BroadcastListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Current month aur dates fetch karne ka logic
    final now = DateTime.now();
    final monthName = DateFormat('MMMM').format(now); // E.g., July
    
    // Month ki pehli aur aakhri date nikalna
    final firstDay = DateFormat('dd MMM').format(DateTime(now.year, now.month, 1));
    final lastDay = DateFormat('dd MMM').format(DateTime(now.year, now.month + 1, 0));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Broadcasts'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(monthName, style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('$firstDay - $lastDay', style: TextStyle(color: colorScheme.onSurface, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            // Baki ka code waisa hi rahega...
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0\nSent', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18)),
                Text('50\nRemaining', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.right),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.0,
              backgroundColor: colorScheme.surface,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: TextStyle(fontFamily: 'Poppins', color: colorScheme.onSurface.withOpacity(0.7)),
                children: [
                  const TextSpan(text: 'Send up to 50 broadcasts per month. '),
                  TextSpan(text: 'Learn more', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(thickness: 1),
            ),
            Expanded(
              child: Center(
                child: Text('No broadcasts', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: theme.floatingActionButtonTheme.backgroundColor ?? colorScheme.primary,
        foregroundColor: theme.floatingActionButtonTheme.foregroundColor ?? Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}