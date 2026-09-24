import 'package:flutter/material.dart';
import 'settingscreen.dart';
import 'groupScreen.dart';
import 'linkedDevicesScreen.dart';
import 'broadcastScreen.dart'; 
import 'starred_screen.dart'; // StarredScreen ka import

class ChatMenuOptions {
  static List<PopupMenuItem<String>> buildMenuItems(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return [
      _buildItem('New group', 'new_group', textColor),
      _buildItem('Broadcast lists', 'new_broadcast', textColor),
      _buildItem('Linked devices', 'linked_devices', textColor),
      _buildItem('Starred', 'starred', textColor),
      _buildItem('Read all', 'read_all', textColor),
      _buildItem('Settings', 'settings', textColor),
    ];
  }

  static PopupMenuItem<String> _buildItem(
    String title, 
    String value, 
    Color textColor,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          color: textColor,
        ),
      ),
    );
  }

  static void handleMenuAction(String value, BuildContext context) {
    switch (value) {
      case 'new_group':
        Navigator.push(
          context,
          _buildNoFlashRoute(const NewGroupScreen()),
        );
        break;
      case 'new_broadcast':
        Navigator.push(
          context,
          _buildNoFlashRoute(const BroadcastListScreen()),
        );
        break;
      case 'linked_devices':
        Navigator.push(
          context,
          _buildNoFlashRoute(const LinkedDevicesScreen()),
        );
        break;
      case 'starred':
        // StarredScreen par navigate karne ke liye logic
        Navigator.push(
          context,
          _buildNoFlashRoute(const StarredScreen()),
        );
        break;
      case 'read_all':
        break;
      case 'settings':
        Navigator.push(
          context,
          _buildNoFlashRoute(const SettingsScreen()),
        );
        break;
    }
  }

  static PageRouteBuilder _buildNoFlashRoute(Widget screen) {
    return PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) => Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: screen,
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
    );
  }
}