import 'package:flutter/material.dart';
import '../apptheme.dart';

class ChatSelectionBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final VoidCallback onPin;
  final VoidCallback onMute;
  final VoidCallback onArchive;

  const ChatSelectionBar({
    super.key,
    required this.selectedCount,
    required this.onCancel,
    required this.onDelete,
    required this.onPin,
    required this.onMute,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = isDark ? AppTheme.darkAppBarBg : AppTheme.lightAppBarBg;
    final textPrimary = isDark ? AppTheme.darkLightText : AppTheme.lightDarkText;

    return AppBar(
      backgroundColor: appBarColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: textPrimary),
        onPressed: onCancel,
      ),
      title: Text('$selectedCount', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
      actions: [
        IconButton(icon: Icon(Icons.push_pin_outlined, color: textPrimary), onPressed: onPin),
        IconButton(icon: Icon(Icons.delete_outline, color: textPrimary), onPressed: onDelete),
        IconButton(icon: Icon(Icons.notifications_off_outlined, color: textPrimary), onPressed: onMute),
        IconButton(icon: Icon(Icons.archive_outlined, color: textPrimary), onPressed: onArchive),
        IconButton(icon: Icon(Icons.more_vert, color: textPrimary), onPressed: () {}),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}