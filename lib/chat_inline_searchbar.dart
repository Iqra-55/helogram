import 'package:flutter/material.dart';
import 'apptheme.dart';
import 'searchBar.dart';

class ChatSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color iconColor;
  final TextEditingController controller;
  final VoidCallback onBack;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String query;

  const ChatSearchAppBar({
    Key? key,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.iconColor,
    required this.controller,
    required this.onBack,
    required this.onChanged,
    required this.onClear,
    required this.query,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = isDark ? Colors.white : Colors.black;

    return AppBar(
      backgroundColor: isDark
          ? AppTheme.darkBackground.withOpacity(0.9)
          : AppTheme.lightBackground.withOpacity(0.9),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: effectiveIconColor, size: 26),
        onPressed: onBack,
      ),
      title: TextField(
        controller: controller,
        autofocus: true,
        style: TextStyle(
          color: textPrimary,
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(
            color: textSecondary,
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: onChanged,
      ),
      actions: [
        if (query.isNotEmpty)
          IconButton(
            icon: Icon(Icons.clear, color: effectiveIconColor, size: 26),
            onPressed: onClear,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ChatSelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;
  final Color textPrimary;
  final Color bgColor;
  final Color iconColor;
  final int selectedCount;
  final VoidCallback onClose;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final VoidCallback onMore;

  const ChatSelectionAppBar({
    Key? key,
    required this.isDark,
    required this.textPrimary,
    required this.bgColor,
    required this.iconColor,
    required this.selectedCount,
    required this.onClose,
    required this.onPin,
    required this.onArchive,
    required this.onDelete,
    required this.onMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = isDark ? Colors.white : Colors.black;

    return AppBar(
      backgroundColor: isDark ? bgColor.withOpacity(0.9) : AppTheme.lightBackground.withOpacity(0.95),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: effectiveIconColor, size: 26),
        onPressed: onClose,
      ),
      title: Text(
        '$selectedCount selected',
        style: TextStyle(
          color: textPrimary,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.push_pin_outlined, color: effectiveIconColor, size: 24),
          onPressed: onPin,
        ),
        IconButton(
          icon: Icon(Icons.archive_outlined, color: effectiveIconColor, size: 24),
          onPressed: onArchive,
        ),
        IconButton(
          icon: Icon(Icons.delete_outline, color: isDark ? effectiveIconColor : Colors.redAccent, size: 24),
          onPressed: onDelete,
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: effectiveIconColor, size: 24),
          onPressed: onMore,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ChatTransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String receiverName;
  final String? receiverAvatar;
  final bool isTyping;
  final bool isUserOnline;
  final Color textPrimary;
  final Color textSecondary;
  final Color primaryColor;
  final bool isDark;
  final Color iconColor;
  final List<Color> avatarBg;
  final Color avatarIconColor;
  final Color subtitleLight;
  final Brightness wallpaperBrightness;
  final VoidCallback onBack;
  final VoidCallback onVideoCall;
  final VoidCallback onVoiceCall;
  final VoidCallback onMenu;
  final VoidCallback onSearch;

  const ChatTransparentAppBar({
    Key? key,
    required this.receiverName,
    this.receiverAvatar,
    required this.isTyping,
    required this.isUserOnline,
    required this.textPrimary,
    required this.textSecondary,
    required this.primaryColor,
    required this.isDark,
    required this.iconColor,
    required this.avatarBg,
    required this.avatarIconColor,
    required this.subtitleLight,
    required this.wallpaperBrightness,
    required this.onBack,
    required this.onVideoCall,
    required this.onVoiceCall,
    required this.onMenu,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = wallpaperBrightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: kToolbarHeight,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: effectiveIconColor, size: 26),
        onPressed: onBack,
      ),
      title: Row(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: avatarBg,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 21,
                  backgroundColor: Colors.transparent,
                  backgroundImage: receiverAvatar != null
                      ? NetworkImage(receiverAvatar!)
                      : null,
                  child: receiverAvatar == null
                      ? Icon(Icons.person, color: avatarIconColor, size: 24)
                      : null,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isUserOnline ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receiverName,
                  style: TextStyle(
                    color: effectiveIconColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isTyping ? 'typing...' : 'Active Now',
                  style: TextStyle(
                    color: isTyping
                        ? primaryColor
                        : (wallpaperBrightness == Brightness.dark
                            ? subtitleLight
                            : Colors.grey.shade600),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.videocam, color: effectiveIconColor, size: 26),
          onPressed: onVideoCall,
        ),
        IconButton(
          icon: Icon(Icons.call, color: effectiveIconColor, size: 26),
          onPressed: onVoiceCall,
        ),
        // 👇 SEARCH ICON — ab three dots ke bilkul paas
        IconButton(
          icon: Icon(Icons.search, color: effectiveIconColor, size: 26),
          onPressed: onSearch,
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: effectiveIconColor, size: 26),
          onPressed: onMenu,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ============================================
// CHAT INLINE SEARCH — Theme-aware background
// ============================================
class ChatInlineSearch extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onBack;
  final VoidCallback onClear;

  const ChatInlineSearch({
    Key? key,
    required this.isDark,
    required this.controller,
    required this.onChanged,
    required this.onBack,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Theme-aware colors — dark/light dono modes ke liye
    final bgColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final searchBarColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.05);
    final textColor = isDark ? Colors.white : Colors.black87;
    final iconColor = isDark ? Colors.white70 : Colors.black54;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              surface: searchBarColor,
              onSurface: textColor,
            ),
      ),
      child: AppBar(
        backgroundColor: bgColor.withOpacity(0.95),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leadingWidth: 48,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor, size: 26),
          onPressed: onBack,
        ),
        title: SettingsSearchBar(
          hintText: 'Search messages...',
          controller: controller,
          onChanged: onChanged,
          onClose: onClear,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}