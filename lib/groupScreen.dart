import 'package:flutter/material.dart';
import 'searchBar.dart';
import 'groupCreationScreen.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<Map<String, dynamic>> _selectedContacts = [];

  final List<Map<String, dynamic>> _contacts = [
    {'name': 'iqra hussain', 'status': 'Hey there! I am using HeloGram', 'avatar': null},
    {'name': 'Saba azam', 'status': 'Busy', 'avatar': null},
    {'name': 'zainab zahra', 'status': 'At work', 'avatar': null},
    {'name': 'zainab fatima', 'status': 'Available', 'avatar': null},
    {'name': 'mano billi', 'status': 'In a meeting', 'avatar': null},
    {'name': 'sara mustafa', 'status': 'Sleeping', 'avatar': null},
    {'name': 'ghazala muqadas', 'status': 'Urgent calls only', 'avatar': null},
    {'name': 'Noor fatima', 'status': 'Hey there! I am using HeloGram', 'avatar': null},
    {'name': 'emaan fatima', 'status': 'At gym', 'avatar': null},
    {'name': 'Maryam shah', 'status': 'Studying', 'avatar': null},
  ];

  List<Map<String, dynamic>> get _filteredContacts {
    if (_searchQuery.isEmpty) return _contacts;
    return _contacts.where((c) {
      return c['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  bool _isSelected(Map<String, dynamic> contact) {
    return _selectedContacts.any((c) => c['name'] == contact['name']);
  }

  void _toggleContact(Map<String, dynamic> contact) {
    setState(() {
      if (_isSelected(contact)) {
        _selectedContacts.removeWhere((c) => c['name'] == contact['name']);
      } else {
        _selectedContacts.add(contact);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_selectedContacts.isNotEmpty) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildDiscardDialog(),
      );
      return result ?? false;
    }
    return true;
  }

  Widget _buildDiscardDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discard group?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: textColor, // FIXED
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your changes won't be saved if you leave before creating the group.",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                color: textColor.withOpacity(0.6), // FIXED
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text(
                    'Discard group',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // FIXED: Text color - navy blue/black in light theme, white in dark theme
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    final Color lightPrimary = const Color(0xFFE0E3E8);
    final Color darkText = const Color(0xFF2D3142);
    final Color chipTextColor = isDark ? Colors.white : darkText;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          Navigator.of(context).pop();
        }
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
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Group',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: textColor, // FIXED
                ),
              ),
              if (_selectedContacts.isNotEmpty)
                Text(
                  '${_selectedContacts.length} of ${_contacts.length} selected',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: textColor.withOpacity(0.6), // FIXED
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SettingsSearchBar(
                hintText: 'Search contacts',
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onClose: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
            ),

            if (_selectedContacts.isNotEmpty)
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _selectedContacts[index];
                    return _buildSelectedChip(contact, colorScheme, lightPrimary, chipTextColor);
                  },
                ),
              ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  Text(
                    'Contacts on HeloGram',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: textColor.withOpacity(0.5), // FIXED
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_filteredContacts.length}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: textColor.withOpacity(0.4), // FIXED
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            Expanded(
              child: _filteredContacts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: textColor.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'No contacts found',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: textColor.withOpacity(0.6), // FIXED
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredContacts.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final contact = _filteredContacts[index];
                        return _buildContactTile(contact, colorScheme, lightPrimary, darkText, textColor);
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: _selectedContacts.isNotEmpty
            ? FloatingActionButton(
                onPressed: () => _navigateToGroupCreation(context),
                backgroundColor: lightPrimary,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: darkText,
                  size: 28,
                ),
              )
            : null,
      ),
    );
  }

    void _navigateToGroupCreation(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => Container(
          color: bgColor,
          child: GroupCreationScreen(
            selectedMembers: _selectedContacts,
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

  Widget _buildSelectedChip(Map<String, dynamic> contact, ColorScheme colorScheme, Color lightPrimary, Color chipTextColor) {
    return Container(
      width: 64,
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              _buildAvatar(contact, colorScheme, radius: 26, lightPrimary: lightPrimary),
              Positioned(
                right: -2,
                top: -2,
                child: GestureDetector(
                  onTap: () => _toggleContact(contact),
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.onSurface.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 12,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            contact['name'].toString().split(' ')[0],
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: chipTextColor,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(Map<String, dynamic> contact, ColorScheme colorScheme, Color lightPrimary, Color darkText, Color textColor) {
    final isSelected = _isSelected(contact);

    return InkWell(
      onTap: () => _toggleContact(contact),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _buildAvatar(contact, colorScheme, radius: 26, lightPrimary: lightPrimary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact['name'],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor, // FIXED
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact['status'],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: textColor.withOpacity(0.5), // FIXED
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? lightPrimary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? lightPrimary
                      : colorScheme.onSurface.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: darkText,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> contact, ColorScheme colorScheme, {required double radius, required Color lightPrimary}) {
    final avatarUrl = contact['avatar'];

    if (avatarUrl != null && avatarUrl.toString().isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarUrl.toString()),
        backgroundColor: lightPrimary.withOpacity(0.15),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: lightPrimary.withOpacity(0.15),
      child: Text(
        contact['name'][0],
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }
}
