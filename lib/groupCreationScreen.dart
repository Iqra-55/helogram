import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'groupPermissions.dart';
import '../services/dissappearing_screen.dart'; // ← ADD KARO

class GroupCreationScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedMembers;

  const GroupCreationScreen({
    super.key,
    required this.selectedMembers,
  });

  @override
  State<GroupCreationScreen> createState() => _GroupCreationScreenState();
}

class _GroupCreationScreenState extends State<GroupCreationScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final FocusNode _groupNameFocusNode = FocusNode();
  int? _disappearingDays;

  bool _editGroupSettings = true;
  bool _sendMessages = true;
  bool _addOtherMembers = true;
  bool _inviteViaLink = false;
  bool _approveNewMembers = false;

  String? _groupIconUrl;
  String? _selectedEmoji;

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupNameFocusNode.dispose();
    super.dispose();
  }

  void _openEmojiPicker() {
    _showEmojiPickerBottomSheet();
  }

  void _showEmojiPickerBottomSheet() {
    final colorScheme = Theme.of(context).colorScheme;
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
                  _groupNameFocusNode.requestFocus();

                  final currentText = _groupNameController.text;
                  final selection = _groupNameController.selection;

                  int start = selection.start;
                  int end = selection.end;
                  if (start < 0 || start > currentText.length) start = currentText.length;
                  if (end < 0 || end > currentText.length) end = currentText.length;

                  final newText = currentText.replaceRange(start, end, emoji.emoji);

                  _groupNameController.value = TextEditingValue(
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
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color lightPrimary = const Color(0xFFE0E3E8);
    final Color darkText = const Color(0xFF2D3142);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) return;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'New group',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: textColor,
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 20 + bottomPadding),
          children: [
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showGroupIconSheet(context),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withOpacity(0.1),
                      shape: BoxShape.circle,
                      image: _groupIconUrl != null
                          ? DecorationImage(
                              image: NetworkImage(_groupIconUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _groupIconUrl == null
                        ? Icon(
                            Icons.camera_alt,
                            color: colorScheme.onSurface.withOpacity(0.5),
                            size: 28,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.onSurface.withOpacity(0.3),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _groupNameController,
                            focusNode: _groupNameFocusNode,
                            textInputAction: TextInputAction.done,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: textColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Group name (optional)',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: colorScheme.onSurface.withOpacity(0.4),
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              filled: false,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _openEmojiPicker,
                          child: Container(
                            width: 44,
                            height: 44,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.emoji_emotions_outlined,
                                color: colorScheme.onSurface.withOpacity(0.5),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ←←← YE UPDATE HUA HAI ←←←
            _buildOptionTile(
              title: 'Disappearing messages',
              subtitle: _disappearingDays == null 
                  ? 'Off' 
                  : '$_disappearingDays ${_disappearingDays == 1 ? 'day' : 'days'}',
              icon: Icons.timer_outlined,
              onTap: () async {
                final result = await Navigator.push<Map<String, dynamic>?>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DisappearingMessagesScreen(
                      initialDays: _disappearingDays,
                    ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _disappearingDays = result['days'] as int?;
                  });
                }
              },
              textColor: textColor,
            ),

            const SizedBox(height: 8),

            _buildOptionTile(
              title: 'Group permissions',
              subtitle: _getPermissionsSummary(),
              icon: Icons.settings_outlined,
              onTap: () async {
                final result = await Navigator.push<Map<String, bool>>(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (context, animation, secondaryAnimation) => Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: GroupPermissionsScreen(
                        editGroupSettings: _editGroupSettings,
                        sendMessages: _sendMessages,
                        addOtherMembers: _addOtherMembers,
                        inviteViaLink: _inviteViaLink,
                        approveNewMembers: _approveNewMembers,
                      ),
                    ),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(position: offsetAnimation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 250),
                  ),
                );

                if (result != null) {
                  setState(() {
                    _editGroupSettings = result['editGroupSettings'] ?? _editGroupSettings;
                    _sendMessages = result['sendMessages'] ?? _sendMessages;
                    _addOtherMembers = result['addOtherMembers'] ?? _addOtherMembers;
                    _inviteViaLink = result['inviteViaLink'] ?? _inviteViaLink;
                    _approveNewMembers = result['approveNewMembers'] ?? _approveNewMembers;
                  });
                }
              },
              textColor: textColor,
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Text(
                  'Members:',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.selectedMembers.isEmpty ? 'None' : '${widget.selectedMembers.length}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: textColor.withOpacity(0.4),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add,
                      color: colorScheme.onSurface.withOpacity(0.5),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            if (widget.selectedMembers.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.selectedMembers.map((member) {
                  return _buildMemberAvatar(member, colorScheme, lightPrimary, darkText, textColor);
                }).toList(),
              ),
            ],
          ],
        ),
        floatingActionButton: Container(
          width: 56,
          height: 56,
          margin: EdgeInsets.only(bottom: bottomPadding),
          decoration: BoxDecoration(
            color: lightPrimary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final groupData = {
                  'name': _groupNameController.text,
                  'disappearingDays': _disappearingDays,
                  'iconEmoji': _selectedEmoji,
                  'iconUrl': _groupIconUrl,
                  'permissions': {
                    'editGroupSettings': _editGroupSettings,
                    'sendMessages': _sendMessages,
                    'addOtherMembers': _addOtherMembers,
                    'inviteViaLink': _inviteViaLink,
                    'approveNewMembers': _approveNewMembers,
                  },
                  'members': widget.selectedMembers,
                };
                debugPrint('Creating group: $groupData');
              },
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Icon(
                  Icons.check,
                  color: darkText,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getPermissionsSummary() {
    List<String> active = [];
    if (_editGroupSettings) active.add('Edit');
    if (_sendMessages) active.add('Chat');
    if (_addOtherMembers) active.add('Add');
    if (_inviteViaLink) active.add('Link');
    if (_approveNewMembers) active.add('Approval');

    if (active.isEmpty) return 'All restricted';
    if (active.length == 5) return 'All allowed';
    return active.join(', ');
  }

  void _showGroupIconSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Group icon',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildIconOption(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: () {
                  Navigator.pop(context);
                },
                textColor: textColor,
              ),
              _buildIconOption(
                icon: Icons.image_outlined,
                label: 'Gallery',
                onTap: () {
                  Navigator.pop(context);
                },
                textColor: textColor,
              ),
              _buildIconOption(
                icon: Icons.search,
                label: 'Search web',
                onTap: () {
                  Navigator.pop(context);
                },
                textColor: textColor,
              ),
              _buildIconOption(
                icon: Icons.auto_fix_high_outlined,
                label: 'AI images',
                onTap: () {
                  Navigator.pop(context);
                },
                textColor: textColor,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.onSurface.withOpacity(0.7), size: 24),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
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
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: textColor.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              icon,
              color: colorScheme.onSurface.withOpacity(0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberAvatar(Map<String, dynamic> member, ColorScheme colorScheme, Color lightPrimary, Color darkText, Color textColor) {
    final avatarUrl = member['avatar'];
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (avatarUrl != null && avatarUrl.toString().isNotEmpty)
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(avatarUrl.toString()),
            )
          else
            CircleAvatar(
              radius: 28,
              backgroundColor: lightPrimary.withOpacity(0.15),
              child: Text(
                member['name'][0],
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: darkText,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            member['name'].toString().split(' ')[0],
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: textColor.withOpacity(0.7),
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}