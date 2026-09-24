import 'dart:ui';
import 'package:flutter/material.dart';
import '../apptheme.dart';
import '../services/chat_theme_screen.dart';
import 'dissappearing_screen.dart';
import '../services/media_links_docs_sheet.dart';

class ChatMenuSheet extends StatelessWidget {
  final String receiverId;
  final String receiverName;
  final String? receiverAvatar;
  final VoidCallback onClearChat;
  final VoidCallback onBlockUser;
  final bool isMuted;
  final Function(bool) onMuteToggle;

  const ChatMenuSheet({
    Key? key,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
    required this.onClearChat,
    required this.onBlockUser,
    this.isMuted = false,
    required this.onMuteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkLightText : AppTheme.lightDarkText;
    final textSecondary = isDark ? AppTheme.darkNavInactive : AppTheme.lightNavInactive;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1D21).withOpacity(0.82)
                : const Color(0xFFFFFFFF).withOpacity(0.78),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.12)
                  : Colors.white.withOpacity(0.5),
              width: 1.2,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.35)
                          : Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: textSecondary.withOpacity(0.15),
                        backgroundImage: receiverAvatar != null ? NetworkImage(receiverAvatar!) : null,
                        child: receiverAvatar == null
                            ? Icon(Icons.person, color: textSecondary, size: 24)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              receiverName,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              'Online',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: dividerColor, height: 24, indent: 20, endIndent: 20),
                _buildMenuItem(
                  context: context,
                  icon: Icons.person_outline,
                  title: 'View Contact',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () => Navigator.pop(context),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.image_outlined,
                  title: 'Media, Links & Docs',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MediaLinksDocsScreen(receiverName: receiverName),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: isMuted ? Icons.notifications_off_outlined : Icons.notifications_outlined,
                  title: isMuted ? 'Unmute Notifications' : 'Mute Notifications',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  trailing: Switch(
                    value: isMuted,
                    onChanged: (val) {
                      onMuteToggle(val);
                      Navigator.pop(context);
                    },
                    activeColor: isDark ? AppTheme.darkNavActive : AppTheme.lightNavActive,
                  ),
                  onTap: () {
                    onMuteToggle(!isMuted);
                    Navigator.pop(context);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.timer_outlined,
                  title: 'Disappearing Messages',
                  subtitle: 'Off',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DisappearingMessagesScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.color_lens_outlined,
                  title: 'Chat Theme',
                  subtitle: 'Change wallpaper & colors',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () {
                    Navigator.pop(context, 'theme');
                  },
                ),
                Divider(color: dividerColor, height: 24, indent: 20, endIndent: 20),
                _buildMenuItem(
                  context: context,
                  icon: Icons.delete_outline,
                  title: 'Clear Chat',
                  textPrimary: isDark ? AppTheme.darkNavActive : Colors.redAccent,
                  textSecondary: textSecondary,
                  onTap: () {
                    Navigator.pop(context);
                    _showClearChatDialog(context, isDark, textPrimary);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.block,
                  title: 'Block $receiverName',
                  textPrimary: isDark ? AppTheme.darkNavActive : Colors.redAccent,
                  textSecondary: textSecondary,
                  onTap: () {
                    Navigator.pop(context);
                    _showBlockDialog(context, isDark, receiverName);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required Color textPrimary,
    required Color textSecondary,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textPrimary, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            )
          : null,
      trailing: trailing ?? Icon(Icons.chevron_right, color: textSecondary, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      minVerticalPadding: 12,
    );
  }

  void _showClearChatDialog(BuildContext context, bool isDark, Color textPrimary) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1D21).withOpacity(0.95) : const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear Chat?',
          style: TextStyle(
            color: textPrimary,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'All messages will be deleted. This action cannot be undone.',
          style: TextStyle(
            color: isDark ? AppTheme.darkNavInactive : AppTheme.lightNavInactive,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppTheme.darkNavInactive : AppTheme.lightNavInactive,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // ✅ Yahan se parent ko call jata hai — parent mein actual delete logic likho
              onClearChat();
            },
            child: Text(
              'Clear',
              style: TextStyle(
                color: isDark ? AppTheme.darkNavActive : Colors.redAccent,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(BuildContext context, bool isDark, String name) {
    final textPrimary = isDark ? AppTheme.darkLightText : AppTheme.lightDarkText;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1D21).withOpacity(0.95) : const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Block $name?',
          style: TextStyle(
            color: textPrimary,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Blocked contacts will no longer be able to call you or send you messages.',
          style: TextStyle(
            color: isDark ? AppTheme.darkNavInactive : AppTheme.lightNavInactive,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppTheme.darkNavInactive : AppTheme.lightNavInactive,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onBlockUser();
            },
            child: Text(
              'Block',
              style: TextStyle(
                color: isDark ? AppTheme.darkNavActive : Colors.redAccent,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
