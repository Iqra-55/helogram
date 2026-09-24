import 'package:flutter/material.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final iconColor = colorScheme.onSurface.withOpacity(0.6);
    final barColor = colorScheme.surface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        // ✅ FIX: AppBar background same as screen (no separate color)
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: _isSearching
            ? _buildSearchBar(barColor, iconColor, textColor)
            : const Text('Calls'),
        leading: _isSearching
            ? null // ✅ Back arrow is INSIDE search bar now!
            : null,
        actions: _isSearching
            ? []
            : [
                IconButton(
                  icon: Icon(Icons.search, color: textColor),
                  onPressed: () => setState(() => _isSearching = true),
                ),
                _buildPopupMenu(context),
              ],
      ),
      body: Column(
        children: [
          // ✅ Call Type Icons Row — ALWAYS VISIBLE
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCallTypeIcon(
                  context,
                  icon: Icons.call,
                  label: 'Call',
                  onTap: () {},
                ),
                _buildCallTypeIcon(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Schedule',
                  onTap: () {},
                ),
                _buildCallTypeIcon(
                  context,
                  icon: Icons.dialpad,
                  label: 'Keypad',
                  onTap: () {},
                ),
                _buildCallTypeIcon(
                  context,
                  icon: Icons.favorite_border,
                  label: 'Favorites',
                  onTap: () {},
                ),
              ],
            ),
          ),

          // ✅ Recent Header (hide when searching)
          if (!_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ),

          // ✅ Calls List
          Expanded(
            child: _isSearching && _searchController.text.isNotEmpty
                ? _buildSearchResults(textColor)
                : _buildCallsList(iconColor),
          ),
        ],
      ),
    );
  }

  // ✅ CHAT-STYLE SEARCH BAR — Arrow INSIDE bar!
  Widget _buildSearchBar(Color barColor, Color iconColor, Color textColor) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          // ✅ Back arrow INSIDE search bar (like Chat screen)
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
            },
            child: Icon(Icons.arrow_back, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Icon(Icons.search, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              cursorColor: textColor,
              decoration: InputDecoration(
                hintText: 'Search name or number...',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: iconColor,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                color: textColor,
              ),
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

  // ✅ 3 Dots Popup Menu — WHITE BACKGROUND
  Widget _buildPopupMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      color: isDark ? const Color(0xFF2A2E36) : Colors.white,
      elevation: 8,
      constraints: const BoxConstraints(
        minWidth: 160,
        maxWidth: 180,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      popUpAnimationStyle: AnimationStyle(
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 200),
        reverseCurve: Curves.easeIn,
        reverseDuration: const Duration(milliseconds: 150),
      ),
      onSelected: (value) {
        switch (value) {
          case 'clear':
            _showClearDialog(context);
            break;
          case 'scheduled':
            break;
          case 'settings':
            break;
        }
      },
      itemBuilder: (context) => [
        _buildMenuItem(context, value: 'clear', label: 'Clear call log'),
        _buildMenuItem(context, value: 'scheduled', label: 'Scheduled calls'),
        _buildMenuItem(context, value: 'settings', label: 'Settings'),
      ],
    );
  }

  // ✅ SIRF TEXT — No Icon!
  PopupMenuItem<String> _buildMenuItem(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuItem<String>(
      value: value,
      child: InkWell(
        onTap: null,
        splashColor: colorScheme.primary.withOpacity(0.3),
        highlightColor: colorScheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Clear Call Log Dialog
  void _showClearDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Clear call log?',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'This will delete all your call history.',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Clear',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Search Results
  Widget _buildSearchResults(Color textColor) {
    return Center(
      child: Text(
        'Searching: ${_searchController.text}',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          color: textColor,
        ),
      ),
    );
  }

  // ✅ Calls List (Empty state)
  Widget _buildCallsList(Color iconColor) {
    return Center(
      child: Text(
        'No calls yet',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          color: iconColor,
        ),
      ),
    );
  }

  // ✅ Call Type Icon Button
  Widget _buildCallTypeIcon(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: colorScheme.primary.withOpacity(0.3),
      highlightColor: colorScheme.primary.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: colorScheme.onSurface,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}