import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../apptheme.dart';

class ChatThemeService {
  // ── 31 DARK THEMES ──
  static final List<Map<String, dynamic>> _darkThemes = [
    {
      'id': 'default_dark',
      'name': 'Default Dark',
      'wallpaperType': 'solid',
      'wallpaperColor': AppTheme.darkBackground,
      'bubbleColor': const Color(0xFF2E8B57),
      'receiverBubbleColor': const Color(0xFF2A2D32),
    },
    {
      'id': 'charcoal_green',
      'name': 'Charcoal Green',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF1A1D21), Color(0xFF0F1113)],
      'bubbleColor': Color(0xFF2E8B57),
      'receiverBubbleColor': Color(0xFF2A2D32),
    },
    {
      'id': 'teal_dark',
      'name': 'Teal Dark',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF0D1F1F), Color(0xFF061212)],
      'bubbleColor': Color(0xFF00BCD4),
      'receiverBubbleColor': Color(0xFF1A2E2E),
    },
    {
      'id': 'midnight_blue',
      'name': 'Midnight Blue',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF0A1628), Color(0xFF050D18)],
      'bubbleColor': Color(0xFF2196F3),
      'receiverBubbleColor': Color(0xFF162238),
    },
    {
      'id': 'deep_purple',
      'name': 'Deep Purple',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF1A0F2E), Color(0xFF0F081A)],
      'bubbleColor': Color(0xFF9C27B0),
      'receiverBubbleColor': Color(0xFF2A1A3A),
    },
    {
      'id': 'forest_green',
      'name': 'Forest Green',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFF1B2E1B),
      'bubbleColor': Color(0xFF4CAF50),
      'receiverBubbleColor': Color(0xFF2A3E2A),
    },
    {
      'id': 'ocean_blue',
      'name': 'Ocean Blue',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFF0F1B2E),
      'bubbleColor': Color(0xFF03A9F4),
      'receiverBubbleColor': Color(0xFF1A2A3E),
    },
    {
      'id': 'wine_red',
      'name': 'Wine Red',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFF2E0F1B),
      'bubbleColor': Color(0xFFE91E63),
      'receiverBubbleColor': Color(0xFF3E1A26),
    },
    {
      'id': 'slate_grey',
      'name': 'Slate Grey',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFF1E1E1E),
      'bubbleColor': Color(0xFF607D8B),
      'receiverBubbleColor': Color(0xFF2E2E2E),
    },
    {
      'id': 'obsidian_black',
      'name': 'Obsidian Black',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF1C1C1C), Color(0xFF0A0A0A)],
      'bubbleColor': Color(0xFF9E9E9E),
      'receiverBubbleColor': Color(0xFF2A2A2A),
    },
    {
      'id': 'ember_orange',
      'name': 'Ember Orange',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF2E1A0F), Color(0xFF1A0F08)],
      'bubbleColor': Color(0xFFFF5722),
      'receiverBubbleColor': Color(0xFF3E2A1F),
    },
    {
      'id': 'neon_lime',
      'name': 'Neon Lime',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF1A2E0F), Color(0xFF0F1A08)],
      'bubbleColor': Color(0xFF76FF03),
      'receiverBubbleColor': Color(0xFF2A3E1F),
    },
    {
      'id': 'electric_violet',
      'name': 'Electric Violet',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF1F0F2E), Color(0xFF12081A)],
      'bubbleColor': Color(0xFF7C4DFF),
      'receiverBubbleColor': Color(0xFF2F1F3E),
    },
    {
      'id': 'crimson_night',
      'name': 'Crimson Night',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF2E0F15), Color(0xFF1A080E)],
      'bubbleColor': Color(0xFFF44336),
      'receiverBubbleColor': Color(0xFF3E1A20),
    },
    {
      'id': 'cyan_abyss',
      'name': 'Cyan Abyss',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF0F1F2E), Color(0xFF08121A)],
      'bubbleColor': Color(0xFF00E5FF),
      'receiverBubbleColor': Color(0xFF1A2A3A),
    },
    {
      'id': 'golden_shadow',
      'name': 'Golden Shadow',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF2E2A0F), Color(0xFF1A1808)],
      'bubbleColor': Color(0xFFFFC107),
      'receiverBubbleColor': Color(0xFF3E3A1F),
    },
    {
      'id': 'magenta_void',
      'name': 'Magenta Void',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF2E0F2A), Color(0xFF1A0815)],
      'bubbleColor': Color(0xFFFF00FF),
      'receiverBubbleColor': Color(0xFF3E1A3A),
    },
    {
      'id': 'indigo_depth',
      'name': 'Indigo Depth',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFF0F0F2E),
      'bubbleColor': Color(0xFF3F51B5),
      'receiverBubbleColor': Color(0xFF1A1A3E),
    },
    {
      'id': 'rustic_brown',
      'name': 'Rustic Brown',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFF2E1B0F),
      'bubbleColor': Color(0xFF8D6E63),
      'receiverBubbleColor': Color(0xFF3E2B1F),
    },
    {
      'id': 'arctic_night',
      'name': 'Arctic Night',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF0F1B2E), Color(0xFF0A121F)],
      'bubbleColor': Color(0xFF80D8FF),
      'receiverBubbleColor': Color(0xFF1A2638),
    },
    {
      'id': 'volcanic_red',
      'name': 'Volcanic Red',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF2E0F0F), Color(0xFF1A0808)],
      'bubbleColor': Color(0xFFFF1744),
      'receiverBubbleColor': Color(0xFF3E1A1A),
    },
    {
      'id': 'jungle_depth',
      'name': 'Jungle Depth',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFF0F2E15),
      'bubbleColor': Color(0xFF00C853),
      'receiverBubbleColor': Color(0xFF1A3E22),
    },
    {
      'id': 'stormy_grey',
      'name': 'Stormy Grey',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF2A2A2A), Color(0xFF151515)],
      'bubbleColor': Color(0xFFB0BEC5),
      'receiverBubbleColor': Color(0xFF3A3A3A),
    },
    {
      'id': 'sapphire_dark',
      'name': 'Sapphire Dark',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFF0A0F2E),
      'bubbleColor': Color(0xFF2962FF),
      'receiverBubbleColor': Color(0xFF1A1F3E),
    },
    {
      'id': 'rosewood',
      'name': 'Rosewood',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFF2E0F1A),
      'bubbleColor': Color(0xFFEC407A),
      'receiverBubbleColor': Color(0xFF3E1A26),
    },
    {
      'id': 'onyx_black',
      'name': 'Onyx Black',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF181818), Color(0xFF0D0D0D)],
      'bubbleColor': Color(0xFFCFD8DC),
      'receiverBubbleColor': Color(0xFF282828),
    },
    {
      'id': 'copper_dark',
      'name': 'Copper Dark',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF2E1F0F), Color(0xFF1A1208)],
      'bubbleColor': Color(0xFFFF6D00),
      'receiverBubbleColor': Color(0xFF3E2F1F),
    },
    {
      'id': 'plum_shadow',
      'name': 'Plum Shadow',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFF1A0F1A),
      'bubbleColor': Color(0xFFAB47BC),
      'receiverBubbleColor': Color(0xFF2A1F2A),
    },
    {
      'id': 'azure_night',
      'name': 'Azure Night',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF0F152E), Color(0xFF080C1A)],
      'bubbleColor': Color(0xFF448AFF),
      'receiverBubbleColor': Color(0xFF1A203E),
    },
    {
      'id': 'olive_dark',
      'name': 'Olive Dark',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFF1A1A0F),
      'bubbleColor': Color(0xFFAFB42B),
      'receiverBubbleColor': Color(0xFF2A2A1F),
    },
    {
      'id': 'charcoal_royal',
      'name': 'Charcoal Royal',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
      'bubbleColor': Color(0xFF5C6BC0),
      'receiverBubbleColor': Color(0xFF2A2A3E),
    },
  ];

  // ── 31 LIGHT THEMES ──
  static final List<Map<String, dynamic>> _lightThemes = [
    {
      'id': 'default_light',
      'name': 'Default Light',
      'wallpaperType': 'solid',
      'wallpaperColor': AppTheme.lightBackground,
      'bubbleColor': const Color(0xFF2C3859),
      'receiverBubbleColor': const Color(0xFFF0EDE5),
    },
    {
      'id': 'soft_cream',
      'name': 'Soft Cream',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFFFDFBF7), Color(0xFFF5F0E8)],
      'bubbleColor': Color(0xFF2E8B57),
      'receiverBubbleColor': Color(0xFFF0EDE5),
    },
    {
      'id': 'sky_mint',
      'name': 'Sky Mint',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFFF0F7F4), Color(0xFFE8F5E9)],
      'bubbleColor': Color(0xFF00BFA5),
      'receiverBubbleColor': Color(0xFFE5F0EC),
    },
    {
      'id': 'blush_pink',
      'name': 'Blush Pink',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFFFDF5F5), Color(0xFFFCE4EC)],
      'bubbleColor': Color(0xFFE91E63),
      'receiverBubbleColor': Color(0xFFF5E5E8),
    },
    {
      'id': 'lavender_mist',
      'name': 'Lavender Mist',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFFF5F3FA), Color(0xFFEDE7F6)],
      'bubbleColor': Color(0xFF7C4DFF),
      'receiverBubbleColor': Color(0xFFEBE8F2),
    },
    {
      'id': 'warm_sand',
      'name': 'Warm Sand',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFFF5F1EB),
      'bubbleColor': Color(0xFF795548),
      'receiverBubbleColor': Color(0xFFE8E4DE),
    },
    {
      'id': 'cool_grey',
      'name': 'Cool Grey',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFFF0F2F5),
      'bubbleColor': Color(0xFF607D8B),
      'receiverBubbleColor': Color(0xFFE5E7EA),
    },
    {
      'id': 'ice_blue',
      'name': 'Ice Blue',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFFE3F2FD),
      'bubbleColor': Color(0xFF2196F3),
      'receiverBubbleColor': Color(0xFFD6E8F5),
    },
    {
      'id': 'peach_puff',
      'name': 'Peach Puff',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFFFFF3E0),
      'bubbleColor': Color(0xFFFF9800),
      'receiverBubbleColor': Color(0xFFF5E8D6),
    },
    {
      'id': 'lemon_chiffon',
      'name': 'Lemon Chiffon',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFFFFFDE7), Color(0xFFFFF9C4)],
      'bubbleColor': Color(0xFFFFEB3B),
      'receiverBubbleColor': Color(0xFFF5F0D6),
    },
    {
      'id': 'rose_quartz',
      'name': 'Rose Quartz',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
      'bubbleColor': Color(0xFFF06292),
      'receiverBubbleColor': Color(0xFFF5D8E0),
    },
    {
      'id': 'sage_green',
      'name': 'Sage Green',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFFF1F8E9),
      'bubbleColor': Color(0xFF8BC34A),
      'receiverBubbleColor': Color(0xFFE5EBDD),
    },
    {
      'id': 'powder_blue',
      'name': 'Powder Blue',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
      'bubbleColor': Color(0xFF03A9F4),
      'receiverBubbleColor': Color(0xFFD6EBF5),
    },
    {
      'id': 'coral_breeze',
      'name': 'Coral Breeze',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFFFBE9E7),
      'bubbleColor': Color(0xFFFF7043),
      'receiverBubbleColor': Color(0xFFF0DDD8),
    },
    {
      'id': 'lilac_dream',
      'name': 'Lilac Dream',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
      'bubbleColor': Color(0xFFBA68C8),
      'receiverBubbleColor': Color(0xFFE8D8EB),
    },
    {
      'id': 'seafoam_white',
      'name': 'Seafoam White',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFFE0F2F1),
      'bubbleColor': Color(0xFF26A69A),
      'receiverBubbleColor': Color(0xFFD5E8E6),
    },
    {
      'id': 'sunset_glow',
      'name': 'Sunset Glow',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
      'bubbleColor': Color(0xFFFFCA28),
      'receiverBubbleColor': Color(0xFFF5EDD6),
    },
    {
      'id': 'cotton_candy',
      'name': 'Cotton Candy',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFFFCE4EC), Color(0xFFE3F2FD)],
      'bubbleColor': Color(0xFFEC407A),
      'receiverBubbleColor': Color(0xFFF0D8E0),
    },
    {
      'id': 'mint_fresh',
      'name': 'Mint Fresh',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFFE8F5E9),
      'bubbleColor': Color(0xFF66BB6A),
      'receiverBubbleColor': Color(0xFFDDE8DD),
    },
    {
      'id': 'skyline_blue',
      'name': 'Skyline Blue',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
      'bubbleColor': Color(0xFF42A5F5),
      'receiverBubbleColor': Color(0xFFD6E5F0),
    },
    {
      'id': 'apricot_cream',
      'name': 'Apricot Cream',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFFFFF3E0),
      'bubbleColor': Color(0xFFFFB74D),
      'receiverBubbleColor': Color(0xFFF5E8D5),
    },
    {
      'id': 'lavender_haze',
      'name': 'Lavender Haze',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
      'bubbleColor': Color(0xFF9575CD),
      'receiverBubbleColor': Color(0xFFE0D8EB),
    },
    {
      'id': 'spring_meadow',
      'name': 'Spring Meadow',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFFF9FBE7),
      'bubbleColor': Color(0xFFCDDC39),
      'receiverBubbleColor': Color(0xFFEBEDD8),
    },
    {
      'id': 'ocean_mist',
      'name': 'Ocean Mist',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
      'bubbleColor': Color(0xFF26C6DA),
      'receiverBubbleColor': Color(0xFFD5EBEE),
    },
    {
      'id': 'strawberry_milk',
      'name': 'Strawberry Milk',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFFFCE4EC),
      'bubbleColor': Color(0xFFF48FB1),
      'receiverBubbleColor': Color(0xFFF0D8E0),
    },
    {
      'id': 'vanilla_bean',
      'name': 'Vanilla Bean',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFFFFF8E1), Color(0xFFFFFDE7)],
      'bubbleColor': Color(0xFFFFD54F),
      'receiverBubbleColor': Color(0xFFF5EDD6),
    },
    {
      'id': 'periwinkle_dawn',
      'name': 'Periwinkle Dawn',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFFE8EAF6), Color(0xFFC5CAE9)],
      'bubbleColor': Color(0xFF7986CB),
      'receiverBubbleColor': Color(0xFFD8DAE8),
    },
    {
      'id': 'melon_sorbet',
      'name': 'Melon Sorbet',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFFF1F8E9),
      'bubbleColor': Color(0xFFAED581),
      'receiverBubbleColor': Color(0xFFE5EBDD),
    },
    {
      'id': 'cherry_blossom',
      'name': 'Cherry Blossom',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
      'bubbleColor': Color(0xFFF06292),
      'receiverBubbleColor': Color(0xFFF5D8E0),
    },
    {
      'id': 'cloud_white',
      'name': 'Cloud White',
      'wallpaperType': 'solid',
      'wallpaperColor': Color(0xFFFAFAFA),
      'bubbleColor': Color(0xFF90A4AE),
      'receiverBubbleColor': Color(0xFFEEEEEE),
    },
    {
      'id': 'tangerine_twist',
      'name': 'Tangerine Twist',
      'wallpaperType': 'gradient',
      'wallpaperColors': [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
      'bubbleColor': Color(0xFFFFA726),
      'receiverBubbleColor': Color(0xFFF5E8D5),
    },
  ];

  static List<Map<String, dynamic>> getThemes(bool isDark) {
    return isDark ? List.unmodifiable(_darkThemes) : List.unmodifiable(_lightThemes);
  }

  static Map<String, dynamic> getDefaultTheme(bool isDark) {
    if (isDark) {
      return {
        'id': 'default_dark',
        'name': 'Default Dark',
        'wallpaperType': 'solid',
        'wallpaperColor': AppTheme.darkBackground,
        'bubbleColor': const Color(0xFF2E8B57),
        'receiverBubbleColor': const Color(0xFF2A2D32),
      };
    }
    return {
      'id': 'default_light',
      'name': 'Default Light',
      'wallpaperType': 'solid',
      'wallpaperColor': AppTheme.lightBackground,
      'bubbleColor': const Color(0xFF2C3859),
      'receiverBubbleColor': const Color(0xFFF0EDE5),
    };
  }

  static Future<void> saveTheme(String chatId, String themeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_$chatId', themeId);
  }

  static Future<String?> getThemeId(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('theme_$chatId');
  }

  // ✅ FIX: getActiveTheme — wallpaper_settings se bhi read karo, chahe theme ho ya na ho
  static Future<Map<String, dynamic>?> getActiveTheme(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('theme_$chatId');
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark = brightness == Brightness.dark;

    // Pehle default theme lo
    Map<String, dynamic> theme;
    if (savedId == null) {
      theme = Map<String, dynamic>.from(getDefaultTheme(isDark));
    } else {
      final allThemes = [..._darkThemes, ..._lightThemes];
      theme = Map<String, dynamic>.from(
        allThemes.firstWhere(
          (t) => t['id'] == savedId,
          orElse: () => getDefaultTheme(isDark),
        ),
      );
    }

    // Old keys se read karo (backward compatibility)
    final bubbleColorValue = prefs.getInt('bubble_color_$chatId');
    if (bubbleColorValue != null) {
      theme['bubbleColor'] = Color(bubbleColorValue);
    }

    final receiverBubbleColorValue = prefs.getInt('receiver_bubble_color_$chatId');
    if (receiverBubbleColorValue != null) {
      theme['receiverBubbleColor'] = Color(receiverBubbleColorValue);
    }

    // ✅ FIX: wallpaper_settings se bhi read karo — AB HAMESHA CHALEGA
    final settingsJson = prefs.getString('wallpaper_settings_$chatId');
    if (settingsJson != null) {
      try {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        final senderVal = settings['senderBubbleColor'] as int?;
        final receiverVal = settings['receiverBubbleColor'] as int?;
        if (senderVal != null) theme['bubbleColor'] = Color(senderVal);
        if (receiverVal != null) theme['receiverBubbleColor'] = Color(receiverVal);
      } catch (_) {}
    }

    return theme;
  }

  static Future<void> saveBubbleColor(String chatId, Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bubble_color_$chatId', color.value);
  }

  static Future<Color?> getBubbleColor(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt('bubble_color_$chatId');
    return value != null ? Color(value) : null;
  }

  static Future<void> saveReceiverBubbleColor(String chatId, Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('receiver_bubble_color_$chatId', color.value);
  }

  static Future<Color?> getReceiverBubbleColor(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt('receiver_bubble_color_$chatId');
    return value != null ? Color(value) : null;
  }

  static Future<void> clearCustomColors(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bubble_color_$chatId');
    await prefs.remove('receiver_bubble_color_$chatId');
  }

  static BoxDecoration getWallpaperDecoration(Map<String, dynamic> theme) {
    if (theme['wallpaperType'] == 'gradient') {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: (theme['wallpaperColors'] as List).cast<Color>(),
        ),
      );
    }
    return BoxDecoration(
      color: theme['wallpaperColor'] as Color? ?? Colors.white,
    );
  }

  static Future<void> resetTheme(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('theme_$chatId');
    await prefs.remove('bubble_color_$chatId');
    await prefs.remove('receiver_bubble_color_$chatId');
  }

  // ═══════════════════════════════════════════════════════════
  // WALLPAPERS
  // ═══════════════════════════════════════════════════════════
  static final List<Map<String, dynamic>> _wallpapers = [
    {
      'id': 'img_01',
      'name': 'Purple Art',
      'type': 'image',
      'assetPath': 'assets/wallpapers/24d3c01f17da5b7bd4afc4669197124f.jpg',
      'brightness': 'dark',
      'description': 'Artistic purple tones for a creative vibe',
    },
    {
      'id': 'img_02',
      'name': 'Room',
      'type': 'image',
      'assetPath': 'assets/wallpapers/4169-27607_Room2.webp',
      'brightness': 'light',
      'description': 'Cozy room aesthetic wallpaper',
    },
    {
      'id': 'img_03',
      'name': 'Pattern',
      'type': 'image',
      'assetPath': 'assets/wallpapers/5705.webp',
      'brightness': 'mixed',
      'description': 'Abstract pattern design',
    },
    {
      'id': 'img_04',
      'name': 'Pink Floral',
      'type': 'image',
      'assetPath': 'assets/wallpapers/1134886.jpg',
      'brightness': 'light',
      'description': 'Soft pink floral artwork',
    },
    {
      'id': 'img_05',
      'name': 'Floral Pattern',
      'type': 'image',
      'assetPath': 'assets/wallpapers/88442725fb9f9ce2828e8698f1d5c8e5.jpg',
      'brightness': 'light',
      'description': 'Elegant floral pattern',
    },
    {
      'id': 'img_06',
      'name': 'Canva Art',
      'type': 'image',
      'assetPath': 'assets/wallpapers/canva-charcoal-mint-green-bright-purple-tactile-psychedelic-noise.jpg',
      'brightness': 'dark',
      'description': 'Psychedelic art with mint and purple',
    },
    {
      'id': 'img_07',
      'name': 'Dark Car',
      'type': 'image',
      'assetPath': 'assets/wallpapers/dark car.jpg',
      'brightness': 'dark',
      'description': 'Sleek dark automotive wallpaper',
    },
    {
      'id': 'img_08',
      'name': 'Lavender',
      'type': 'image',
      'assetPath': 'assets/wallpapers/OIP (1).jpg',
      'brightness': 'light',
      'description': 'Calming lavender fields',
    },
    {
      'id': 'img_09',
      'name': 'Plant',
      'type': 'image',
      'assetPath': 'assets/wallpapers/OIP (2).jpg',
      'brightness': 'light',
      'description': 'Green plant nature wallpaper',
    },
    {
      'id': 'img_10',
      'name': 'Teal Pattern',
      'type': 'image',
      'assetPath': 'assets/wallpapers/OIP (4).jpg',
      'brightness': 'dark',
      'description': 'Deep teal geometric pattern',
    },
    {
      'id': 'img_11',
      'name': 'Teal Roses',
      'type': 'image',
      'assetPath': 'assets/wallpapers/OIP (5).jpg',
      'brightness': 'dark',
      'description': 'Dark teal roses aesthetic',
    },
    {
      'id': 'img_12',
      'name': 'Orange Floral',
      'type': 'image',
      'assetPath': 'assets/wallpapers/OIP (6).jpg',
      'brightness': 'light',
      'description': 'Warm orange floral design',
    },
    {
      'id': 'img_13',
      'name': 'Golden Room',
      'type': 'image',
      'assetPath': 'assets/wallpapers/OIP (7).jpg',
      'brightness': 'dark',
      'description': 'Luxurious golden interior',
    },
    {
      'id': 'img_14',
      'name': 'Pink Flowers',
      'type': 'image',
      'assetPath': 'assets/wallpapers/OIP (8).jpg',
      'brightness': 'light',
      'description': 'Delicate pink flowers',
    },
    {
      'id': 'img_15',
      'name': 'Vanity',
      'type': 'image',
      'assetPath': 'assets/wallpapers/OIP (9).jpg',
      'brightness': 'light',
      'description': 'Elegant vanity setup',
    },
    {
      'id': 'img_16',
      'name': 'Car',
      'type': 'image',
      'assetPath': 'assets/wallpapers/OIP.jpg',
      'brightness': 'dark',
      'description': 'Classic car wallpaper',
    },
    {
      'id': 'img_17',
      'name': 'Purple Butterfly',
      'type': 'image',
      'assetPath': 'assets/wallpapers/purple-butterfly-art-wallpaper-2.jpg',
      'brightness': 'dark',
      'description': 'Artistic purple butterfly',
    },
    {
      'id': 'img_18',
      'name': 'Soft Blue',
      'type': 'image',
      'assetPath': 'assets/wallpapers/WhatsApp Image 2026-08-16 at 3.23.07 PM (1).jpeg',
      'brightness': 'light',
      'description': 'Soft blue calming background',
    },
    {
      'id': 'img_19',
      'name': 'Dark Rose',
      'type': 'image',
      'assetPath': 'assets/wallpapers/WhatsApp Image 2026-08-16 at 3.23.07 PM.jpeg',
      'brightness': 'dark',
      'description': 'Mysterious dark rose theme',
    },
    {
      'id': 'img_20',
      'name': 'Pink Hearts',
      'type': 'image',
      'assetPath': 'assets/wallpapers/WhatsApp Image 2026-08-16 at 3.23.09 PM.jpeg',
      'brightness': 'light',
      'description': 'Cute pink hearts pattern',
    },
    {
      'id': 'img_21',
      'name': 'Blue Sky',
      'type': 'image',
      'assetPath': 'assets/wallpapers/WhatsApp Image 2026-08-16 at 3.23.10 PM (1).jpeg',
      'brightness': 'light',
      'description': 'Clear blue sky scenery',
    },
    {
      'id': 'img_22',
      'name': 'Pastel Floral',
      'type': 'image',
      'assetPath': 'assets/wallpapers/WhatsApp Image 2026-08-16 at 3.23.10 PM (2).jpeg',
      'brightness': 'light',
      'description': 'Soft pastel floral art',
    },
    {
      'id': 'img_23',
      'name': 'Purple Sky',
      'type': 'image',
      'assetPath': 'assets/wallpapers/WhatsApp Image 2026-08-16 at 3.23.10 PM.jpeg',
      'brightness': 'dark',
      'description': 'Dreamy purple night sky',
    },
    {
      'id': 'img_24',
      'name': 'White Floral',
      'type': 'image',
      'assetPath': 'assets/wallpapers/WhatsApp Image 2026-08-16 at 3.23.11 PM.jpeg',
      'brightness': 'light',
      'description': 'Pure white floral elegance',
    },
    {
      'id': 'img_25',
      'name': 'Minimal',
      'type': 'image',
      'assetPath': 'assets/wallpapers/WhatsApp Image 2026-08-16 at 3.23.21 PM.jpeg',
      'brightness': 'light',
      'description': 'Clean minimal design',
    },
    {
      'id': 'img_26',
      'name': 'Green Nature',
      'type': 'image',
      'assetPath': 'assets/wallpapers/WhatsApp Image 2026-08-16 at 3.23.22 PM (1).jpeg',
      'brightness': 'light',
      'description': 'Fresh green nature view',
    },
    {
      'id': 'img_27',
      'name': 'Blue Tree',
      'type': 'image',
      'assetPath': 'assets/wallpapers/WhatsApp Image 2026-08-16 at 3.23.22 PM.jpeg',
      'brightness': 'light',
      'description': 'Serene blue tree landscape',
    },
    {
      'id': 'img_28',
      'name': 'Blue Butterfly',
      'type': 'image',
      'assetPath': 'assets/wallpapers/wp15106873.webp',
      'brightness': 'light',
      'description': 'Beautiful blue butterfly art',
    },
  ];

  static List<Map<String, dynamic>> getWallpapers(bool isDark) {
    return List.unmodifiable(_wallpapers);
  }

  static Map<String, dynamic>? getWallpaperById(String id, bool isDark) {
    try {
      final wp = _wallpapers.firstWhere((w) => w['id'] == id);
      return {
        'id': wp['id'],
        'name': wp['name'],
        'type': wp['type'],
        'assetPath': wp['assetPath'],
        'brightness': wp['brightness'],
        'description': wp['description'],
        'displayColor': isDark ? Colors.grey[800]! : Colors.grey[400]!,
      };
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveWallpaper(String chatId, String wallpaperId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallpaper_$chatId', wallpaperId);
  }

  static Future<String> getWallpaper(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('wallpaper_$chatId') ?? 'default';
  }

  static Future<void> clearWallpaper(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wallpaper_$chatId');
  }

  static BoxDecoration getWallpaperDecorationById(String id, bool isDark) {
    try {
      final wp = _wallpapers.firstWhere((w) => w['id'] == id);
      if (wp['type'] == 'image') {
        return BoxDecoration(
          image: DecorationImage(
            image: AssetImage(wp['assetPath']),
            fit: BoxFit.cover,
            opacity: isDark ? 0.35 : 0.25,
          ),
        );
      }
    } catch (_) {}

    return BoxDecoration(
      color: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // WALLPAPER SETTINGS
  // ═══════════════════════════════════════════════════════════
  static Future<void> saveWallpaperSettings(
    String chatId,
    Map<String, dynamic> settings,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallpaper_settings_$chatId', jsonEncode(settings));
  }

  // ✅ FIX: senderBubbleColor & receiverBubbleColor bhi return karo
  static Future<Map<String, dynamic>> getWallpaperSettings(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('wallpaper_settings_$chatId');
    if (jsonStr == null) {
      return {
        'blur': 0.0,
        'brightness': 0.0,
        'tint': Colors.transparent.value,
        'darkTheme': false,
      };
    }
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return {
        'blur': (map['blur'] as num?)?.toDouble() ?? 0.0,
        'brightness': (map['brightness'] as num?)?.toDouble() ?? 0.0,
        'tint': map['tint'] as int? ?? Colors.transparent.value,
        'darkTheme': map['darkTheme'] as bool? ?? false,
        'senderBubbleColor': map['senderBubbleColor'] as int?,
        'receiverBubbleColor': map['receiverBubbleColor'] as int?,
      };
    } catch (_) {
      return {
        'blur': 0.0,
        'brightness': 0.0,
        'tint': Colors.transparent.value,
        'darkTheme': false,
      };
    }
  }

  static Future<Map<String, dynamic>> getFullWallpaperConfig(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final wallpaperId = prefs.getString('wallpaper_$chatId') ?? 'default';
    final settings = await getWallpaperSettings(chatId);

    return {
      'wallpaperId': wallpaperId,
      'blur': settings['blur'],
      'brightness': settings['brightness'],
      'tint': Color(settings['tint'] as int),
      'darkTheme': settings['darkTheme'],
      'senderBubbleColor': settings['senderBubbleColor'],
      'receiverBubbleColor': settings['receiverBubbleColor'],
    };
  }

  static Future<void> clearWallpaperSettings(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wallpaper_settings_$chatId');
  }
}