import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum MediaType { image, video }

class ChatInputBar extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textMuted;
  final Color iconColor;
  final Color actionBtnBg;
  final Color actionBtnIcon;
  final Color? themeColor;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText;
  final VoidCallback onEmojiToggle;
  final VoidCallback onAttach;
  final VoidCallback onSend;
  final VoidCallback onVoice;
  final ValueChanged<String> onChanged;
  final Function(File file, MediaType type)? onMediaPicked;
  final VoidCallback? onCamera; // 👈 YEH ADD KIYA — direct camera screen ke liye

  const ChatInputBar({
    Key? key,
    required this.isDark,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textMuted,
    required this.iconColor,
    required this.actionBtnBg,
    required this.actionBtnIcon,
    this.themeColor,
    required this.controller,
    required this.focusNode,
    required this.hasText,
    required this.onEmojiToggle,
    required this.onAttach,
    required this.onSend,
    required this.onVoice,
    required this.onChanged,
    this.onMediaPicked,
    this.onCamera, // 👈 YEH ADD KIYA
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color effectiveIconColor = isDark ? Colors.white : Colors.grey.shade600;
    final Color effectiveBtnBg = themeColor ?? actionBtnBg;
    final Color effectiveBtnIcon = themeColor != null ? Colors.white : actionBtnIcon;
    final Color fieldBg = isDark ? surfaceColor.withOpacity(0.5) : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 1),
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: fieldBg,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: 5,
                  minLines: 1,
                  style: TextStyle(
                    color: textPrimary,
                    fontFamily: 'Poppins',
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fieldBg,
                    hintText: 'Send a message...',
                    hintStyle: TextStyle(
                      color: textMuted,
                      fontFamily: 'Poppins',
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    prefixIcon: IconButton(
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: effectiveIconColor,
                        size: 24,
                      ),
                      splashRadius: 24,
                      onPressed: onEmojiToggle,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.attach_file,
                            color: effectiveIconColor,
                            size: 24,
                          ),
                          onPressed: onAttach,
                        ),
                        // 👇 CAMERA ICON — ab direct custom camera khulegi
                        IconButton(
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            color: effectiveIconColor,
                            size: 24,
                          ),
                          onPressed: onCamera ?? () => _openMediaPicker(context), // 👈 FIX
                        ),
                      ],
                    ),
                  ),
                  onChanged: onChanged,
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: hasText ? onSend : onVoice,
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.only(bottom: 1),
                decoration: BoxDecoration(
                  color: effectiveBtnBg,
                  shape: BoxShape.circle,
                  boxShadow: themeColor != null
                      ? [
                          BoxShadow(
                            color: themeColor!.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  hasText ? Icons.send : Icons.mic,
                  color: effectiveBtnIcon,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 👇 Fallback — agar onCamera null ho toh purani sheet ayegi
  void _openMediaPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _MediaPickerSheet(
        onMediaPicked: onMediaPicked,
      ),
    );
  }
}

// ============================================
// 👇 YEH PURANI SHEET HAI — ab sirf fallback ke liye
// ============================================
class _MediaPickerSheet extends StatelessWidget {
  final Function(File file, MediaType type)? onMediaPicked;
  final ImagePicker _picker = ImagePicker();

  _MediaPickerSheet({this.onMediaPicked});

  Future<void> _pickFromGallery(BuildContext context) async {
    Navigator.pop(context);
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (picked != null && onMediaPicked != null) {
        onMediaPicked!(File(picked.path), MediaType.image);
      }
    } catch (e) {
      _showError(context, 'Gallery error: $e');
    }
  }

  Future<void> _pickVideoFromGallery(BuildContext context) async {
    Navigator.pop(context);
    try {
      final XFile? picked = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (picked != null && onMediaPicked != null) {
        onMediaPicked!(File(picked.path), MediaType.video);
      }
    } catch (e) {
      _showError(context, 'Video error: $e');
    }
  }

  Future<void> _capturePhoto(BuildContext context) async {
    Navigator.pop(context);
    try {
      final XFile? captured = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (captured != null && onMediaPicked != null) {
        onMediaPicked!(File(captured.path), MediaType.image);
      }
    } catch (e) {
      _showError(context, 'Camera error: $e');
    }
  }

  Future<void> _recordVideo(BuildContext context) async {
    Navigator.pop(context);
    try {
      final XFile? recorded = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 2),
        preferredCameraDevice: CameraDevice.rear,
      );
      if (recorded != null && onMediaPicked != null) {
        onMediaPicked!(File(recorded.path), MediaType.video);
      }
    } catch (e) {
      _showError(context, 'Record error: $e');
    }
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Share Media',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _PickerOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: Colors.purple,
                    onTap: () => _pickFromGallery(context),
                  ),
                  _PickerOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: Colors.red,
                    onTap: () => _capturePhoto(context),
                  ),
                  _PickerOption(
                    icon: Icons.videocam_rounded,
                    label: 'Video',
                    color: Colors.blue,
                    onTap: () => _pickVideoFromGallery(context),
                  ),
                  _PickerOption(
                    icon: Icons.videocam_off_rounded,
                    label: 'Record',
                    color: Colors.orange,
                    onTap: () => _recordVideo(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}