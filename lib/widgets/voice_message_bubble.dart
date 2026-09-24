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
    final isVoice = msg['type'] == 'voice';

    // 👇 THEME COLOR SE BUBBLE BANAO
    Widget content;
    if (isVoice && voiceWidget != null) {
      content = voiceWidget!;
    } else {
      content = _buildTextBubble();
    }

    // Selection overlay
    if (isSelected) {
      content = Container(
        foregroundDecoration: BoxDecoration(
          color: primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: primaryColor, width: 2),
        ),
        child: content,
      );
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            left: isMe ? 60 : 12,
            right: isMe ? 12 : 60,
            top: 4,
            bottom: 4,
          ),
          child: isVoice
              ? content
              : Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    content,
                    const SizedBox(height: 2),
                    _buildMetaRow(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTextBubble() {
    final bgColor = isMe ? myBubbleColor : otherBubbleColor;
    final txtColor = isMe ? myTextColor : otherTextColor;
    final messageText = msg['message']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
      ),
      child: _buildMessageText(messageText, txtColor),
    );
  }

  Widget _buildMessageText(String text, Color textColor) {
    if (!isMatch || searchQuery.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontFamily: 'Poppins',
          height: 1.3,
        ),
      );
    }

    // Search highlight logic
    final lowerText = text.toLowerCase();
    final lowerQuery = searchQuery.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        if (start < text.length) {
          spans.add(TextSpan(
            text: text.substring(start),
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontFamily: 'Poppins',
            ),
          ));
        }
        break;
      }

      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontFamily: 'Poppins',
          ),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + lowerQuery.length),
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontFamily: 'Poppins',
          backgroundColor: searchHighlightColor,
          fontWeight: FontWeight.w600,
        ),
      ));

      start = index + lowerQuery.length;
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildMetaRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formattedTime,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white38 : Colors.black38,
            fontFamily: 'Poppins',
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          Icon(
            isRead ? Icons.done_all : Icons.done,
            size: 14,
            color: isRead
                ? (isDark ? Colors.blue.shade300 : Colors.blue)
                : (isDark ? Colors.white38 : Colors.black38),
          ),
        ],
      ],
    );
  }
}