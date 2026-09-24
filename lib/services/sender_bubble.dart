import 'package:flutter/material.dart';
import 'chat_theme_service.dart';

class SenderBubble extends StatelessWidget {
  final String message;
  final String time;
  final String? chatId;
  final Color? color;

  const SenderBubble({
    Key? key,
    required this.message,
    required this.time,
    this.chatId,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Agar direct color pass kiya hai
    if (color != null) {
      return _buildBubble(color!);
    }

    // Default theme se color lo
    final defaultTheme = ChatThemeService.getDefaultTheme(isDark);
    final defaultColor = defaultTheme['bubbleColor'] as Color;

    // Agar chatId nahi hai toh default
    if (chatId == null || chatId!.isEmpty) {
      return _buildBubble(defaultColor);
    }

    // Saved theme se fetch karo
    return FutureBuilder<Map<String, dynamic>?>(
      future: ChatThemeService.getActiveTheme(chatId!),
      builder: (context, snapshot) {
        final themeColor = snapshot.data?['bubbleColor'] as Color?;
        final bubbleColor = themeColor ?? defaultColor;
        return _buildBubble(bubbleColor);
      },
    );
  }

  Widget _buildBubble(Color bubbleColor) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 60, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'Poppins',
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}