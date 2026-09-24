import 'package:flutter/material.dart';
import 'searchBar.dart';
import 'groupScreen.dart';
import 'groupCreationScreen.dart';

class FabButton extends StatelessWidget {
  const FabButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _navigateToSelectContact(context),
      backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.chat_bubble,
        color: Theme.of(context).floatingActionButtonTheme.foregroundColor,
        size: 28,
      ),
    );
  }

  void _navigateToSelectContact(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => Container(
          color: bgColor,
          child: const SelectContactScreen(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

// SELECT CONTACT SCREEN
class SelectContactScreen extends StatefulWidget {
  const SelectContactScreen({super.key});

  @override
  State<SelectContactScreen> createState() => _SelectContactScreenState();
}

class _SelectContactScreenState extends State<SelectContactScreen> {
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
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        color: bgColor,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                color: bgColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                      onPressed: () {
                        if (_isSearching) {
                          setState(() {
                            _isSearching = false;
                            _searchController.clear();
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    Expanded(
                      child: _isSearching
                          ? SettingsSearchBar(
                              hintText: 'Search name or number...',
                              controller: _searchController,
                              onChanged: (value) => setState(() {}),
                              onClose: () {
                                setState(() {
                                  _isSearching = false;
                                  _searchController.clear();
                                });
                              },
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Select contact',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '0 contacts',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    if (!_isSearching) ...[
                      IconButton(
                        icon: Icon(Icons.search, color: colorScheme.onSurface),
                        onPressed: () => setState(() => _isSearching = true),
                      ),
                      IconButton(
                        icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
                        onPressed: () {},
                      ),
                    ],
                  ],
                ),
              ),

              _buildOptionTile(
                icon: Icons.group_add_outlined,
                title: 'New group',
                onTap: () => _navigateToNewGroup(context),
              ),

              _buildOptionTile(
                icon: Icons.person_add_outlined,
                title: 'New contact',
                onTap: () {},
              ),

              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colorScheme.onSurface.withOpacity(0.1),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Contacts on HeloGram',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: _isSearching && _searchController.text.isNotEmpty
                    ? Center(
                        child: Text(
                          'Searching: ${_searchController.text}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          'No contacts yet',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToNewGroup(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => Container(
          color: bgColor,
          child: const NewGroupScreen(),
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

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      splashColor: colorScheme.primary.withOpacity(0.3),
      highlightColor: colorScheme.primary.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF767F93) 
                    : colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDark 
                    ? Colors.white 
                    : colorScheme.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}