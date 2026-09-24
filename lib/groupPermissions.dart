
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupPermissionsScreen extends StatefulWidget {
  final bool editGroupSettings;
  final bool sendMessages;
  final bool addOtherMembers;
  final bool inviteViaLink;
  final bool approveNewMembers;

  const GroupPermissionsScreen({
    super.key,
    this.editGroupSettings = true,
    this.sendMessages = true,
    this.addOtherMembers = true,
    this.inviteViaLink = false,
    this.approveNewMembers = false,
  });

  @override
  State<GroupPermissionsScreen> createState() => _GroupPermissionsScreenState();
}

class _GroupPermissionsScreenState extends State<GroupPermissionsScreen> {
  late bool _editGroupSettings;
  late bool _sendMessages;
  late bool _addOtherMembers;
  late bool _inviteViaLink;
  late bool _approveNewMembers;

  @override
  void initState() {
    super.initState();
    _editGroupSettings = widget.editGroupSettings;
    _sendMessages = widget.sendMessages;
    _addOtherMembers = widget.addOtherMembers;
    _inviteViaLink = widget.inviteViaLink;
    _approveNewMembers = widget.approveNewMembers;
  }

  Map<String, bool> _getCurrentState() {
    return {
      'editGroupSettings': _editGroupSettings,
      'sendMessages': _sendMessages,
      'addOtherMembers': _addOtherMembers,
      'inviteViaLink': _inviteViaLink,
      'approveNewMembers': _approveNewMembers,
    };
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
      canPop: false,
      // FIXED: Phone back button se bhi state save hogi
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Phone back button press pe state return karo
        Navigator.of(context).pop(_getCurrentState());
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
              // Arrow back se state return
              Navigator.pop(context, _getCurrentState());
            },
          ),
          title: Text(
            'Group permissions',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Members can:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: textColor.withOpacity(0.5),
                ),
              ),
            ),

            _buildToggleTile(
              icon: Icons.edit,
              title: 'Edit group settings',
              subtitle: 'This includes the name, icon, description, disappearing message timer, and the ability to pin, keep or unkeep messages.',
              value: _editGroupSettings,
              onChanged: (val) => setState(() => _editGroupSettings = val),
              lightPrimary: lightPrimary,
              darkText: darkText,
              textColor: textColor,
            ),

            const SizedBox(height: 16),

            _buildToggleTile(
              icon: Icons.chat_bubble_outline,
              title: 'Send new messages',
              subtitle: '',
              value: _sendMessages,
              onChanged: (val) => setState(() => _sendMessages = val),
              lightPrimary: lightPrimary,
              darkText: darkText,
              textColor: textColor,
            ),

            const SizedBox(height: 16),

            _buildToggleTile(
              icon: Icons.person_add_outlined,
              title: 'Add other members',
              subtitle: '',
              value: _addOtherMembers,
              onChanged: (val) => setState(() => _addOtherMembers = val),
              lightPrimary: lightPrimary,
              darkText: darkText,
              textColor: textColor,
            ),

            const SizedBox(height: 16),

            _buildToggleTile(
              icon: Icons.link,
              title: 'Invite via link or QR code',
              subtitle: '',
              value: _inviteViaLink,
              onChanged: (val) => setState(() => _inviteViaLink = val),
              lightPrimary: lightPrimary,
              darkText: darkText,
              textColor: textColor,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
              child: Text(
                'Admins can:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: textColor.withOpacity(0.5),
                ),
              ),
            ),

            _buildToggleTile(
              icon: Icons.person_outline,
              title: 'Approve new members',
              subtitle: 'When turned on, admins must approve anyone who wants to join the group.',
              value: _approveNewMembers,
              onChanged: (val) => setState(() => _approveNewMembers = val),
              showLearnMore: true,
              lightPrimary: lightPrimary,
              darkText: darkText,
              textColor: textColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showLearnMore = false,
    required Color lightPrimary,
    required Color darkText,
    required Color textColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          padding: const EdgeInsets.only(top: 4),
          child: Icon(
            icon,
            color: textColor.withOpacity(0.6),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),

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
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: textColor.withOpacity(0.5),
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(text: subtitle),
                        if (showLearnMore)
                          TextSpan(
                            text: ' Learn more',
                            style: TextStyle(
                              color: darkText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: darkText,
          activeTrackColor: lightPrimary,
          inactiveThumbColor: colorScheme.onSurface.withOpacity(0.5),
          inactiveTrackColor: colorScheme.onSurface.withOpacity(0.2),
        ),
      ],
    );
  }
}
