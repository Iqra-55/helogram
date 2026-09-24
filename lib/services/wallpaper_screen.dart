import 'package:flutter/material.dart';
import '../apptheme.dart';
import 'chat_theme_service.dart';
import 'wallpaper_preview_screen.dart';

class WallpaperScreen extends StatefulWidget {
  final String chatId;
  final String currentWallpaper;
  final String contactName;  // <-- New parameter

  const WallpaperScreen({
    Key? key,
    required this.chatId,
    required this.currentWallpaper,
    required this.contactName,  // <-- Required
  }) : super(key: key);

  @override
  State<WallpaperScreen> createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen> {
  late String _selectedWallpaper;

  @override
  void initState() {
    super.initState();
    _selectedWallpaper = widget.currentWallpaper;
  }

  void _selectWallpaper(String id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WallpaperPreviewScreen(
          chatId: widget.chatId,
          contactName: widget.contactName,
          wallpaperId: id,
        ),
      ),
    );
    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  BoxDecoration _getPreviewDecoration(Map<String, dynamic> wp) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      image: DecorationImage(
        image: AssetImage(wp['assetPath']),
        fit: BoxFit.cover,
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

    final wallpapers = ChatThemeService.getWallpapers(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkAppBarBg : AppTheme.lightAppBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Wallpaper',
              style: TextStyle(
                color: textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              widget.contactName,  // <-- Contact name dikh raha hai
              style: TextStyle(
                color: textSecondary,
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () async {
              await ChatThemeService.clearWallpaper(widget.chatId);
              if (mounted) Navigator.pop(context, {'id': 'default'});
            },
            child: Text(
              'Remove',
              style: TextStyle(
                color: iconColor,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: wallpapers.length,
    
        itemBuilder: (context, index) {
          final wp = wallpapers[index];
          final isSelected = _selectedWallpaper == wp['id'];

          return GestureDetector(
            onTap: () => _selectWallpaper(wp['id']),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  height: 110,
                  curve: Curves.easeOut,
                  decoration: _getPreviewDecoration(wp).copyWith(
                    border: isSelected
                        ? Border.all(
                            color: isDark ? Colors.white : Colors.black,
                            width: 2.5,
                          )
                        : Border.all(
                            color: textPrimary.withOpacity(0.08),
                            width: 1,
                          ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white : Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: isDark ? Colors.black : Colors.white,
                              size: 16,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  wp['name'],
                  style: TextStyle(
                    color: isSelected ? textPrimary : textSecondary,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}