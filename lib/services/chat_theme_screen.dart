import 'package:flutter/material.dart';
import 'dart:ui';
import '../apptheme.dart';
import 'chat_theme_service.dart';
import '../chat_bubble_screen.dart';
import 'wallpaper_screen.dart';
import 'theme_preview_screen.dart';

class ChatThemeScreen extends StatefulWidget {
  final String chatId;
  final String contactName;

  const ChatThemeScreen({
    Key? key,
    required this.chatId,
    required this.contactName,
  }) : super(key: key);

  @override
  State<ChatThemeScreen> createState() => _ChatThemeScreenState();
}

class _ChatThemeScreenState extends State<ChatThemeScreen> {
  String? _selectedId;
  Color _currentBubbleColor = const Color(0xFF2E8B57);
  Color _currentReceiverBubbleColor = const Color(0xFF2A2D32);
  String _currentWallpaper = 'default';

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  // ✅ FIX: Har baar screen visible hone pe refresh karo
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    final currentId = await ChatThemeService.getThemeId(widget.chatId);
    final theme = await ChatThemeService.getActiveTheme(widget.chatId);
    final wallpaper = await ChatThemeService.getWallpaper(widget.chatId);
    
    // ✅ FIX: Direct wallpaper_settings se bhi read karo as backup
    final settings = await ChatThemeService.getWallpaperSettings(widget.chatId);
    
    if (mounted) {
      setState(() {
        _selectedId = currentId;
        _currentWallpaper = wallpaper;
        
        if (theme != null) {
          _currentBubbleColor = (theme['bubbleColor'] as Color?) ?? const Color(0xFF2E8B57);
          _currentReceiverBubbleColor = (theme['receiverBubbleColor'] as Color?) ?? const Color(0xFF2A2D32);
        }
        
        // ✅ FIX: Agar wallpaper_settings mein color hai, use woh override kare
        final senderVal = settings['senderBubbleColor'] as int?;
        final receiverVal = settings['receiverBubbleColor'] as int?;
        if (senderVal != null) _currentBubbleColor = Color(senderVal);
        if (receiverVal != null) _currentReceiverBubbleColor = Color(receiverVal);
      });
    }
  }

  // ✅ FIX: Color ko dono jagah save karo (old keys + wallpaper_settings)
  Future<void> _saveBubbleColor(bool isReceiver, Color color) async {
    if (isReceiver) {
      await ChatThemeService.saveReceiverBubbleColor(widget.chatId, color);
    } else {
      await ChatThemeService.saveBubbleColor(widget.chatId, color);
    }

    // wallpaper_settings bhi update karo taake ChatScreen bhi read kar sake
    final settings = Map<String, dynamic>.from(
      await ChatThemeService.getWallpaperSettings(widget.chatId),
    );
    settings[isReceiver ? 'receiverBubbleColor' : 'senderBubbleColor'] = color.value;
    await ChatThemeService.saveWallpaperSettings(widget.chatId, settings);
  }

  Future<void> _resetToDefault() async {
    await ChatThemeService.resetTheme(widget.chatId);
    await ChatThemeService.clearWallpaper(widget.chatId);
    await ChatThemeService.clearWallpaperSettings(widget.chatId);
    await _loadCurrent();
  }

  void _showResetMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: [
        PopupMenuItem<String>(
          value: 'reset',
          padding: EdgeInsets.zero,
          height: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 180,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A1A1A).withOpacity(0.95)
                      : const Color(0xFFFFFFFF).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.06),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.4)
                          : Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _resetToDefault();
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.restart_alt_rounded,
                            size: 18,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Reset to Default',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openThemePreview(Map<String, dynamic> theme) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final previousId = await ChatThemeService.getThemeId(widget.chatId);
    
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => ThemePreviewScreen(
          chatId: widget.chatId,
          theme: theme,
          isDark: isDark,
        ),
      ),
    );
    
    if (result != null && mounted) {
      final newId = await ChatThemeService.getThemeId(widget.chatId);
      if (newId != previousId) {
        await ChatThemeService.clearCustomColors(widget.chatId);
      }
      await _loadCurrent();
    }
  }

  Widget _buildThemeCard(Map<String, dynamic> theme) {
    final isSelected = _selectedId == theme['id'];

    return GestureDetector(
      onTap: () => _openThemePreview(theme),
      child: Container(
        width: 58,
        height: 76,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          gradient: theme['wallpaperType'] == 'gradient'
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: (theme['wallpaperColors'] as List).cast<Color>(),
                )
              : null,
          color: theme['wallpaperType'] == 'solid'
              ? theme['wallpaperColor'] as Color
              : null,
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned(
              top: 4,
              left: 4,
              right: 4,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: 18,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 15,
              left: 4,
              child: Container(
                width: 24,
                height: 8,
                decoration: BoxDecoration(
                  color: (theme['receiverBubbleColor'] as Color).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Positioned(
              top: 27,
              right: 4,
              child: Container(
                width: 26,
                height: 10,
                decoration: BoxDecoration(
                  color: theme['bubbleColor'] as Color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                bottom: 2,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.black, size: 9),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textPrimary = isDark ? AppTheme.darkLightText : Colors.black;
    final textSecondary = isDark ? AppTheme.darkNavInactive : Colors.black54;
    final iconColor = isDark ? Colors.white : Colors.black;
    final themes = ChatThemeService.getThemes(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkAppBarBg : AppTheme.lightAppBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chat theme',
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: false,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.more_vert, color: iconColor),
              onPressed: () => _showResetMenu(context),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                isDark ? 'Dark Themes' : 'Light Themes',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            SizedBox(
              height: 150,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 6,
                  childAspectRatio: 0.72,
                ),
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  return _buildThemeCard(themes[index]);
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Tap any theme to preview before applying.',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Customize',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            // ===== MY BUBBLE =====
            ListTile(
              leading: Icon(Icons.chat_bubble, color: iconColor, size: 22),
              title: Text(
                'My bubble',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Your messages',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _currentBubbleColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: textPrimary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: textSecondary, size: 20),
                ],
              ),
              onTap: () async {
                final defaultSender = ChatThemeService.getDefaultTheme(isDark)['bubbleColor'] as Color;
                final result = await Navigator.push<Color>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatBubbleScreen(
                      initialColor: _currentBubbleColor,
                      defaultColor: defaultSender,
                      chatId: widget.chatId,
                      isReceiver: false,
                    ),
                  ),
                );
                if (result != null && mounted) {
                  await _saveBubbleColor(false, result);
                  setState(() => _currentBubbleColor = result);
                }
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            // ===== THEIR BUBBLE =====
            ListTile(
              leading: Icon(Icons.chat_bubble_outline, color: iconColor, size: 22),
              title: Text(
                'Their bubble',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                "Other person's messages",
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _currentReceiverBubbleColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: textPrimary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: textSecondary, size: 20),
                ],
              ),
              onTap: () async {
                final defaultReceiver = ChatThemeService.getDefaultTheme(isDark)['receiverBubbleColor'] as Color;
                final result = await Navigator.push<Color>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatBubbleScreen(
                      initialColor: _currentReceiverBubbleColor,
                      defaultColor: defaultReceiver,
                      chatId: widget.chatId,
                      isReceiver: true,
                    ),
                  ),
                );
                if (result != null && mounted) {
                  await _saveBubbleColor(true, result);
                  setState(() => _currentReceiverBubbleColor = result);
                }
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            // ===== WALLPAPER =====
            ListTile(
              leading: Icon(Icons.wallpaper, color: iconColor, size: 22),
              title: Text(
                'Wallpaper',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Chat background',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: ChatThemeService.getWallpaperDecorationById(_currentWallpaper, isDark).copyWith(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: textPrimary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: textSecondary, size: 20),
                ],
              ),
              onTap: () async {
                await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WallpaperScreen(
                      chatId: widget.chatId,
                      currentWallpaper: _currentWallpaper,
                      contactName: widget.contactName,
                    ),
                  ),
                );
                if (mounted) {
                  await _loadCurrent();
                }
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ],
        ),
      ),
    );
  }
}