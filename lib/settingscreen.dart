import 'package:flutter/material.dart';
import 'searchBar.dart';
import 'profileScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _username = 'User';
  String _userHandle = '@user';
  String _userBio = '';
  String _links = '';

  bool _isSearching = false;
  String _searchQuery = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _linksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = _username;
    _bioController.text = _userBio;
    _usernameController.text = _userHandle.replaceFirst('@', '');
    _linksController.text = _links;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
    _linksController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getSearchResults(String query) {
    if (query.isEmpty) return [];

    final allItems = [
      {'title': 'Account', 'subtitle': 'Security notifications, change number', 'icon': Icons.key_outlined},
      {'title': 'Privacy', 'subtitle': 'Blocked accounts, disappearing messages', 'icon': Icons.lock_outline},
      {'title': 'Lists', 'subtitle': 'Manage people and groups', 'icon': Icons.list_alt_outlined},
      {'title': 'Chats', 'subtitle': 'Theme, wallpapers, chat history', 'icon': Icons.chat_bubble_outline},
      {'title': 'Appearance', 'subtitle': 'Chat theme, app icon, app theme', 'icon': Icons.palette_outlined},
      {'title': 'Broadcasts', 'subtitle': 'Manage lists and send broadcasts', 'icon': Icons.campaign_outlined},
      {'title': 'Notifications', 'subtitle': 'Message, group & call tones', 'icon': Icons.notifications_none_outlined},
      {'title': 'Storage and data', 'subtitle': 'Network usage, auto-download', 'icon': Icons.storage_outlined},
      {'title': 'Accessibility', 'subtitle': 'Increase contrast, animation', 'icon': Icons.accessibility_new_outlined},
      {'title': 'App language', 'subtitle': "English (device's language)", 'icon': Icons.language_outlined},
      {'title': 'Help and feedback', 'subtitle': 'Help center, contact us, privacy policy', 'icon': Icons.help_outline},
      {'title': 'Invite a friend', 'subtitle': '', 'icon': Icons.person_add_outlined},
      {'title': 'App updates', 'subtitle': '', 'icon': Icons.system_update_outlined},
    ];

    return allItems.where((item) {
      final title = item['title']?.toString().toLowerCase() ?? '';
      final subtitle = item['subtitle']?.toString().toLowerCase() ?? '';
      final q = query.toLowerCase();
      return title.contains(q) || subtitle.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
        title: _isSearching
            ? SettingsSearchBar(
                hintText: 'Search settings',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onClose: () {
                  setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                  });
                },
              )
            : const Text(
                'Settings',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: _isSearching
            ? []
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToProfileScreen(context),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code),
                  onPressed: () {},
                ),
              ],
      ),
      body: _isSearching
          ? _buildSearchResults(colorScheme)
          : _buildSettingsBody(colorScheme),
    );
  }

  Widget _buildSearchResults(ColorScheme colorScheme) {
    final results = _getSearchResults(_searchQuery);

    if (_searchQuery.isEmpty) {
      return const Center(
        child: Text(
          'Type to search settings',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No results for "$_searchQuery"',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return _buildWhatsAppTile(
          icon: item['icon'] as IconData,
          title: item['title'] as String,
          subtitle: item['subtitle'] as String,
          onTap: () {},
        );
      },
    );
  }

  Widget _buildSettingsBody(ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        InkWell(
          onTap: () => _navigateToProfileScreen(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: colorScheme.primary.withOpacity(0.15),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _username,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.edit,
                      size: 18,
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _userHandle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Row(
            children: [
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
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Premium',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Unlock exclusive themes, advanced features and more for a better experience.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios,
                color: colorScheme.onSurface.withOpacity(0.4),
                size: 18,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _buildWhatsAppTile(
          icon: Icons.key_outlined,
          title: 'Account',
          subtitle: 'Security notifications, change number',
          onTap: () {},
        ),
        _buildWhatsAppTile(
          icon: Icons.lock_outline,
          title: 'Privacy',
          subtitle: 'Blocked accounts, disappearing messages',
          onTap: () {},
        ),
        _buildWhatsAppTile(
          icon: Icons.list_alt_outlined,
          title: 'Lists',
          subtitle: 'Manage people and groups',
          onTap: () {},
        ),
        _buildWhatsAppTile(
          icon: Icons.chat_bubble_outline,
          title: 'Chats',
          subtitle: 'Theme, wallpapers, chat history',
          onTap: () {},
        ),
        _buildWhatsAppTile(
          icon: Icons.palette_outlined,
          title: 'Appearance',
          subtitle: 'Chat theme, app icon, app theme',
          onTap: () {},
        ),
        _buildWhatsAppTile(
          icon: Icons.campaign_outlined,
          title: 'Broadcasts',
          subtitle: 'Manage lists and send broadcasts',
          onTap: () {},
        ),
        _buildWhatsAppTile(
          icon: Icons.notifications_none_outlined,
          title: 'Notifications',
          subtitle: 'Message, group & call tones',
          onTap: () {},
        ),
        _buildWhatsAppTile(
          icon: Icons.storage_outlined,
          title: 'Storage and data',
          subtitle: 'Network usage, auto-download',
          onTap: () {},
        ),
        _buildWhatsAppTile(
          icon: Icons.accessibility_new_outlined,
          title: 'Accessibility',
          subtitle: 'Increase contrast, animation',
          onTap: () {},
        ),
        _buildWhatsAppTile(
          icon: Icons.language_outlined,
          title: 'App language',
          subtitle: "English (device's language)",
          onTap: () {},
        ),
        _buildWhatsAppTile(
          icon: Icons.help_outline,
          title: 'Help and feedback',
          subtitle: 'Help center, contact us, privacy policy',
          onTap: () {},
        ),
        _buildWhatsAppTile(
          icon: Icons.person_add_outlined,
          title: 'Invite a friend',
          onTap: () {},
        ),
        _buildWhatsAppTile(
          icon: Icons.system_update_outlined,
          title: 'App updates',
          onTap: () {},
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

    void _navigateToProfileScreen(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => Container(
          color: bgColor,
          child: ProfileScreen(
            username: _username,
            userHandle: _userHandle,
            userBio: _userBio,
            onProfileUpdated: (name, handle, bio) {
              setState(() {
                _username = name;
                _userHandle = handle;
                _userBio = bio;
              });
            },
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
  }
  Widget _buildWhatsAppTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 2),
              child: Icon(icon, color: colorScheme.onSurface.withOpacity(0.5), size: 22),
            ),
            const SizedBox(width: 24),
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
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null && subtitle.toString().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: colorScheme.onSurface.withOpacity(0.45),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
