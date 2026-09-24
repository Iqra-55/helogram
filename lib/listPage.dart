import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'theme.dart';
import 'apptheme.dart';

class NewListPage extends StatefulWidget {
  const NewListPage({super.key});

  @override
  State<NewListPage> createState() => _NewListPageState();
}

class _NewListPageState extends State<NewListPage> {
  final TextEditingController _listNameController = TextEditingController();
  final FocusNode _listNameFocusNode = FocusNode();
  String _selectedQuickCreate = '';

  final List<Map<String, dynamic>> _quickCreateOptions = [
    {'icon': Icons.work_outline, 'label': 'Work'},
    {'icon': Icons.people_outline, 'label': 'Friends'},
    {'icon': Icons.favorite_border, 'label': 'Family'},
    {'icon': Icons.school_outlined, 'label': 'Study'},
    {'icon': Icons.shopping_bag_outlined, 'label': 'Shopping'},
  ];

  @override
  void dispose() {
    _listNameController.dispose();
    _listNameFocusNode.dispose();
    super.dispose();
  }

  void _openEmojiPicker() {
    _showEmojiPickerBottomSheet();
  }

  void _showEmojiPickerBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [

                    
                    const SizedBox(width: 12),
                    Icon(
                      Icons.search,
                      color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.4),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search emoji',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.4),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          filled: false,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
            Expanded(
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  _listNameFocusNode.requestFocus();

                  final currentText = _listNameController.text;
                  final selection = _listNameController.selection;

                  int start = selection.start;
                  int end = selection.end;
                  if (start < 0 || start > currentText.length) start = currentText.length;
                  if (end < 0 || end > currentText.length) end = currentText.length;

                  final newText = currentText.replaceRange(start, end, emoji.emoji);

                  _listNameController.value = TextEditingValue(
                    text: newText,
                    selection: TextSelection.collapsed(
                      offset: start + emoji.emoji.length,
                    ),
                  );

                  Navigator.pop(context);
                },
                config: Config(
                  emojiViewConfig: EmojiViewConfig(
                    columns: 8,
                    emojiSizeMax: 32,
                    verticalSpacing: 4,
                    horizontalSpacing: 4,
                    gridPadding: const EdgeInsets.symmetric(horizontal: 8),
                    recentsLimit: 32,
                    noRecents: Text(
                      'No Recents',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    loadingIndicator: const SizedBox.shrink(),
                    buttonMode: ButtonMode.MATERIAL,
                    backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                  ),
                  categoryViewConfig: CategoryViewConfig(
                    initCategory: Category.RECENT,
                    recentTabBehavior: RecentTabBehavior.RECENT,
                    tabIndicatorAnimDuration: kTabScrollDuration,
                    indicatorColor: const Color(0xFF007AFF),
                    iconColor: isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
                    iconColorSelected: const Color(0xFF007AFF),
                    backspaceColor: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                    categoryIcons: const CategoryIcons(),
                    backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                  ),
                  skinToneConfig: SkinToneConfig(
                    enabled: true,
                    dialogBackgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                    indicatorColor: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2),
                  ),
                  bottomActionBarConfig: BottomActionBarConfig(
                    backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                    buttonColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                    buttonIconColor: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                  ),
                  searchViewConfig: SearchViewConfig(
                    backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                  ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    // AppTheme colors
    final bgColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final textColor = isDark ? AppTheme.darkLightText : AppTheme.lightDarkText;
    final greyColor = isDark ? AppTheme.darkNavInactive : const Color(0xFF6B7280);
    final dividerColor = isDark ? const Color(0xFF2A2E36) : const Color(0xFFE5E7EB);

    // Light green for premium
    final premiumColor = isDark ? const Color.fromARGB(255, 202, 220, 209) : const Color.fromARGB(255, 12, 39, 87);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Header ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: greyColor,
                      ),
                      
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'New List',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Create a list to organize your chats',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: greyColor,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.share_outlined,
                            size: 18,
                            color: greyColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Share',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: greyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── List Name ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'List name',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // SMOOTH — no box, underline only
                    Row(
                      children: [
                        Icon(
                          Icons.format_list_bulleted,
                          size: 22,
                          color: greyColor,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _listNameController,
                            focusNode: _listNameFocusNode,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: textColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. Work, Friends, Family',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                color: greyColor.withOpacity(0.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: dividerColor,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: dividerColor,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: textColor,
                                  width: 1.5,
                                ),
                              ),
                              suffixIcon: GestureDetector(
                                onTap: _openEmojiPicker,
                                child: Icon(
                                  Icons.sentiment_satisfied_outlined,
                                  size: 20,
                                  color: greyColor,
                                ),
                              ),
                              suffixIconConstraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This list will appear as a filter at the top of your Chats tab.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: greyColor.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Divider ───
            SliverToBoxAdapter(
              child: Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: dividerColor,
              ),
            ),

            // ─── Quick Create ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Create',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: greyColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _quickCreateOptions.map((option) {
                        final isSelected = _selectedQuickCreate == option['label'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedQuickCreate = option['label'];
                              _listNameController.text = option['label'];
                            });
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB))
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? (isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB))
                                        : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  option['icon'] as IconData,
                                  size: 22,
                                  color: isSelected
                                      ? textColor
                                      : greyColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                option['label'] as String,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? textColor : greyColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Divider ───
            SliverToBoxAdapter(
              child: Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: dividerColor,
              ),
            ),

            // ─── Customize your list ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Customize your list',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: greyColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium,
                                size: 10,
                                color: premiumColor,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Premium',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: premiumColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildListItem(
                      icon: Icons.palette_outlined,
                      title: 'Change color',
                      subtitle: 'Pick a color that fits your list',
                      greyColor: greyColor,
                      textColor: textColor,
                      isLocked: true,
                    ),
                    _buildListItem(
                      icon: Icons.sentiment_satisfied_outlined,
                      title: 'Choose icon',
                      subtitle: 'Choose a symbol for your list',
                      greyColor: greyColor,
                      textColor: textColor,
                      isLocked: true,
                    ),
                    _buildListItem(
                      icon: Icons.notifications_outlined,
                      title: 'Custom notifications',
                      subtitle: 'Set custom notifications for this list',
                      greyColor: greyColor,
                      textColor: textColor,
                      isLocked: true,
                    ),
                  ],
                ),
              ),
            ),

            // ─── Divider ───
            SliverToBoxAdapter(
              child: Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: dividerColor,
              ),
            ),

            // ─── HeloGram Plus Banner ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.diamond_outlined,
                          size: 22,
                          color: premiumColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'HeloGram Plus',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.workspace_premium,
                                    size: 14,
                                    color: premiumColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Unlock unlimited lists, custom icons, colors, and exclusive personalization features.',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: greyColor.withOpacity(0.8),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: greyColor.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── Divider ───
            SliverToBoxAdapter(
              child: Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: dividerColor,
              ),
            ),

            // ─── Add People or Groups ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.group_add_outlined,
                        size: 22,
                        color: greyColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Add People or Groups',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: greyColor.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color greyColor,
    required Color textColor,
    bool isLocked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: greyColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: greyColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (isLocked)
            Icon(
              Icons.lock_outline,
              size: 18,
              color: greyColor.withOpacity(0.4),
            ),
        ],
      ),
    );
  }
}