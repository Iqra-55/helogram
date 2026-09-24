import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

// ============================================
// 📦 DEPENDENCIES (pubspec.yaml)
// ============================================
// dependencies:
//   image_picker: ^1.1.2
//   file_picker: ^8.1.0

enum AttachmentType {
  image,
  video,
  audio,
  document,
  location,
  contact,
  file,
}

class AttachmentBottomSheet {
  static Future<void> show({
    required BuildContext context,
    required Function(AttachmentType type, File? file, String? path)
        onAttachmentSelected,
    VoidCallback? onCameraTap,
  }) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (ctx) => _AttachmentSheetContent(
        onAttachmentSelected: onAttachmentSelected,
        onCameraTap: onCameraTap,
      ),
    );
  }
}

class _AttachmentSheetContent extends StatefulWidget {
  final Function(AttachmentType type, File? file, String? path)
      onAttachmentSelected;
  final VoidCallback? onCameraTap;

  const _AttachmentSheetContent({
    required this.onAttachmentSelected,
    this.onCameraTap,
  });

  @override
  State<_AttachmentSheetContent> createState() =>
      _AttachmentSheetContentState();
}

class _AttachmentSheetContentState extends State<_AttachmentSheetContent> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromGallery() async {
    Navigator.pop(context);
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (picked != null) {
      widget.onAttachmentSelected(
        AttachmentType.image,
        File(picked.path),
        picked.path,
      );
    }
  }

  Future<void> _captureFromCamera() async {
    Navigator.pop(context);
    if (widget.onCameraTap != null) {
      widget.onCameraTap!();
      return;
    }
    final XFile? captured = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (captured != null) {
      widget.onAttachmentSelected(
        AttachmentType.image,
        File(captured.path),
        captured.path,
      );
    }
  }

  Future<void> _pickVideo() async {
    Navigator.pop(context);
    final XFile? picked = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );
    if (picked != null) {
      widget.onAttachmentSelected(
        AttachmentType.video,
        File(picked.path),
        picked.path,
      );
    }
  }

  Future<void> _recordAudio() async {
    Navigator.pop(context);
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      widget.onAttachmentSelected(
        AttachmentType.audio,
        File(result.files.single.path!),
        result.files.single.path,
      );
    }
  }

  Future<void> _pickDocument() async {
    Navigator.pop(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt'],
    );
    if (result != null && result.files.single.path != null) {
      widget.onAttachmentSelected(
        AttachmentType.document,
        File(result.files.single.path!),
        result.files.single.path,
      );
    }
  }

  Future<void> _shareLocation() async {
    Navigator.pop(context);
    widget.onAttachmentSelected(AttachmentType.location, null, null);
  }

  Future<void> _shareContact() async {
    Navigator.pop(context);
    widget.onAttachmentSelected(AttachmentType.contact, null, null);
  }

  Future<void> _pickAnyFile() async {
    Navigator.pop(context);
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      widget.onAttachmentSelected(
        AttachmentType.file,
        File(result.files.single.path!),
        result.files.single.path,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0B141A);
    const Color cardColor = Color(0xFF1F2C34);
    const Color accentGreen = Color(0xFF00A884);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.97),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Fake Message Input Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.white.withOpacity(0.5), // 👈 FIX
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Message...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.attach_file,
                        color: Colors.white.withOpacity(0.5), // 👈 FIX
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: const BoxDecoration(
                          color: accentGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // First Row: Gallery | Camera | Video | Audio
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _AttachOption(
                      icon: Icons.photo_rounded,
                      label: 'Gallery',
                      bgColor: accentGreen.withOpacity(0.12),
                      iconColor: accentGreen,
                      isHighlighted: true,
                      onTap: _pickImageFromGallery,
                    ),
                    _AttachOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      bgColor: cardColor,
                      iconColor: const Color(0xFFEF4444),
                      onTap: _captureFromCamera,
                    ),
                    _AttachOption(
                      icon: Icons.videocam_rounded,
                      label: 'Video',
                      bgColor: cardColor,
                      iconColor: const Color(0xFF8B5CF6),
                      onTap: _pickVideo,
                    ),
                    _AttachOption(
                      icon: Icons.mic_rounded,
                      label: 'Audio Note',
                      bgColor: cardColor,
                      iconColor: const Color(0xFFF59E0B),
                      onTap: _recordAudio,
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Second Row: Document | Location | Contact | File
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _AttachOption(
                      icon: Icons.insert_drive_file_rounded,
                      label: 'Document',
                      bgColor: cardColor,
                      iconColor: const Color(0xFF3B82F6),
                      onTap: _pickDocument,
                    ),
                    _AttachOption(
                      icon: Icons.location_on_rounded,
                      label: 'Location',
                      bgColor: cardColor,
                      iconColor: const Color(0xFF10B981),
                      onTap: _shareLocation,
                    ),
                    _AttachOption(
                      icon: Icons.person_rounded,
                      label: 'Contact',
                      bgColor: cardColor,
                      iconColor: const Color(0xFF06B6D4),
                      onTap: _shareContact,
                    ),
                    _AttachOption(
                      icon: Icons.folder_rounded,
                      label: 'File',
                      bgColor: cardColor,
                      iconColor: const Color(0xFF6366F1),
                      onTap: _pickAnyFile,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Recent Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: accentGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Recent Items (Horizontal)
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _RecentThumb(
                        color: Colors.blueGrey.shade700,
                        label: '12',
                        onTap: _pickImageFromGallery,
                      ),
                      _RecentThumb(
                        color: Colors.orange.shade800,
                        label: '08',
                        icon: Icons.videocam,
                        onTap: _pickVideo,
                      ),
                      _RecentPdfThumb(
                        title: 'Project\nProposal.pdf',
                        size: '2.4 MB',
                        onTap: _pickDocument,
                      ),
                      _RecentThumb(
                        color: Colors.green.shade800,
                        label: '24',
                        onTap: _pickImageFromGallery,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== WIDGETS ====================

class _AttachOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  State<_AttachOption> createState() => _AttachOptionState();
}

class _AttachOptionState extends State<_AttachOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: widget.bgColor,
                borderRadius: BorderRadius.circular(22),
                border: widget.isHighlighted
                    ? Border.all(
                        color: widget.iconColor.withOpacity(0.4),
                        width: 1.5,
                      )
                    : null,
                boxShadow: widget.isHighlighted
                    ? [
                        BoxShadow(
                          color: widget.iconColor.withOpacity(0.25),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentThumb extends StatelessWidget {
  final Color color;
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _RecentThumb({
    required this.color,
    required this.label,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        height: 100,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            if (icon != null)
              Center(
                child: Icon(icon, color: Colors.white.withOpacity(0.3), size: 28), // 👈 FIX
              ),
            Positioned(
              bottom: 6,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentPdfThumb extends StatelessWidget {
  final String title;
  final String size;
  final VoidCallback onTap;

  const _RecentPdfThumb({
    required this.title,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        height: 100,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2C34),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PDF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              size,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}