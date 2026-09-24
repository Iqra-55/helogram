import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../apptheme.dart';
import 'chat_theme_service.dart';
import '../chat_bubble_screen.dart';

class WallpaperPreviewScreen extends StatefulWidget {
  final String chatId;
  final String wallpaperId;
  final String contactName;

  const WallpaperPreviewScreen({
    Key? key,
    required this.chatId,
    required this.wallpaperId,
    required this.contactName,
  }) : super(key: key);

  @override
  State<WallpaperPreviewScreen> createState() => _WallpaperPreviewScreenState();
}

class _WallpaperPreviewScreenState extends State<WallpaperPreviewScreen> {
  late Map<String, dynamic> _wallpaper;
  late bool _systemIsDark;

  double _blur = 0;
  double _brightness = 0;
  Color _tintColor = Colors.transparent;
  bool _isDarkTheme = false;
  late String _selectedWallpaperId;

  Color? _customSenderBubbleColor;
  Color? _customReceiverBubbleColor;

  final DraggableScrollableController _sheetController = DraggableScrollableController();

  final List<Color> _tintColors = [
    Colors.transparent,
    const Color(0xFFFF80AB),
    const Color(0xFFF8BBD0),
    const Color(0xFFB2FF59),
    const Color(0xFFE1BEE7),
    const Color(0xFF80D8FF),
  ];

  @override
  void initState() {
    super.initState();
    _systemIsDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    _isDarkTheme = _systemIsDark;
    _selectedWallpaperId = widget.wallpaperId;
    final wp = ChatThemeService.getWallpaperById(widget.wallpaperId, _systemIsDark);
    _wallpaper = wp ?? {
      'id': widget.wallpaperId,
      'name': 'Unknown',
      'type': 'image',
      'assetPath': '',
      'brightness': 'mixed',
      'description': 'No description available',
    };
    _loadSavedSettings();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedSettings() async {
    final settings = await ChatThemeService.getWallpaperSettings(widget.chatId);

    if (mounted) {
      setState(() {
        _blur = (settings['blur'] as num?)?.toDouble() ?? 0.0;
        _brightness = (settings['brightness'] as num?)?.toDouble() ?? 0.0;
        _tintColor = Color((settings['tint'] as int?) ?? Colors.transparent.value);
        _isDarkTheme = (settings['darkTheme'] as bool?) ?? _systemIsDark;

        // Load custom bubble colors from settings
        final senderVal = settings['senderBubbleColor'] as int?;
        final receiverVal = settings['receiverBubbleColor'] as int?;
        if (senderVal != null) _customSenderBubbleColor = Color(senderVal);
        if (receiverVal != null) _customReceiverBubbleColor = Color(receiverVal);
      });
    }
  }

  Future<void> _applyWallpaper() async {
    // Save wallpaper and clear any existing theme (mutual exclusivity)
    await ChatThemeService.resetTheme(widget.chatId);

    final result = {
      'id': _selectedWallpaperId,
      'blur': _blur,
      'brightness': _brightness,
      'tint': _tintColor.value,
      'darkTheme': _isDarkTheme,
      'senderBubbleColor': _customSenderBubbleColor?.value,
      'receiverBubbleColor': _customReceiverBubbleColor?.value,
    };
    await ChatThemeService.saveWallpaper(widget.chatId, _selectedWallpaperId);
    await ChatThemeService.saveWallpaperSettings(widget.chatId, result);

    if (mounted) {
      Navigator.pop(context, result);
    }
  }

  Map<String, dynamic> get _activeTheme {
    final theme = ChatThemeService.getDefaultTheme(_isDarkTheme);
    // Override with custom colors if set
    if (_customSenderBubbleColor != null) {
      theme['bubbleColor'] = _customSenderBubbleColor;
    }
    if (_customReceiverBubbleColor != null) {
      theme['receiverBubbleColor'] = _customReceiverBubbleColor;
    }
    return theme;
  }

  Color get _senderBubbleColor => _customSenderBubbleColor ?? (_activeTheme['bubbleColor'] as Color);
  Color get _receiverBubbleColor => _customReceiverBubbleColor ?? (_activeTheme['receiverBubbleColor'] as Color);

  Color get _senderTextColor => Colors.white;

  Color get _receiverTextColor {
    final lum = _receiverBubbleColor.computeLuminance();
    return lum > 0.5 ? Colors.black87 : Colors.white;
  }

  Color get _chatAppBarColor => _isDarkTheme
      ? const Color(0xFF1F2C34)
      : const Color(0xFFF0F2F5);

  Color get _chatDateChipColor => _isDarkTheme
      ? const Color(0xFF1F2C34)
      : const Color(0xFFE1F3FB);

  void _selectWallpaper(String id) {
    final wp = ChatThemeService.getWallpaperById(id, _isDarkTheme);
    if (wp != null) {
      setState(() {
        _selectedWallpaperId = id;
        _wallpaper = wp;
      });
    }
  }

  Future<void> _openBubbleScreen(bool isReceiver) async {
    final defaultColor = isReceiver
        ? _activeTheme['receiverBubbleColor'] as Color
        : _activeTheme['bubbleColor'] as Color;
    final currentColor = isReceiver
        ? (_customReceiverBubbleColor ?? defaultColor)
        : (_customSenderBubbleColor ?? defaultColor);

    final result = await Navigator.push<Color>(
      context,
      MaterialPageRoute(
        builder: (context) => ChatBubbleScreen(
          initialColor: currentColor,
          defaultColor: defaultColor,
          chatId: widget.chatId,
          isReceiver: isReceiver,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (isReceiver) {
          _customReceiverBubbleColor = result;
        } else {
          _customSenderBubbleColor = result;
        }
      });
    }
  }

  void _toggleSheet() {
    if (_sheetController.isAttached) {
      final currentSize = _sheetController.size;
      if (currentSize > 0.2) {
        _sheetController.animateTo(
          0.08,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _sheetController.animateTo(
          0.62,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  Widget _buildBubblePreview({
    required Color color,
    required bool isSender,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isSender ? const Radius.circular(12) : const Radius.circular(3),
            bottomRight: isSender ? const Radius.circular(3) : const Radius.circular(12),
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.edit,
            size: 12,
            color: color.computeLuminance() > 0.5 ? Colors.black45 : Colors.white70,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkTheme ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textPrimary = _isDarkTheme ? AppTheme.darkLightText : Colors.black;
    final iconColor = _isDarkTheme ? Colors.white : Colors.black;

    final wallpapers = ChatThemeService.getWallpapers(_isDarkTheme);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: _isDarkTheme ? AppTheme.darkAppBarBg : AppTheme.lightAppBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Wallpaper Preview',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: _applyWallpaper,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _isDarkTheme
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFF00A884),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isDarkTheme
                      ? Colors.white.withOpacity(0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ===== FULL SCREEN WALLPAPER =====
          Image.asset(
            _wallpaper['assetPath'],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          if (_tintColor != Colors.transparent)
            Container(color: _tintColor.withOpacity(0.25)),
          Container(
            color: _brightness > 0
                ? Colors.black.withOpacity(_brightness * 0.6)
                : Colors.white.withOpacity((-_brightness).clamp(0.0, 0.6) * 0.6),
          ),
          if (_blur > 0)
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _blur * 15,
                sigmaY: _blur * 15,
              ),
              child: Container(color: Colors.transparent),
            ),

          // ===== CHAT PREVIEW =====
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    color: _chatAppBarColor.withOpacity(0.9),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back, size: 22, color: _isDarkTheme ? Colors.white : Colors.black),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.pink.shade200,
                          child: Text(
                            widget.contactName.isNotEmpty
                                ? widget.contactName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.contactName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                  color: _isDarkTheme ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                'Online',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isDarkTheme ? Colors.green.shade400 : Colors.green,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.videocam, size: 22, color: _isDarkTheme ? Colors.white : Colors.black),
                        const SizedBox(width: 16),
                        Icon(Icons.call, size: 22, color: _isDarkTheme ? Colors.white : Colors.black),
                        const SizedBox(width: 16),
                        Icon(Icons.more_vert, size: 22, color: _isDarkTheme ? Colors.white : Colors.black),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _chatDateChipColor.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: _isDarkTheme ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(right: 60),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _receiverBubbleColor.withOpacity(0.95),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Swipe left or right to preview\nmore wallpapers ✨',
                                  style: TextStyle(
                                    color: _receiverTextColor,
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '3:45 PM',
                                  style: TextStyle(
                                    color: _receiverTextColor.withOpacity(0.6),
                                    fontSize: 10,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(left: 60),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _senderBubbleColor.withOpacity(0.95),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Only your ${widget.contactName} chat\nwill change. Only you see your\nchat themes.',
                                  style: TextStyle(
                                    color: _senderTextColor,
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '3:45 PM',
                                      style: TextStyle(
                                        color: _senderTextColor.withOpacity(0.7),
                                        fontSize: 10,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.done_all,
                                      size: 14,
                                      color: _senderTextColor.withOpacity(0.8),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),

          // ===== DRAGGABLE BOTTOM SHEET =====
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.62,
            minChildSize: 0.08,
            maxChildSize: 0.72,
            snap: true,
            snapSizes: const [0.08, 0.62, 0.72],
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isDarkTheme
                          ? const Color(0xFF1F2C34).withOpacity(0.35)
                          : Colors.white.withOpacity(0.40),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border.all(
                        color: _isDarkTheme
                            ? Colors.white.withOpacity(0.15)
                            : Colors.white.withOpacity(0.5),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      children: [
                        // Drag handle
                        GestureDetector(
                          onTap: _toggleSheet,
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 8, bottom: 4),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: _isDarkTheme
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.black.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Blur Slider
                        _buildSliderRow(
                          icon: Icons.water_drop_outlined,
                          label: 'Blur',
                          value: _blur,
                          onChanged: (v) => setState(() => _blur = v),
                          iconColor: iconColor,
                          textColor: textPrimary,
                        ),
                        const SizedBox(height: 6),
                        // Brightness Slider
                        _buildSliderRow(
                          icon: Icons.wb_sunny_outlined,
                          label: 'Brightness',
                          value: _brightness,
                          min: -1,
                          max: 1,
                          onChanged: (v) => setState(() => _brightness = v),
                          iconColor: iconColor,
                          textColor: textPrimary,
                        ),
                        const SizedBox(height: 16),
                        // Tint Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Icon(Icons.color_lens_outlined, size: 20, color: iconColor),
                              const SizedBox(width: 12),
                              Text(
                                'Tint',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(width: 16),
                              ..._tintColors.map((color) {
                                final isSelected = _tintColor == color;
                                return GestureDetector(
                                  onTap: () => setState(() => _tintColor = color),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? (_isDarkTheme ? Colors.white : Colors.black)
                                            : (color == Colors.transparent 
                                                ? (_isDarkTheme ? Colors.white38 : Colors.black26) 
                                                : Colors.transparent),
                                        width: 2.5,
                                      ),
                                      boxShadow: isSelected && color != Colors.transparent
                                          ? [
                                              BoxShadow(
                                                color: color.withOpacity(0.5),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: isSelected
                                        ? Icon(
                                            Icons.check,
                                            size: 14,
                                            color: color == Colors.transparent
                                                ? (_isDarkTheme ? Colors.white : Colors.black)
                                                : (color.computeLuminance() > 0.5
                                                    ? Colors.black
                                                    : Colors.white),
                                          )
                                        : (color == Colors.transparent
                                            ? Icon(
                                                Icons.block,
                                                size: 12,
                                                color: _isDarkTheme ? Colors.white54 : Colors.black45,
                                              )
                                            : null),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Theme Toggle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Icon(Icons.nightlight_round, size: 20, color: iconColor),
                              const SizedBox(width: 12),
                              Text(
                                'Theme',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: _isDarkTheme
                                      ? Colors.white.withOpacity(0.08)
                                      : Colors.black.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _isDarkTheme
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.black.withOpacity(0.08),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _themeButton('Light', !_isDarkTheme, iconColor),
                                    _themeButton('Dark', _isDarkTheme, iconColor),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // BUBBLES SECTION
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 20, color: iconColor),
                              const SizedBox(width: 12),
                              Text(
                                'Bubbles',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const Spacer(),
                              _buildBubblePreview(
                                color: _senderBubbleColor,
                                isSender: true,
                                onTap: () => _openBubbleScreen(false),
                              ),
                              const SizedBox(width: 10),
                              _buildBubblePreview(
                                color: _receiverBubbleColor,
                                isSender: false,
                                onTap: () => _openBubbleScreen(true),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Wallpapers
                        SizedBox(
                          height: 110,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(left: 16),
                            itemCount: wallpapers.length,
                            itemBuilder: (context, index) {
                              final wp = wallpapers[index];
                              final isSelected = _selectedWallpaperId == wp['id'];
                              return GestureDetector(
                                onTap: () => _selectWallpaper(wp['id']),
                                child: Container(
                                  width: 80,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: AssetImage(wp['assetPath']),
                                      fit: BoxFit.cover,
                                    ),
                                    border: isSelected
                                        ? Border.all(
                                            color: const Color(0xFF00A884),
                                            width: 3,
                                          )
                                        : null,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: isSelected
                                      ? const Align(
                                          alignment: Alignment.topRight,
                                          child: Padding(
                                            padding: EdgeInsets.all(3),
                                            child: Icon(
                                              Icons.check_circle,
                                              color: Color(0xFF00A884),
                                              size: 16,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required IconData icon,
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required Color iconColor,
    required Color textColor,
    double min = 0,
    double max = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF00A884),
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
                thumbColor: const Color(0xFF00A884),
                overlayColor: const Color(0xFF00A884).withOpacity(0.2),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeButton(String label, bool isActive, Color iconColor) {
    return GestureDetector(
      onTap: () => setState(() => _isDarkTheme = label == 'Dark'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00A884) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              label == 'Light' ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              size: 16,
              color: isActive ? Colors.white : iconColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : iconColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}