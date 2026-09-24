import 'package:flutter/material.dart';

// ==================== PROFILE SCREEN ====================
class ProfileScreen extends StatefulWidget {
  final String username;
  final String userHandle;
  final String userBio;
  final Function(String, String, String) onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.username,
    required this.userHandle,
    required this.userBio,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _username;
  late String _userHandle;
  late String _userBio;

  @override
  void initState() {
    super.initState();
    _username = widget.username;
    _userHandle = widget.userHandle;
    _userBio = widget.userBio;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onProfileUpdated(_username, _userHandle, _userBio);
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Center(
            child: GestureDetector(
              onTap: () => _showProfilePictureSheet(context),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: colorScheme.primary.withOpacity(0.15),
                        child: Icon(
                          Icons.person,
                          size: 55,
                          color: colorScheme.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _showProfilePictureSheet(context),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          _buildProfileTile(
            icon: Icons.person_outline,
            label: 'Name',
            value: _username,
            onTap: () => _navigateToEditField(
              context,
              title: 'Name',
              value: _username,
              hint: 'Your name',
              maxLength: 25,
              description: "People will see this name if you interact with them and they don't have you saved as a contact.",
              onSave: (val) => setState(() => _username = val),
            ),
          ),

          _buildProfileTile(
            icon: Icons.info_outline,
            label: 'About',
            value: _userBio.isEmpty ? 'Set About' : _userBio,
            valueColor: _userBio.isEmpty ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
            onTap: () => _navigateToEditField(
              context,
              title: 'About',
              value: _userBio,
              hint: 'About',
              maxLength: 139,
              description: '',
              onSave: (val) => setState(() => _userBio = val),
            ),
          ),

          _buildProfileTile(
            icon: Icons.alternate_email,
            label: 'Username',
            value: _userHandle.replaceFirst('@', ''),
            onTap: () => _navigateToEditField(
              context,
              title: 'Username',
              value: _userHandle.replaceFirst('@', ''),
              hint: 'Username',
              maxLength: 20,
              description: 'This is your unique username. People can find you using this.',
              onSave: (val) => setState(() => _userHandle = '@$val'),
            ),
          ),

          _buildProfileTile(
            icon: Icons.link_outlined,
            label: 'Links',
            value: 'Add links',
            valueColor: colorScheme.primary,
            onTap: () => _navigateToEditField(
              context,
              title: 'Links',
              value: '',
              hint: 'Add your social links',
              maxLength: 100,
              description: 'Add links to your social profiles.',
              onSave: (val) {},
            ),
          ),

          _buildProfileTile(
            icon: Icons.lock_outline,
            label: 'Change Password',
            value: '',
            showArrow: true,
            onTap: () => _navigateToChangePassword(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool showArrow = false,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: colorScheme.onSurface.withOpacity(0.5),
              size: 22,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (value.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: valueColor ?? colorScheme.onSurface,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.4),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showProfilePictureSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Profile picture',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: colorScheme.onSurface.withOpacity(0.6)),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildPictureOption(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: () {},
              ),
              _buildPictureOption(
                icon: Icons.image_outlined,
                label: 'Gallery',
                onTap: () {},
              ),
              _buildPictureOption(
                icon: Icons.auto_fix_high_outlined,
                label: 'AI images',
                onTap: () {},
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPictureOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
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
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ FIX: No white flash navigation
  void _navigateToEditField(
    BuildContext context, {
    required String title,
    required String value,
    required String hint,
    required int maxLength,
    required String description,
    required Function(String) onSave,
  }) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => Container(
          color: bgColor,
          child: EditFieldScreen(
            title: title,
            value: value,
            hint: hint,
            maxLength: maxLength,
            description: description,
            onSave: onSave,
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

  // ✅ FIX: No white flash navigation
  void _navigateToChangePassword(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => Container(
          color: bgColor,
          child: ChangePasswordScreen(
            onChanged: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Password changed successfully',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
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
}

// ==================== EDIT FIELD SCREEN ====================
class EditFieldScreen extends StatefulWidget {
  final String title;
  final String value;
  final String hint;
  final int maxLength;
  final String description;
  final Function(String) onSave;

  const EditFieldScreen({
    super.key,
    required this.title,
    required this.value,
    required this.hint,
    required this.maxLength,
    required this.description,
    required this.onSave,
  });

  @override
  State<EditFieldScreen> createState() => _EditFieldScreenState();
}

class _EditFieldScreenState extends State<EditFieldScreen> {
  late TextEditingController _controller;
  late int _charCount;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _charCount = widget.value.length;
    _controller.addListener(() {
      setState(() {
        _charCount = _controller.text.length;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest ?? colorScheme.surface,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(
                        Icons.emoji_emotions_outlined,
                        color: colorScheme.onSurface.withOpacity(0.5),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          maxLength: widget.maxLength,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: widget.hint,
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: colorScheme.onSurface.withOpacity(0.3),
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      Text(
                        '${_charCount}/${widget.maxLength}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (widget.description.isNotEmpty)
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.5),
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomPadding + 16),
            child: GestureDetector(
              onTap: () {
                widget.onSave(_controller.text.trim());
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== CHANGE PASSWORD SCREEN ====================
class ChangePasswordScreen extends StatefulWidget {
  final VoidCallback onChanged;

  const ChangePasswordScreen({
    super.key,
    required this.onChanged,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                _buildPasswordField(_currentController, 'Current Password', colorScheme),
                const SizedBox(height: 16),
                _buildPasswordField(_newController, 'New Password', colorScheme),
                const SizedBox(height: 16),
                _buildPasswordField(_confirmController, 'Confirm New Password', colorScheme),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomPadding + 16),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                widget.onChanged();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(
                  child: Text(
                    'Change Password',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, ColorScheme colorScheme) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            Icons.lock_outline,
            color: colorScheme.onSurface.withOpacity(0.4),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: true,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: colorScheme.onSurface.withOpacity(0.3),
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}