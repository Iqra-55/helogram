import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../apptheme.dart';
import 'chat_theme_service.dart';
import '../chat_bubble_screen.dart';

class ThemePreviewScreen extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic> theme;
  final bool isDark;

  const ThemePreviewScreen({
    Key? super.key,
    required this.chatId,
    required this.theme,
    required this.isDark,
  });

  @override
  State<ThemePreviewScreen> createState() => _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends State<ThemePreviewScreen> {
  late Map<String, dynamic> _theme;
  late bool _isDark;
  double _brightness = 0.0;
  double _wallpaperOpacity = 0.25;
  Color? _senderBubbleColor;
  Color? _receiverBubbleColor;

  @override
  void initState() {
    super.initState();
    _theme = _normalizeTheme(Map<String, dynamic>.from(widget.theme));
    _isDark = widget.isDark;
    _senderBubbleColor = _resolveColor(_theme['bubbleColor'], null);
    _receiverBubbleColor = _resolveColor(_theme['receiverBubbleColor'], null);
    _loadSettings();
  }

  Color _resolveColor(dynamic value, Color? fallback) {
    if (value is Color) return value;
    if (value is int) return Color(value);
    return fallback ?? Colors.transparent;
  }

  int? _colorValue(dynamic color) {
    if (color == null) return null;
    if (color is Color) return color.value;
    if (color is int) return color;
    return null;
  }

  Map<String, dynamic> _normalizeTheme(Map<String, dynamic> theme) {
    final result = Map<String, dynamic>.from(theme);
    const colorKeys = ['wallpaperColor', 'bubbleColor', 'receiverBubbleColor'];
    for (final key in colorKeys) {
      if (result.containsKey(key)) {
        result[key] = _resolveColor(result[key], Colors.transparent);
      }
    }
    if (result.containsKey('wallpaperColors') && result['wallpaperColors'] is List) {
      result['wallpaperColors'] = (result['wallpaperColors'] as List)
          .map((c) => _resolveColor(c, Colors.white))
          .toList();
    }
    return result;
  }

  Future<void> _loadSettings() async {
    final settings = await ChatThemeService.getWallpaperSettings(widget.chatId);
    if (mounted) {
      setState(() {
        _brightness = (settings['brightness'] as num?)?.toDouble() ?? 0.0;
      });
    }
  }

  Future<void> _applyTheme() async {
    await ChatThemeService.saveTheme(widget.chatId, _theme['id']);
    await ChatThemeService.clearWallpaper(widget.chatId);
    await ChatThemeService.saveWallpaperSettings(widget.chatId, {
      'blur': 0.0,
      'brightness': _brightness,
      'tint': Colors.transparent.value,
      'darkTheme': _isDark,
      'senderBubbleColor': _colorValue(_senderBubbleColor ?? _theme['bubbleColor']),
      'receiverBubbleColor': _colorValue(_receiverBubbleColor ?? _theme['receiverBubbleColor']),
    });
    if (mounted) {
      Navigator.pop(context, _theme);
    }
  }

  Future<void> _removeTheme() async {
    await ChatThemeService.resetTheme(widget.chatId);
    await ChatThemeService.clearWallpaperSettings(widget.chatId);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickSenderBubble() async {
    final color = await Navigator.push<Color>(
      context,
      MaterialPageRoute(
        builder: (_) => ChatBubbleScreen(
          initialColor: _senderBubbleColor ?? _defaultSenderColor,
          defaultColor: _defaultSenderColor,
          chatId: widget.chatId,
          isReceiver: false,
        ),
      ),
    );
    if (color != null && mounted) {
      setState(() => _senderBubbleColor = color);
    }
  }

  Future<void> _pickReceiverBubble() async {
    final color = await Navigator.push<Color>(
      context,
      MaterialPageRoute(
        builder: (_) => ChatBubbleScreen(
          initialColor: _receiverBubbleColor ?? _defaultReceiverColor,
          defaultColor: _defaultReceiverColor,
          chatId: widget.chatId,
          isReceiver: true,
        ),
      ),
    );
    if (color != null && mounted) {
      setState(() => _receiverBubbleColor = color);
    }
  }

  Color get _defaultSenderColor {
    return _resolveColor(
      _theme['bubbleColor'],
      _isDark ? const Color(0xFF2E8B57) : const Color(0xFF2C3859),
    );
  }

  Color get _defaultReceiverColor {
    return _resolveColor(
      _theme['receiverBubbleColor'],
      _isDark ? const Color(0xFF2A2D32) : const Color(0xFFF0EDE5),
    );
  }

  Color get _activeSenderColor => _senderBubbleColor ?? _defaultSenderColor;
  Color get _activeReceiverColor => _receiverBubbleColor ?? _defaultReceiverColor;

  Color _textColor(Color bg) {
    final lum = bg.computeLuminance();
    return lum > 0.5 ? Colors.black87 : Colors.white;
  }

  BoxDecoration get _wallpaperDecoration {
    if (_theme['wallpaperType'] == 'gradient') {
      final rawColors = _theme['wallpaperColors'] as List?;
      if (rawColors != null && rawColors.isNotEmpty) {
        final colors = rawColors.map((c) => _resolveColor(c, Colors.white)).toList();
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors.cast<Color>(),
          ),
        );
      }
    }
    return BoxDecoration(
      color: _resolveColor(_theme['wallpaperColor'], Colors.white),
    );
  }

  Color get _sheetBackgroundColor {
    double wallpaperLum = 0.5;

    if (_theme['wallpaperType'] == 'gradient') {
      final rawColors = _theme['wallpaperColors'] as List?;
      if (rawColors != null && rawColors.isNotEmpty) {
        final colors = rawColors.map((c) => _resolveColor(c, Colors.white)).toList();
        wallpaperLum = colors.map((c) => c.computeLuminance()).reduce((a, b) => a + b) / colors.length;
      }
    } else {
      wallpaperLum = _resolveColor(_theme['wallpaperColor'], Colors.grey).computeLuminance();
    }

    final bool isBrightWallpaper = wallpaperLum > 0.55;

    if (_isDark) {
      return Colors.black.withOpacity(isBrightWallpaper ? 0.65 : 0.4);
    } else {
      return Colors.white.withOpacity(isBrightWallpaper ? 0.85 : 0.65);
    }
  }

  Color get _sheetBorderColor {
    return _isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.08);
  }

  List<Map<String, dynamic>> get _filteredThemes {
    final themes = _isDark
        ? ChatThemeService.getThemes(true)
        : ChatThemeService.getThemes(false);
    return themes.map((t) => _normalizeTheme(Map<String, dynamic>.from(t))).toList();
  }

  void _onThemeTap(Map<String, dynamic> t) {
    setState(() {
      _theme = _normalizeTheme(Map<String, dynamic>.from(t));
      _senderBubbleColor = null;
      _receiverBubbleColor = null;
    });
  }

  void _onModeChanged(bool dark) {
    if (_isDark == dark) return;
    setState(() {
      _isDark = dark;
      _senderBubbleColor = null;
      _receiverBubbleColor = null;
      final themes = _filteredThemes;
      if (themes.isNotEmpty) {
        _theme = _normalizeTheme(Map<String, dynamic>.from(themes.first));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textPrimary = _isDark ? AppTheme.darkLightText : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Theme Preview',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.white),
            onPressed: _applyTheme,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Wallpaper
          Container(decoration: _wallpaperDecoration),

          // Brightness overlay
          Container(
            color: _brightness > 0
                ? Colors.black.withOpacity((_brightness * 0.6).clamp(0.0, 0.85))
                : Colors.white.withOpacity((-_brightness * 0.5).clamp(0.0, 0.7)),
          ),

          // Chat preview (top area)
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: kToolbarHeight + 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildMockChat(),
                  ),
                ),
                // Bottom space for collapsed sheet (12% of screen)
                const SizedBox(height: 100),
              ],
            ),
          ),

          // ---- DraggableScrollableSheet ----
          // Ye officially nested scroll + sheet drag handle karta hai
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.12,
            maxChildSize: 0.85,
            snap: true,
            snapSizes: const [0.12, 0.42, 0.85],
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _sheetBackgroundColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border.all(
                        color: _sheetBorderColor,
                        width: 1,
                      ),
                    ),
                    // IMPORTANT: scrollController DraggableScrollableSheet se aata hai
                    // Isko ListView/CustomScrollView ko dena zaroori hai taake
                    // sheet drag aur inner scroll dono smoothly kaam karein
                    child: CustomScrollView(
                      controller: scrollController,
                      physics: const ClampingScrollPhysics(),
                      slivers: [
                        // Drag handle
                        SliverToBoxAdapter(
                          child: Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 10, bottom: 14),
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: _isDark
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        // Bubbles row
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: _isDark
                                        ? Colors.black.withOpacity(0.3)
                                        : Colors.black.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.chat_bubble_outline,
                                    size: 16,
                                    color: _isDark ? Colors.white : Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Bubbles',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _pickSenderBubble,
                                  child: Container(
                                    width: 40,
                                    height: 32,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      color: _activeSenderColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _isDark
                                            ? Colors.white.withOpacity(0.3)
                                            : Colors.black.withOpacity(0.15),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      size: 12,
                                      color: _textColor(_activeSenderColor) == Colors.white
                                          ? Colors.white
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _pickReceiverBubble,
                                  child: Container(
                                    width: 40,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: _activeReceiverColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _isDark
                                            ? Colors.white.withOpacity(0.3)
                                            : Colors.black.withOpacity(0.15),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      size: 12,
                                      color: _textColor(_activeReceiverColor) == Colors.white
                                          ? Colors.white
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 14)),
                        // Brightness
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: _isDark
                                        ? Colors.black.withOpacity(0.3)
                                        : Colors.black.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.brightness_6,
                                    size: 16,
                                    color: _isDark ? Colors.white : Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Brightness',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 160,
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: const Color(0xFF2E8B57),
                                      inactiveTrackColor: _isDark
                                          ? Colors.white.withOpacity(0.3)
                                          : Colors.black.withOpacity(0.15),
                                      thumbColor: _isDark ? Colors.white : const Color(0xFF2E8B57),
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 7,
                                      ),
                                      overlayShape: const RoundSliderOverlayShape(
                                        overlayRadius: 12,
                                      ),
                                    ),
                                    child: Slider(
                                      value: _brightness,
                                      min: -1.0,
                                      max: 1.0,
                                      onChanged: (v) {
                                        setState(() => _brightness = v);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 14)),
                        // Theme toggle
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: _isDark
                                        ? Colors.black.withOpacity(0.3)
                                        : Colors.black.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.brightness_auto,
                                    size: 16,
                                    color: _isDark ? Colors.white : Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Theme',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const Spacer(),
                                _buildThemeToggle(),
                              ],
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 14)),
                        // Themes label
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Themes',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 8)),
                        // Themes horizontal list
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: _filteredThemes.length,
                              itemBuilder: (context, index) {
                                final t = _filteredThemes[index];
                                final isSelected = _theme['id'] == t['id'];

                                final rawColors = t['wallpaperType'] == 'gradient'
                                    ? (t['wallpaperColors'] as List)
                                    : [t['wallpaperColor']];

                                final colors = rawColors.map((c) => _resolveColor(c, Colors.white)).toList();

                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _onThemeTap(t),
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    margin: const EdgeInsets.symmetric(horizontal: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: isSelected
                                          ? Border.all(
                                              color: const Color(0xFF2E8B57),
                                              width: 2.5,
                                            )
                                          : Border.all(
                                              color: _isDark
                                                  ? Colors.white.withOpacity(0.2)
                                                  : Colors.black.withOpacity(0.1),
                                              width: 1,
                                            ),
                                      gradient: colors.length > 1
                                          ? LinearGradient(
                                              colors: colors.cast<Color>(),
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color: colors.length == 1
                                          ? colors.first
                                          : null,
                                    ),
                                    child: isSelected
                                        ? const Align(
                                            alignment: Alignment.topRight,
                                            child: Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Color(0xFF2E8B57),
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
                        ),
                        // Bottom padding
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
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

  Widget _buildThemeToggle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onModeChanged(!_isDark),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 110,
        height: 36,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: _isDark ? const Color(0xFF1A1D21) : const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: _isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 52,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E8B57),
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E8B57).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wb_sunny_rounded,
                          size: 14,
                          color: !_isDark ? Colors.white : Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Light',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: !_isDark ? Colors.white : Colors.grey,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.nightlight_round,
                          size: 14,
                          color: _isDark ? Colors.white : Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Dark',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _isDark ? Colors.white : Colors.grey,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockChat() {
    return Column(
      children: [
        _buildMockDateChip(),
        const SizedBox(height: 16),
        _buildMockBubble(
          text: 'Swipe left or right to preview more wallpapers',
          isMe: false,
          bubbleColor: _activeReceiverColor,
          textColor: _textColor(_activeReceiverColor),
        ),
        const SizedBox(height: 8),
        _buildMockBubble(
          text: 'Only your chat will change. Only you see your chat themes.',
          isMe: true,
          bubbleColor: _activeSenderColor,
          textColor: _textColor(_activeSenderColor),
        ),
        const SizedBox(height: 8),
        _buildMockBubble(
          text: 'Text is easy to read on these bubbles.',
          isMe: false,
          bubbleColor: _activeReceiverColor,
          textColor: _textColor(_activeReceiverColor),
        ),
      ],
    );
  }

  Widget _buildMockDateChip() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _isDark
              ? Colors.grey.shade800.withOpacity(0.8)
              : Colors.grey.shade200.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Today',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _isDark ? Colors.white70 : Colors.black54,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildMockBubble({
    required String text,
    required bool isMe,
    required Color bubbleColor,
    required Color textColor,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 60 : 0,
          right: isMe ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}
