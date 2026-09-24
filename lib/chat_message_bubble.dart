import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  final bool isSelected;
  final bool isMatch;
  final String searchQuery;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isDark;
  final Color primaryColor;
  final Color searchHighlightColor;
  final Color myBubbleColor;
  final Color otherBubbleColor;
  final Color myTextColor;
  final Color otherTextColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color iconColor;
  final Widget? voiceWidget;
  final String formattedTime;
  final bool isRead;

  const ChatMessageBubble({
    Key? key,
    required this.msg,
    required this.isMe,
    required this.isSelected,
    required this.isMatch,
    required this.searchQuery,
    this.onTap,
    this.onLongPress,
    required this.isDark,
    required this.primaryColor,
    required this.searchHighlightColor,
    required this.myBubbleColor,
    required this.otherBubbleColor,
    required this.myTextColor,
    required this.otherTextColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.iconColor,
    this.voiceWidget,
    required this.formattedTime,
    required this.isRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? myBubbleColor : otherBubbleColor;
    final textColor = isMe ? myTextColor : otherTextColor;

    Widget content = voiceWidget ?? _buildTextContent(textColor);

    Widget bubble = Container(
      margin: EdgeInsets.only(
        left: isMe ? 60 : 12,
        right: isMe ? 12 : 60,
        top: 4,
        bottom: 4,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                content,
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 11,
                        color: textMuted,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        isRead ? Icons.done_all : Icons.done,
                        size: 14,
                        color: isRead ? primaryColor : textMuted,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Selection mode overlay (full bubble) — sirf selection k liye
    if (isSelected) {
      bubble = Container(
        foregroundDecoration: BoxDecoration(
          color: primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: primaryColor, width: 2),
        ),
        child: bubble,
      );
    }

    return bubble;
  }

  // ✅ SIRF WORDS HIGHLIGHT — pura message nahi
  Widget _buildTextContent(Color textColor) {
    final messageText = msg['message']?.toString() ?? '';

    if (searchQuery.isEmpty || !isMatch) {
      return Text(
        messageText,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontFamily: 'Poppins',
          height: 1.3,
        ),
      );
    }

    // ✅ RichText with only matching words highlighted
    return _HighlightText(
      text: messageText,
      query: searchQuery,
      baseStyle: TextStyle(
        color: textColor,
        fontSize: 15,
        fontFamily: 'Poppins',
        height: 1.3,
      ),
      highlightColor: searchHighlightColor,
      highlightTextColor: textColor,
    );
  }
}

// ============================================
// ✅ WORD-LEVEL HIGHLIGHT WIDGET
// ============================================
class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle baseStyle;
  final Color highlightColor;
  final Color highlightTextColor;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightColor,
    required this.highlightTextColor,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];

    int start = 0;
    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) break;

      // Normal text before match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: baseStyle,
        ));
      }

      // ✅ Highlighted match word
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: baseStyle.copyWith(
          backgroundColor: highlightColor,
          fontWeight: FontWeight.w700,
          color: highlightTextColor,
        ),
      ));

      start = index + query.length;
    }

    // Remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
