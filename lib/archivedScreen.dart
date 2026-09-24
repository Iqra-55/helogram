import 'package:flutter/material.dart';
import '/services/chat_data_service(archived).dart';

class ArchivedScreen extends StatefulWidget {
  const ArchivedScreen({super.key});

  @override
  State<ArchivedScreen> createState() => _ArchivedScreenState();
}

class _ArchivedScreenState extends State<ArchivedScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final archived = ChatDataService.archivedUsers;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Archived',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: archived.isEmpty
          ? Center(
              child: Text(
                'No archived chats',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            )
          : ListView.builder(
              itemCount: archived.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final user = archived[index];
                final userId = user['_id'] ?? '';
                final isUserOnline = user['online'] == true;

                return InkWell(
                  onTap: () {
                    // Restore chat back to main screen
                    ChatDataService.restoreUser(user);
                    Navigator.pop(context);
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: isDark
                              ? const Color(0xFF2A2F3A)
                              : const Color(0xFFE8ECF1),
                          child: Icon(
                            Icons.person,
                            color: isDark
                                ? const Color(0xFF767F93)
                                : const Color(0xFF8B95A5),
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
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      'Tap to restore',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.unarchive, color: colorScheme.onSurface.withOpacity(0.6)),
                      onPressed: () {
                        setState(() {
                          ChatDataService.restoreUser(user);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
