import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

// ============================================
// 📦 REQUIRED DEPENDENCIES (pubspec.yaml)
// ============================================
// dependencies:
//   image_picker: ^1.1.2
//   photo_view: ^0.14.0
//
// iOS ke liye Info.plist mein ye permissions add karein:
// <key>NSPhotoLibraryUsageDescription</key>
// <string>We need access to photos to share in chat</string>
// <key>NSCameraUsageDescription</key>
// <string>We need camera access to take photos</string>
// <key>NSMicrophoneUsageDescription</key>
// <string>We need microphone for video recording</string>

// ============================================
// 1️⃣ MEDIA PICKER BOTTOM SHEET (Premium UI)
// ============================================
enum MediaType { image, video }

class MediaPickerSheet {
  static Future<void> show({
    required BuildContext context,
    required Function(File file, MediaType type) onMediaPicked,
    Color? themeColor,
  }) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => _MediaPickerContent(
        onMediaPicked: onMediaPicked,
        themeColor: themeColor,
      ),
    );
  }
}

class _MediaPickerContent extends StatelessWidget {
  final Function(File file, MediaType type) onMediaPicked;
  final Color? themeColor;

  _MediaPickerContent({
    required this.onMediaPicked,
    this.themeColor,
  });

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery(BuildContext context) async {
    Navigator.pop(context);
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (picked != null) onMediaPicked(File(picked.path), MediaType.image);
  }

  Future<void> _pickVideoFromGallery(BuildContext context) async {
    Navigator.pop(context);
    final XFile? picked = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );
    if (picked != null) onMediaPicked(File(picked.path), MediaType.video);
  }

  Future<void> _capturePhoto(BuildContext context) async {
    Navigator.pop(context);
    final XFile? captured = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (captured != null) onMediaPicked(File(captured.path), MediaType.image);
  }

  Future<void> _recordVideo(BuildContext context) async {
    Navigator.pop(context);
    final XFile? recorded = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 2),
      preferredCameraDevice: CameraDevice.rear,
    );
    if (recorded != null) onMediaPicked(File(recorded.path), MediaType.video);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final Color subTextColor = isDark ? Colors.white60 : Colors.black54;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 36,
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
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    fontFamily: 'Poppins',
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose what you want to share',
                  style: TextStyle(
                    fontSize: 13,
                    color: subTextColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _PickerOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      gradient: const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                      onTap: () => _pickFromGallery(context),
                    ),
                    _PickerOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      gradient: const [Color(0xFFEF4444), Color(0xFFF97316)],
                      onTap: () => _capturePhoto(context),
                    ),
                    _PickerOption(
                      icon: Icons.videocam_rounded,
                      label: 'Video',
                      gradient: const [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                      onTap: () => _pickVideoFromGallery(context),
                    ),
                    _PickerOption(
                      icon: Icons.videocam_off_rounded,
                      label: 'Record',
                      gradient: const [Color(0xFFF59E0B), Color(0xFFEC4899)],
                      onTap: () => _recordVideo(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_PickerOption> createState() => _PickerOptionState();
}

class _PickerOptionState extends State<_PickerOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient.last.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(widget.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// 2️⃣ CHAT IMAGE BUBBLE (Premium Theme-Matching)
// ============================================
class ChatImageBubble extends StatelessWidget {
  final File imageFile;
  final bool isMe;
  final String? caption;
  final DateTime? timestamp;
  final Color? themeColor;

  const ChatImageBubble({
    Key? key,
    required this.imageFile,
    required this.isMe,
    this.caption,
    this.timestamp,
    this.themeColor,
  }) : super(key: key);

  String get _heroTag => 'chat_image_${imageFile.path}_${key.hashCode}';

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bubbleColor = themeColor ?? (isMe
        ? (isDark ? const Color(0xFF2A2D32) : const Color(0xFFDCF8C6))
        : (isDark ? const Color(0xFF2A2D32) : Colors.white));

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 60 : 12,
          right: isMe ? 12 : 60,
          top: 3,
          bottom: 3,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Container
            GestureDetector(
              onTap: () => _openFullScreen(context),
              child: Hero(
                tag: _heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.68,
                      maxHeight: MediaQuery.of(context).size.height * 0.42,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                      frameBuilder: (
                        BuildContext context,
                        Widget child,
                        int? frame,
                        bool wasSynchronouslyLoaded,
                      ) {
                        if (wasSynchronouslyLoaded || frame != null) {
                          return child;
                        }
                        return _buildLoadingShimmer(isDark);
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _buildErrorState(isDark);
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Caption + Timestamp row
            if ((caption != null && caption!.isNotEmpty) || timestamp != null)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 4, right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (caption != null && caption!.isNotEmpty)
                      Flexible(
                        child: Text(
                          caption!,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white.withOpacity(0.85) : Colors.black87,
                            fontFamily: 'Poppins',
                            height: 1.3,
                          ),
                        ),
                      ),
                    if (timestamp != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(timestamp!),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer(bool isDark) {
    return Container(
      width: 220,
      height: 220,
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: themeColor ?? (isDark ? Colors.white38 : Colors.black26),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Container(
      width: 220,
      height: 160,
      color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_rounded,
            color: isDark ? Colors.white24 : Colors.black26,
            size: 44,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load',
            style: TextStyle(
              color: isDark ? Colors.white30 : Colors.black38,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  void _openFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(
          imageFile: imageFile,
          heroTag: _heroTag,
          caption: caption,
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }
}

// ============================================
// 3️⃣ FULL SCREEN IMAGE VIEWER (Immersive)
// ============================================
class FullScreenImageViewer extends StatefulWidget {
  final File imageFile;
  final String heroTag;
  final String? caption;

  const FullScreenImageViewer({
    Key? key,
    required this.imageFile,
    required this.heroTag,
    this.caption,
  }) : super(key: key);

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer>
    with SingleTickerProviderStateMixin {
  bool _showUI = true;
  late AnimationController _uiController;

  @override
  void initState() {
    super.initState();
    _uiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _uiController.value = 1.0;
  }

  @override
  void dispose() {
    _uiController.dispose();
    super.dispose();
  }

  void _toggleUI() {
    setState(() {
      _showUI = !_showUI;
      if (_showUI) {
        _uiController.forward();
      } else {
        _uiController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showUI
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // PhotoView
          GestureDetector(
            onTap: _toggleUI,
            child: Hero(
              tag: widget.heroTag,
              child: PhotoView(
                imageProvider: FileImage(widget.imageFile),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
                initialScale: PhotoViewComputedScale.contained,
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                loadingBuilder: (context, event) => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.white38, size: 60),
                ),
              ),
            ),
          ),

          // Bottom gradient + caption
          if (widget.caption != null && widget.caption!.isNotEmpty)
            AnimatedBuilder(
              animation: _uiController,
              builder: (context, child) {
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: _uiController.value,
                    child: IgnorePointer(
                      ignoring: !_showUI,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          30,
                          20,
                          MediaQuery.of(context).padding.bottom + 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.85),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Text(
                          widget.caption!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ============================================
// 4️⃣ CHAT VIDEO BUBBLE (Premium)
// ============================================
class ChatVideoBubble extends StatelessWidget {
  final File videoFile;
  final bool isMe;
  final String? caption;
  final DateTime? timestamp;

  const ChatVideoBubble({
    Key? key,
    required this.videoFile,
    required this.isMe,
    this.caption,
    this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 60 : 12,
          right: isMe ? 12 : 60,
          top: 3,
          bottom: 3,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                // TODO: Video player screen
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.62,
                  height: 220,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade200,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background pattern
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [const Color(0xFF2A2D32), const Color(0xFF1C1C1E)]
                                : [Colors.grey.shade300, Colors.grey.shade200],
                          ),
                        ),
                      ),
                      Center(
                        child: Icon(
                          Icons.videocam_rounded,
                          size: 56,
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                      ),

                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                            ],
                          ),
                        ),
                      ),

                      // Play button
                      Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),

                      // Duration badge
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.videocam,
                                color: Colors.white70,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '0:00',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (caption != null && caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 4, right: 4),
                child: Text(
                  caption!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white.withOpacity(0.85) : Colors.black87,
                    fontFamily: 'Poppins',
                    height: 1.3,
                  ),
                ),
              ),
            if (timestamp != null)
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                child: Text(
                  _formatTime(timestamp!),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }
}