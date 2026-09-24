import 'package:flutter/material.dart';
import '../apptheme.dart';

class ChatSearchSheet extends StatefulWidget {
  final String receiverName;

  const ChatSearchSheet({
    Key? key,
    required this.receiverName,
  }) : super(key: key);

  @override
  State<ChatSearchSheet> createState() => _ChatSearchSheetState();
}

class _ChatSearchSheetState extends State<ChatSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _dummyResults = [
    {'message': 'Assalam-o-Alaikum! Kaise ho?', 'date': 'Today', 'isMe': false},
    {'message': 'Walaikum Assalam! Main theek hoon.', 'date': 'Today', 'isMe': true},
    {'message': 'HeloGram app kaisi lag rahi hai?', 'date': 'Today', 'isMe': false},
    {'message': 'Bohat achi! Dark theme WhatsApp jaisi hai.', 'date': 'Today', 'isMe': true},
    {'message': 'Wah! Mujhe bhi try karni hai.', 'date': 'Today', 'isMe': false},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final textPrimary = isDark ? AppTheme.darkLightText : AppTheme.lightDarkText;
    final textSecondary = isDark ? AppTheme.darkNavInactive : AppTheme.lightNavInactive;
    final textMuted = isDark
        ? AppTheme.darkNavInactive.withOpacity(0.6)
        : AppTheme.lightNavInactive.withOpacity(0.6);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Search in Chat',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Search Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkBackground.withOpacity(0.6)
                        : AppTheme.lightSurface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.06),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(
                      color: textPrimary,
                      fontFamily: 'Poppins',
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search messages...',
                      hintStyle: TextStyle(
                        color: textMuted,
                        fontFamily: 'Poppins',
                        fontSize: 15,
                      ),
                      prefixIcon: Icon(Icons.search, color: textSecondary, size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: textSecondary, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              Divider(
                color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
                height: 1,
              ),
              // Results
              Expanded(
                child: _searchController.text.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, color: textMuted, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'Search for messages',
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 15,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: _dummyResults.length,
                        itemBuilder: (context, index) {
                          final result = _dummyResults[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkBackground.withOpacity(0.5)
                                  : AppTheme.lightBackground.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.black.withOpacity(0.04),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result['message'],
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      result['isMe'] ? 'You' : widget.receiverName,
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    Text(
                                      result['date'],
                                      style: TextStyle(
                                        color: textMuted,
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
