import 'package:flutter/material.dart';

/// Reusable Search Bar - Settings + Contacts + Any Search dono ke liye
class SettingsSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClose;
  final TextEditingController? controller; // External controller support

  const SettingsSearchBar({
    super.key,
    this.hintText = 'Search settings',
    this.onChanged,
    this.onClose,
    this.controller,
  });

  @override
  State<SettingsSearchBar> createState() => _SettingsSearchBarState();
}

class _SettingsSearchBarState extends State<SettingsSearchBar> {
  late final TextEditingController _internalController;

  TextEditingController get _controller => widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();
  }

  @override
  void dispose() {
    _internalController.dispose();
    super.dispose();
  }

  void clearSearch() {
    _controller.clear();
    widget.onChanged?.call('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final iconColor = colorScheme.onSurface.withOpacity(0.6);
    final barColor = colorScheme.surface;

    return Container(
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
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              cursorColor: textColor,
              decoration: InputDecoration(
                hintText: widget.hintText,
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
              onChanged: (value) {
                widget.onChanged?.call(value);
                setState(() {});
              },
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: clearSearch,
              child: Icon(Icons.close, color: iconColor, size: 20),
            ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
