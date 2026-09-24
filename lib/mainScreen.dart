import 'package:flutter/material.dart';
import 'main.dart';
import 'archivedScreen.dart';
import 'chatMenu.dart';
import 'fabButton.dart';
import 'filterChips.dart';
import 'services/api_services.dart';
import 'chat_screen.dart' as chat;
import 'chat_Selection_Bar.dart';
import 'apptheme.dart';
import 'welcome_screen.dart';
import '/services/chat_data_service(archived).dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> users = [];
  bool isLoadingUsers = true;

  bool _isSelectionMode = false; 
  final Set<String> _selectedUserIds = {};

  bool get isOnline => !offlineModeNotifier.value;

  String _selectedFilter = 'All';
  final List<String> _pinnedUserIds = [];
  final Set<String> _mutedUserIds = {};

  @override
  void initState() {
    super.initState();
    searchNotifier.addListener(_onSearchChanged);
    offlineModeNotifier.addListener(_onOfflineModeChanged);
    loadUsers();
  }

  void loadUsers() async {
    final data = await ApiService.getUsers();
    setState(() {
      users = data;
      isLoadingUsers = false;
    });
  }

  void _clearSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedUserIds.clear();
    });
  }

  @override
  void dispose() {
    searchNotifier.removeListener(_onSearchChanged);
    offlineModeNotifier.removeListener(_onOfflineModeChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!searchNotifier.value && mounted) {
      setState(() {
        _searchController.clear();
      });
    }
  }

  void _onOfflineModeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // PIN — max 3, maintain order
  void _pinSelected() {
    final toPin = _selectedUserIds.where((id) => !_pinnedUserIds.contains(id)).toList();
    final available = 3 - _pinnedUserIds.length;

    if (available <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max 3 chats can be pinned'), duration: Duration(seconds: 2)),
      );
      _clearSelection();
      return;
    }

    if (toPin.length > available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only 3 chats can be pinned at a time'), duration: Duration(seconds: 2)),
      );
    }

    setState(() {
      _pinnedUserIds.addAll(toPin.take(available));
      _clearSelection();
    });
  }

  // DELETE — chat + messages
  void _deleteSelected() {
    setState(() {
      for (final id in _selectedUserIds) {
        ChatDataService.clearMessages(id);
        users.removeWhere((u) => (u['_id'] ?? '') == id);
        _pinnedUserIds.remove(id);
        _mutedUserIds.remove(id);
      }
      _clearSelection();
    });
  }

  // MUTE — no notifications
  void _muteSelected() {
    setState(() {
      for (final id in _selectedUserIds) {
        _mutedUserIds.add(id);
        ChatDataService.mutedUserIds.add(id);
      }
      _clearSelection();
    });
  }

  // ARCHIVE — move to archived screen
  void _archiveSelected() {
    setState(() {
      for (final id in _selectedUserIds.toList()) {
        final user = users.firstWhere(
          (u) => (u['_id'] ?? '') == id,
          orElse: () => <String, dynamic>{},
        );
        if (user.isNotEmpty) {
          ChatDataService.archiveUser(user);
          users.remove(user);
          _pinnedUserIds.remove(id);
        }
      }
      _clearSelection();
    });
  }

  // Check restored users from ArchivedScreen
  void _checkRestoredUsers() {
    final restored = ChatDataService.pullRestoredUsers();
    if (restored.isNotEmpty) {
      setState(() {
        users.addAll(restored);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final iconColor = colorScheme.onSurface.withOpacity(0.6);
    final searchBarColor = colorScheme.surface;
    final archiveBarColor = Theme.of(context).scaffoldBackgroundColor;
    final arrowColor = colorScheme.onSurface.withOpacity(0.4);

    return ValueListenableBuilder<bool>(
      valueListenable: searchNotifier,
      builder: (context, isSearching, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,

          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: _isSelectionMode
                ? SafeArea(
                    child: ChatSelectionBar(
                      selectedCount: _selectedUserIds.length,
                      onCancel: _clearSelection,
                      onDelete: _deleteSelected,
                      onPin: _pinSelected,
                      onMute: _muteSelected,
                      onArchive: _archiveSelected,
                    ),
                  )
                : AppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    surfaceTintColor: Colors.transparent,
                    title: isSearching
                        ? _buildSearchBar(archiveBarColor, iconColor, textColor)
                        : _buildLogo(textColor),
                    centerTitle: false,
                    toolbarHeight: 90,
                    actions: isSearching
                        ? []
                        : _buildAppBarActions(textColor, context),
                  ),
          ),

          floatingActionButton: (isSearching || _isSelectionMode)
              ? null
              : const FabButton(),

          body: Column(
            children: [
              if (!isSearching) _buildSearchButton(searchBarColor, iconColor, textColor),

              if (!isSearching)
                FilterChipsWidget(
                  colorScheme: colorScheme,
                  onFilterSelected: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                    debugPrint('Selected: $filter');
                  },
                ),

              if (isSearching) _buildFilterChips(),

              if (!isSearching) _buildArchiveBar(archiveBarColor, iconColor, textColor, arrowColor),

              Expanded(
                child: isSearching && _searchController.text.isNotEmpty
                    ? _buildSearchResults(textColor, iconColor)
                    : _buildMainContent(textColor, iconColor),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(Color textColor, Color iconColor) {
    _checkRestoredUsers();

    if (isLoadingUsers) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white24),
      );
    }

    if (users.isEmpty && _selectedFilter == 'All') {
      return const WelcomeScreen();
    }

    if (users.isEmpty) {
      return Center(
        child: Text(
          'No chats yet',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            color: textColor.withOpacity(0.5),
          ),
        ),
      );
    }

    return _buildChatListWithUsers(textColor, iconColor);
  }

  Widget _buildChatListWithUsers(Color textColor, Color iconColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // SORT: Pinned first (in pin order), then others
    final sortedUsers = [...users];
    sortedUsers.sort((a, b) {
      final aId = a['_id'] ?? '';
      final bId = b['_id'] ?? '';
      final aIndex = _pinnedUserIds.indexOf(aId);
      final bIndex = _pinnedUserIds.indexOf(bId);
      if (aIndex != -1 && bIndex != -1) return aIndex.compareTo(bIndex);
      if (aIndex != -1) return -1;
      if (bIndex != -1) return 1;
      return 0;
    });

    return ListView.builder(
      itemCount: sortedUsers.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final user = sortedUsers[index];
        final userId = user['_id'] ?? '';
        final isUserOnline = user['online'] == true;
        final isSelected = _selectedUserIds.contains(userId);
        final isPinned = _pinnedUserIds.contains(userId);
        final isMuted = _mutedUserIds.contains(userId);

        return InkWell(
          onLongPress: () {
            if (!_isSelectionMode) {
              setState(() {
                _isSelectionMode = true;
                _selectedUserIds.add(userId);
              });
            }
          },
          onTap: () {
            if (_isSelectionMode) {
              setState(() {
                if (isSelected) {
                  _selectedUserIds.remove(userId);
                  if (_selectedUserIds.isEmpty) _isSelectionMode = false;
                } else {
                  _selectedUserIds.add(userId);
                }
              });
            } else {
              Navigator.push(
                context,
                PageRouteBuilder(
                  opaque: false,
                  transitionDuration: const Duration(milliseconds: 300),
                  reverseTransitionDuration: const Duration(milliseconds: 250),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return chat.ChatScreen(
                      receiverId: userId,
                      receiverName: user['name'] ?? 'User',
                    );
                  },
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end).chain(
                      CurveTween(curve: curve),
                    );
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                ),
              );
            }
          },
          child: Container(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                : Colors.transparent,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: isDark
                        ? AppTheme.darkSurface
                        : AppTheme.lightSurface.withOpacity(0.7),
                    child: Icon(
                      Icons.person,
                      color: isDark
                          ? AppTheme.darkNavInactive
                          : AppTheme.lightNavInactive,
                      size: 28,
                    ),
                  ),
                  if (isUserOnline)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A884),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      user['name'] ?? 'User',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (isPinned)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(Icons.push_pin, size: 14, color: iconColor),
                    ),
                ],
              ),
              subtitle: Text(
                isUserOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: isUserOnline ? const Color(0xFF00A884) : iconColor,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(user['lastSeen']),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isMuted)
                    Icon(Icons.volume_off, size: 16, color: iconColor)
                  else
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00A884),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // SEARCH — filter names + tap to open chat
  Widget _buildSearchResults(Color textColor, Color iconColor) {
    final query = _searchController.text.toLowerCase();
    final results = users.where((u) {
      final name = (u['name'] ?? '').toString().toLowerCase();
      return name.contains(query);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'No results for "${_searchController.text}"',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: textColor.withOpacity(0.5)),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final user = results[index];
        final userId = user['_id'] ?? '';
        final isUserOnline = user['online'] == true;

        return InkWell(
          onTap: () {
            searchNotifier.value = false;
            Navigator.push(
              context,
              PageRouteBuilder(
                opaque: false,
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) {
                  return chat.ChatScreen(
                    receiverId: userId,
                    receiverName: user['name'] ?? 'User',
                  );
                },
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(position: offsetAnimation, child: child);
                },
              ),
            );
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkSurface
                      : AppTheme.lightSurface.withOpacity(0.7),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkNavInactive
                        : AppTheme.lightNavInactive,
                    size: 28,
                  ),
                ),
                if (isUserOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A884),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              user['name'] ?? 'User',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            subtitle: Text(
              isUserOnline ? 'Online' : 'Offline',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: isUserOnline ? const Color(0xFF00A884) : iconColor,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';

    try {
      final date = DateTime.parse(timestamp.toString());
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'now';
      if (diff.inHours < 1) return '${diff.inMinutes}m';
      if (diff.inDays < 1) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${date.day}/${date.month}';
    } catch (e) {
      return '';
    }
  }

  Widget _buildSearchBar(Color barColor, Color iconColor, Color textColor) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => searchNotifier.value = false,
            child: Icon(Icons.arrow_back, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              cursorColor: textColor,
              decoration: InputDecoration(
                hintText: 'Search chats',
                hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 15, color: iconColor),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
              style: TextStyle(fontFamily: 'Poppins', fontSize: 15, color: textColor),
              onChanged: (value) => setState(() {}),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {});
              },
              child: Icon(Icons.close, color: iconColor, size: 20),
            ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildLogo(Color logoColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Helo', style: TextStyle(fontFamily: 'GreatVibes', fontSize: 44, color: logoColor, height: 1.0, fontWeight: FontWeight.w700)),
          Text('Gram', style: TextStyle(fontFamily: 'GreatVibes', fontSize: 44, color: logoColor, height: 1.0, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions(Color logoColor, BuildContext context) {
    return [
      _buildUserAvatarWithIndicator(),
      const SizedBox(width: 4),
      IconButton(
        icon: Icon(Icons.camera_alt_outlined, color: logoColor, size: 26),
        onPressed: () {},
      ),
      PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: logoColor, size: 26),
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        offset: const Offset(0, 40),
        onSelected: (value) => ChatMenuOptions.handleMenuAction(value, context),
        itemBuilder: (context) => ChatMenuOptions.buildMenuItems(context),
      ),
      const SizedBox(width: 8),
    ];
  }

  Widget _buildUserAvatarWithIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final Color dotColor = isOnline
        ? Colors.green
        : colorScheme.onSurface.withOpacity(0.4);

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppTheme.darkSurface
                  : AppTheme.lightSurface.withOpacity(0.7),
            ),
            child: Icon(
              Icons.person,
              color: isDark
                  ? AppTheme.darkNavInactive
                  : AppTheme.lightNavInactive,
              size: 22,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
                boxShadow: isOnline
                    ? [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton(Color barColor, Color iconColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => searchNotifier.value = true,
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(Icons.search, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Text('Search chats', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, color: textColor)),
              const Spacer(),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip('Unread', Icons.mark_chat_unread_outlined, colorScheme),
          const SizedBox(width: 8),
          _buildChip('Photos', Icons.image_outlined, colorScheme),
          const SizedBox(width: 8),
          _buildChip('Videos', Icons.videocam_outlined, colorScheme),
          const SizedBox(width: 8),
          _buildChip('Links', Icons.link_outlined, colorScheme),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildArchiveBar(Color barColor, Color iconColor, Color textColor, Color arrowColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _navigateToArchived(context),
          splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.archive_outlined, color: iconColor, size: 24),
                  const SizedBox(width: 16),
                  Text(
                    'Archived',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: arrowColor, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToArchived(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => Container(
          color: bgColor,
          child: const ArchivedScreen(),
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
  }
}
