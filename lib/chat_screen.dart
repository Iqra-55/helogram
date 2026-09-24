import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

// ==================== SERVICES ====================
import 'services/api_services.dart';
import 'services/socket_service.dart';
import 'services/chat_theme_service.dart';
import 'services/chat_storage_service.dart';
import 'apptheme.dart';
import 'services/chat_menu_sheet.dart';
import 'services/chat_theme_screen.dart';
import 'chat_screen_voice.dart';
import 'widgets/voice_record_bar.dart';
import 'chat_calendar_picker.dart';

// ==================== EXTRACTED WIDGETS ====================
import 'chat_app_bars.dart';
import 'chat_input_bar.dart';
import 'chat_message_bubble.dart';
import 'services/sender_bubble.dart';
import 'services/reciever_bubbles.dart';

// ==================== NEW: CAMERA + ATTACHMENT ====================
import 'camera_screen.dart';
import 'attachmentSheet.dart';

// ============================================
// 1️⃣ CHAT IMAGE BUBBLE
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

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 60 : 12,
          right: isMe ? 12 : 60,
          top: 4,
          bottom: 4,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _openFullScreen(context),
              child: Hero(
                tag: _heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.65,
                      maxHeight: MediaQuery.of(context).size.height * 0.45,
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
                        return Container(
                          width: 200,
                          height: 200,
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 150,
                          color: Colors.red.shade50,
                          child: const Icon(
                            Icons.broken_image_rounded,
                            color: Colors.red,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (caption != null && caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
                child: Text(
                  caption!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            if (timestamp != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                child: Text(
                  _formatTime(timestamp!),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
          ],
        ),
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
// 2️⃣ FULL SCREEN IMAGE VIEWER
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
      duration: const Duration(milliseconds: 200),
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
      body: Stack(
        fit: StackFit.expand,
        children: [
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
                  child: Icon(Icons.broken_image, color: Colors.white54, size: 60),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _uiController,
            builder: (context, child) {
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _uiController.value,
                  child: IgnorePointer(
                    ignoring: !_showUI,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 8,
                        right: 8,
                        bottom: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new,
                                color: Colors.white, size: 22),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.share_outlined,
                                color: Colors.white, size: 22),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert,
                                color: Colors.white, size: 22),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.caption != null)
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
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
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
// 3️⃣ CHAT VIDEO BUBBLE
// ============================================
class ChatVideoBubble extends StatefulWidget {
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
  State<ChatVideoBubble> createState() => _ChatVideoBubbleState();
}

class _ChatVideoBubbleState extends State<ChatVideoBubble> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  String _durationText = '0:00';

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.file(widget.videoFile);
    await _controller!.initialize();
    final duration = _controller!.value.duration;
    setState(() {
      _isInitialized = true;
      _durationText = _formatDuration(duration);
    });
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _openVideoPlayer() {
    if (_controller == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _VideoPlayerScreen(
          controller: _controller!,
          caption: widget.caption,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: widget.isMe ? 60 : 12,
          right: widget.isMe ? 12 : 60,
          top: 4,
          bottom: 4,
        ),
        child: Column(
          crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _openVideoPlayer,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 220,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isInitialized)
                        SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller!.value.size.width,
                              height: _controller!.value.size.height,
                              child: VideoPlayer(_controller!),
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.videocam_rounded,
                          size: 60,
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _durationText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.caption != null && widget.caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
                child: Text(
                  widget.caption!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            if (widget.timestamp != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                child: Text(
                  _formatTime(widget.timestamp!),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontFamily: 'Poppins',
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

// ============================================
// VIDEO PLAYER SCREEN
// ============================================
class _VideoPlayerScreen extends StatefulWidget {
  final VideoPlayerController controller;
  final String? caption;

  const _VideoPlayerScreen({
    required this.controller,
    this.caption,
  });

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  bool _showControls = true;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onVideoUpdate);
    widget.controller.setLooping(true);
    _duration = widget.controller.value.duration;
    _position = widget.controller.value.position;
    _isPlaying = widget.controller.value.isPlaying;
  }

  void _onVideoUpdate() {
    if (mounted) {
      setState(() {
        _position = widget.controller.value.position;
        _duration = widget.controller.value.duration;
        _isPlaying = widget.controller.value.isPlaying;
      });
    }
  }

  void _togglePlay() {
    if (_isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes.toString().padLeft(2, '0');
    final secs = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onVideoUpdate);
    widget.controller.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: _toggleControls,
            child: Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),
          ),
          // Top bar
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_showControls,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  right: 8,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
          // Center play button
          AnimatedOpacity(
            opacity: _showControls && !_isPlaying ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_showControls || _isPlaying,
              child: Center(
                child: GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bottom controls
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_showControls,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 32 + MediaQuery.of(context).padding.bottom),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.caption != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            widget.caption!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: _togglePlay,
                          ),
                          Text(
                            _formatDuration(_position),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Expanded(
                            child: Slider(
                              value: _position.inMilliseconds.toDouble().clamp(0, _duration.inMilliseconds.toDouble()),
                              max: _duration.inMilliseconds.toDouble(),
                              activeColor: Colors.white,
                              inactiveColor: Colors.white30,
                              onChanged: (value) {
                                widget.controller.seekTo(
                                  Duration(milliseconds: value.toInt()),
                                );
                              },
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
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

// ============================================
// 4️⃣ CHAT SCREEN
// ============================================
class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String? receiverAvatar;

  const ChatScreen({
    Key? key,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin, ChatVoiceMixin {
  // Controllers
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Message State
  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;
  bool isLoading = true;
  String myUserId = '';
  bool _isSelectionMode = false;
  Set<int> _selectedIndices = {};
  bool _isMuted = false;
  bool _isSearching = false;
  String _searchQuery = '';
  bool _hasText = false;
  bool _isUserOnline = true;
  DateTime? _selectedDate;

  // Theme & Wallpaper
  bool _showEmojiPicker = false;
  late Map<String, dynamic> _activeTheme;
  String? _activeWallpaperId;

  // ===== WALLPAPER EFFECTS =====
  double _wallpaperBlur = 0;
  double _wallpaperBrightness = 0;
  Color _wallpaperTint = Colors.transparent;

  // Route activation tracking for theme reload
  bool _wasActive = false;

  // Scroll position tracking
  bool _isAtBottom = true;

  @override
  void initState() {
    super.initState();

    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark = brightness == Brightness.dark;

    _activeTheme = _defaultTheme(isDark);

    myUserId = ApiService.userId ?? '';

    _scrollController.addListener(_onScroll);

    _loadTheme();
    _loadSavedMessages();
    _setupSocket();
    initVoicePlayer();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && mounted) {
        setState(() => _showEmojiPicker = false);
      }
    });

    _messageController.addListener(() {
      final hasText = _messageController.text.trim().isNotEmpty;
      if (hasText != _hasText && mounted) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    disposeVoicePlayer();
    _focusNode.dispose();
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();

    try {
      SocketService.offAll();
    } catch (e) {}

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      final isActive = route.isCurrent;
      if (isActive && !_wasActive) {
        _loadTheme();
      }
      _wasActive = isActive;
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    final atBottom = maxScroll <= 0 || current >= maxScroll - 80;

    if (atBottom != _isAtBottom && mounted) {
      setState(() => _isAtBottom = atBottom);
    }
  }

  void _jumpToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final max = _scrollController.position.maxScrollExtent;
        if (max > 0) {
          _scrollController.jumpTo(max);
        }
      }
    });
  }

  void _jumpToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _toggleScrollPosition() {
    if (_isAtBottom) {
      _jumpToTop();
    } else {
      _jumpToBottom();
    }
  }

  // ============================================
  // 📎 MEDIA PICKED (Updated with optional caption)
  // ============================================
  void _onMediaPicked(File file, MediaType type, {String? caption}) {
    final newMessage = {
      'senderId': myUserId,
      'message': caption ?? '',
      'type': type == MediaType.image ? 'image' : 'video',
      'mediaPath': file.path,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };
    setState(() => messages.add(newMessage));
    _saveMessages();
    scrollToBottom();
  }

  // ============================================
  // 📎 ATTACHMENT SHEET + CAMERA INTEGRATION
  // ============================================

  void _showAttachmentSheet() {
    AttachmentBottomSheet.show(
      context: context,
      onAttachmentSelected: (type, file, path) {
        switch (type) {
          case AttachmentType.image:
            if (file != null) _onMediaPicked(file, MediaType.image);
            break;
          case AttachmentType.video:
            if (file != null) _onMediaPicked(file, MediaType.video);
            break;
          case AttachmentType.audio:
            _handleAudioAttachment(file, path);
            break;
          case AttachmentType.document:
            _handleDocumentAttachment(file, path);
            break;
          case AttachmentType.location:
            _handleLocationAttachment();
            break;
          case AttachmentType.contact:
            _handleContactAttachment();
            break;
          case AttachmentType.file:
            _handleFileAttachment(file, path);
            break;
        }
      },
      onCameraTap: () => _openCustomCamera(),
    );
  }

  // ============================================
  // 📷 CUSTOM CAMERA (Updated with caption)
  // ============================================
  void _openCustomCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomCameraScreen(
          contactName: widget.receiverName,
          onMediaCaptured: (file, caption, isVideo) {
            _onMediaPicked(
              file,
              isVideo ? MediaType.video : MediaType.image,
              caption: caption,
            );
          },
        ),
      ),
    );
  }

  void _handleAudioAttachment(File? file, String? path) {
    if (file == null) return;
    final newMessage = {
      'senderId': myUserId,
      'message': '',
      'type': 'voice',
      'voicePath': file.path,
      'duration': 0,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };
    setState(() => messages.add(newMessage));
    _saveMessages();
    scrollToBottom();
  }

  void _handleDocumentAttachment(File? file, String? path) {
    if (file == null) return;
    final newMessage = {
      'senderId': myUserId,
      'message': file.path.split('/').last,
      'type': 'document',
      'mediaPath': file.path,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };
    setState(() => messages.add(newMessage));
    _saveMessages();
    scrollToBottom();
  }

  void _handleLocationAttachment() {
    final newMessage = {
      'senderId': myUserId,
      'message': '📍 Location shared',
      'type': 'location',
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };
    setState(() => messages.add(newMessage));
    _saveMessages();
    scrollToBottom();
  }

  void _handleContactAttachment() {
    final newMessage = {
      'senderId': myUserId,
      'message': '👤 Contact shared',
      'type': 'contact',
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };
    setState(() => messages.add(newMessage));
    _saveMessages();
    scrollToBottom();
  }

  void _handleFileAttachment(File? file, String? path) {
    if (file == null) return;
    final newMessage = {
      'senderId': myUserId,
      'message': file.path.split('/').last,
      'type': 'file',
      'mediaPath': file.path,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };
    setState(() => messages.add(newMessage));
    _saveMessages();
    scrollToBottom();
  }

  // ============================================
  // THEME & COLOR HELPERS
  // ============================================

  Color _resolveColor(dynamic value, Color fallback) {
    if (value is Color) return value;
    if (value is int) return Color(value);
    return fallback;
  }

  Color _resolveThemeColor(String key, Color fallback) {
    return _resolveColor(_activeTheme[key], fallback);
  }

  Color _contrastText(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : const Color(0xFF1A1A1A);
  }

  Brightness _wallpaperBrightnessValue(bool isDark) {
    final type = _activeTheme['wallpaperType'] ?? 'solid';
    if (type == 'solid') {
      final color = _resolveColor(
        _activeTheme['wallpaperColor'],
        isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      );
      return ThemeData.estimateBrightnessForColor(color);
    }
    final colors = _activeTheme['wallpaperColors'] as List?;
    if (colors != null && colors.isNotEmpty) {
      final firstColor = _resolveColor(colors[0], Colors.white);
      return ThemeData.estimateBrightnessForColor(firstColor);
    }
    return Brightness.light;
  }

  Map<String, dynamic> _defaultTheme(bool isDark) {
    return isDark
        ? {
            'wallpaperType': 'solid',
            'wallpaperColor': AppTheme.darkBackground,
            'bubbleColor': AppTheme.darkSurface,
            'receiverBubbleColor': const Color(0xFF2A2D32),
          }
        : {
            'wallpaperType': 'solid',
            'wallpaperColor': AppTheme.lightBackground,
            'bubbleColor': AppTheme.lightNavActive,
            'receiverBubbleColor': const Color(0xFFF0EDE5),
          };
  }

  Map<String, dynamic> _normalizeTheme(Map<String, dynamic> theme) {
    final result = Map<String, dynamic>.from(theme);
    const colorKeys = ['wallpaperColor', 'bubbleColor', 'receiverBubbleColor'];
    for (final key in colorKeys) {
      if (result.containsKey(key)) {
        result[key] = _resolveColor(result[key], Colors.transparent);
      }
    }
    if (result.containsKey('wallpaperColors') && result['wallpaperColors'] is List) {
      result['wallpaperColors'] = (result['wallpaperColors'] as List)
          .map((c) => _resolveColor(c, Colors.white))
          .toList();
    }
    return result;
  }

  Future<void> _loadTheme() async {
    try {
      final savedTheme = await ChatThemeService.getActiveTheme(widget.receiverId);
      final savedWallpaperId = await ChatThemeService.getWallpaper(widget.receiverId);
      final settings = await ChatThemeService.getWallpaperSettings(widget.receiverId);

      final isDark = (settings['darkTheme'] as bool?) ??
          SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

      final hasWallpaper = savedWallpaperId != null && savedWallpaperId != 'default';

      if (mounted) {
        setState(() {
          if (hasWallpaper) {
            _activeWallpaperId = savedWallpaperId;
            _activeTheme = _defaultTheme(isDark);
          } else if (savedTheme != null && savedTheme.isNotEmpty) {
            _activeTheme = _normalizeTheme(savedTheme);
            _activeWallpaperId = null;
          } else {
            _activeTheme = _defaultTheme(isDark);
            _activeWallpaperId = null;
          }

          final senderColorVal = settings['senderBubbleColor'] as int?;
          final receiverColorVal = settings['receiverBubbleColor'] as int?;
          if (senderColorVal != null) {
            _activeTheme['bubbleColor'] = Color(senderColorVal);
          }
          if (receiverColorVal != null) {
            _activeTheme['receiverBubbleColor'] = Color(receiverColorVal);
          }

          _wallpaperBlur = (settings['blur'] as num?)?.toDouble() ?? 0.0;
          _wallpaperBrightness = (settings['brightness'] as num?)?.toDouble() ?? 0.0;
          _wallpaperTint = Color((settings['tint'] as int?) ?? Colors.transparent.value);
        });
      }

      if (hasWallpaper && savedTheme != null && savedTheme.isNotEmpty) {
        await ChatThemeService.resetTheme(widget.receiverId);
      }
    } catch (e) {}
  }

  Future<void> _loadSavedMessages() async {
    try {
      final savedMessages =
          await ChatStorageService.loadMessages(widget.receiverId);
      if (mounted) {
        setState(() {
          messages = savedMessages;
          isLoading = false;
        });
        if (messages.isNotEmpty) _jumpToBottom();
      }

      try {
        final apiData = await ApiService.getMessages(widget.receiverId);
        if (mounted && apiData is List && apiData.isNotEmpty) {
          final apiMessages = List<Map<String, dynamic>>.from(apiData);
          final merged = _mergeMessages(apiMessages, savedMessages);

          setState(() => messages = merged);
          await _saveMessages();
          _jumpToBottom();
        }
      } catch (e) {}
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> _mergeMessages(
    List<Map<String, dynamic>> apiMessages,
    List<Map<String, dynamic>> localMessages,
  ) {
    final merged = <Map<String, dynamic>>[];
    final seen = <String>{};

    String makeKey(Map<String, dynamic> msg) {
      final ts = msg['timestamp']?.toString() ?? '';
      final sender = msg['senderId']?.toString() ?? '';
      final text = msg['message']?.toString() ?? '';
      final type = msg['type']?.toString() ?? 'text';
      final media = msg['mediaPath']?.toString() ??
          msg['voicePath']?.toString() ??
          '';
      return '${ts}_${sender}_${text}_${type}_$media';
    }

    for (final msg in apiMessages) {
      final key = makeKey(msg);
      if (!seen.contains(key)) {
        seen.add(key);
        merged.add(Map<String, dynamic>.from(msg));
      }
    }

    for (final msg in localMessages) {
      final key = makeKey(msg);
      if (!seen.contains(key)) {
        seen.add(key);
        merged.add(Map<String, dynamic>.from(msg));
      }
    }

    merged.sort((a, b) {
      final aTime = DateTime.tryParse(a['timestamp']?.toString() ?? '') ??
          DateTime(2000);
      final bTime = DateTime.tryParse(b['timestamp']?.toString() ?? '') ??
          DateTime(2000);
      return aTime.compareTo(bTime);
    });

    return merged;
  }

  Future<void> _saveMessages() async {
    await ChatStorageService.saveMessages(widget.receiverId, messages);
  }

  void _setupSocket() {
    try {
      SocketService.connect();

      SocketService.onReceiveMessage((data) {
        if (data['senderId'] == widget.receiverId && mounted) {
          setState(() {
            messages.add({
              'senderId': data['senderId'],
              'message': data['message'],
              'type': 'text',
              'timestamp': data['timestamp'],
              'isRead': false,
            });
          });
          _saveMessages();
          scrollToBottom();
        }
      });

      SocketService.onUserTyping((data) {
        if (data['userId'] == widget.receiverId && mounted) {
          setState(() => isTyping = data['isTyping']);
        }
      });
    } catch (e) {}
  }

  void sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = {
      'senderId': myUserId,
      'message': text,
      'type': 'text',
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };

    setState(() {
      messages.add(newMessage);
      _hasText = false;
    });

    _saveMessages();

    try {
      SocketService.sendMessage(widget.receiverId, text);
    } catch (e) {}

    _messageController.clear();
    scrollToBottom();
  }

  void _toggleEmojiPicker() {
    if (_showEmojiPicker) {
      setState(() => _showEmojiPicker = false);
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _showEmojiPicker = true);
      });
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
        if (_selectedIndices.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIndices.add(index);
        _isSelectionMode = true;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedIndices.clear();
    });
  }

  void _deleteSelected() {
    setState(() {
      final sorted = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
      for (final i in sorted) messages.removeAt(i);
      _clearSelection();
    });
    _saveMessages();
  }

  void _clearChat() {
    setState(() => messages.clear());
    ChatStorageService.clearMessages(widget.receiverId);
  }

  void _blockUser() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.receiverName} blocked')),
    );
  }

  Future<void> _showChatMenu() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChatMenuSheet(
        receiverId: widget.receiverId,
        receiverName: widget.receiverName,
        receiverAvatar: widget.receiverAvatar,
        isMuted: _isMuted,
        onMuteToggle: (val) => setState(() => _isMuted = val),
        onClearChat: _clearChat,
        onBlockUser: _blockUser,
      ),
    );
    if (result == 'theme') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatThemeScreen(
            chatId: widget.receiverId,
            contactName: widget.receiverName,
          ),
        ),
      );
      await _loadTheme();
    }
  }

  List<Map<String, dynamic>> get _filteredMessages {
    var result = messages;

    if (_searchQuery.isNotEmpty) {
      result = result.where((msg) {
        return msg['message']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedDate != null) {
      result = result.where((msg) {
        try {
          final msgDate = DateTime.parse(msg['timestamp'].toString());
          return msgDate.year == _selectedDate!.year &&
              msgDate.month == _selectedDate!.month &&
              msgDate.day == _selectedDate!.day;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    return result;
  }

  void _onCalendarPressed() async {
    final date = await ChatCalendarPicker.show(
      context,
      isDark: Theme.of(context).brightness == Brightness.dark,
    );
    if (date != null && mounted) {
      setState(() => _selectedDate = date);
    }
  }

  void _clearDateFilter() {
    setState(() => _selectedDate = null);
  }

  String _formatTime(dynamic timestamp) {
    try {
      final date = DateTime.parse(timestamp.toString());
      return DateFormat('HH:mm').format(date);
    } catch (e) {
      return DateFormat('HH:mm').format(DateTime.now());
    }
  }

  String _getDateHeaderText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) return 'Today';
    if (msgDate == yesterday) return 'Yesterday';

    final diff = today.difference(msgDate).inDays;
    if (diff < 7) {
      return DateFormat('EEEE').format(date);
    }

    if (date.year == now.year) {
      return DateFormat('MMM d').format(date);
    }

    return DateFormat('MMM d, yyyy').format(date);
  }

  Widget _buildDateHeader(DateTime date, bool isDark, Color textSecondary) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey.shade800.withOpacity(0.8)
              : Colors.grey.shade200.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _getDateHeaderText(date),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textSecondary,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar(
    bool isDark,
    Color bgColor,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
    Color iconColor,
    List<Color> avatarBg,
    Color avatarIconColor,
    Color subtitleLight,
    Brightness wpBrightness,
    Color wallpaperColor,
  ) {
    if (_isSelectionMode) {
      return ChatSelectionAppBar(
        isDark: isDark,
        textPrimary: textPrimary,
        bgColor: bgColor,
        iconColor: iconColor,
        selectedCount: _selectedIndices.length,
        onClose: _clearSelection,
        onPin: () {},
        onArchive: () {},
        onDelete: _deleteSelected,
        onMore: () {},
      );
    }

    if (_isSearching) {
      return ChatInlineSearch(
        isDark: isDark,
        backgroundColor: wallpaperColor,
        controller: _searchController,
        onBack: () => setState(() {
          _isSearching = false;
          _searchQuery = '';
          _selectedDate = null;
          _searchController.clear();
        }),
        onChanged: (value) => setState(() => _searchQuery = value),
        onClear: () => setState(() {
          _searchQuery = '';
          _searchController.clear();
        }),
        onCalendar: _onCalendarPressed,
      );
    }

    return ChatTransparentAppBar(
      receiverName: widget.receiverName,
      receiverAvatar: widget.receiverAvatar,
      isTyping: isTyping,
      isUserOnline: _isUserOnline,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      primaryColor: primaryColor,
      isDark: isDark,
      iconColor: iconColor,
      avatarBg: avatarBg,
      avatarIconColor: avatarIconColor,
      subtitleLight: subtitleLight,
      wallpaperBrightness: wpBrightness,
      onBack: () => Navigator.pop(context),
      onVideoCall: () {},
      onVoiceCall: () {},
      onMenu: _showChatMenu,
      onSearch: () => setState(() => _isSearching = true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final primaryColor =
        isDark ? AppTheme.darkNavActive : AppTheme.lightNavActive;
    final textPrimary =
        isDark ? AppTheme.darkLightText : AppTheme.lightDarkText;
    final textSecondary =
        isDark ? AppTheme.darkNavInactive : AppTheme.lightNavInactive;
    final textMuted = isDark
        ? AppTheme.darkNavInactive.withOpacity(0.7)
        : AppTheme.lightNavInactive.withOpacity(0.7);
    final iconColor = isDark ? AppTheme.darkLightText : AppTheme.lightDarkText;
    final actionBtnBg = primaryColor;
    final actionBtnIcon = isDark ? AppTheme.darkBackground : AppTheme.lightLightText;
    final avatarBg = isDark
        ? [Colors.grey.shade700, Colors.grey.shade900]
        : [Colors.grey.shade300, Colors.grey.shade400];
    final avatarIconColor =
        isDark ? Colors.grey.shade300 : Colors.grey.shade600;
    final subtitleLight =
        isDark ? AppTheme.darkNavInactive : Colors.grey.shade500;

    final searchHighlightColor = isDark
        ? AppTheme.darkNavActive.withOpacity(0.25)
        : AppTheme.lightNavActive.withOpacity(0.15);

    final myBubbleClr = _resolveThemeColor(
      'bubbleColor',
      isDark ? AppTheme.darkSurface : AppTheme.lightNavActive,
    );
    final theirBubbleClr = _resolveThemeColor(
      'receiverBubbleColor',
      isDark ? AppTheme.darkBackground.withOpacity(0.9) : AppTheme.lightSurface,
    );

    final myTextClr = _contrastText(myBubbleClr);
    final theirTextClr = _contrastText(theirBubbleClr);

    final wpBrightness = _wallpaperBrightnessValue(isDark);

    final Color wallpaperColor;
    if ((_activeTheme['wallpaperType'] ?? 'solid') == 'gradient' &&
        _activeTheme['wallpaperColors'] != null) {
      final colors = _activeTheme['wallpaperColors'] as List;
      wallpaperColor = colors.isNotEmpty
          ? _resolveColor(colors[0], bgColor)
          : bgColor;
    } else {
      wallpaperColor = _resolveColor(_activeTheme['wallpaperColor'], bgColor);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: bgColor,
      appBar: _buildAppBar(
        isDark,
        bgColor,
        textPrimary,
        textSecondary,
        primaryColor,
        iconColor,
        avatarBg,
        avatarIconColor,
        subtitleLight,
        wpBrightness,
        wallpaperColor,
      ),
      body: Stack(
        children: [
          // ===== WALLPAPER BACKGROUND + EFFECTS =====
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: _activeWallpaperId != null && _activeWallpaperId != 'default'
                      ? ChatThemeService.getWallpaperDecorationById(_activeWallpaperId!, isDark)
                      : ChatThemeService.getWallpaperDecoration(_activeTheme),
                ),
                if (_wallpaperTint != Colors.transparent)
                  Container(color: _wallpaperTint.withOpacity(0.25)),
                Container(
                  color: _wallpaperBrightness > 0
                      ? Colors.black.withOpacity(_wallpaperBrightness * 0.6)
                      : Colors.white.withOpacity((-_wallpaperBrightness).clamp(0.0, 0.6) * 0.6),
                ),
                if (_wallpaperBlur > 0)
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _wallpaperBlur * 15,
                      sigmaY: _wallpaperBlur * 15,
                    ),
                    child: Container(color: Colors.transparent),
                  ),
              ],
            ),
          ),

          Column(
            children: [
              if (_isSearching && _selectedDate != null)
                Container(
                  margin: EdgeInsets.only(
                    top: kToolbarHeight + MediaQuery.of(context).padding.top + 12,
                    left: 12,
                    right: 12,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      backgroundColor: isDark
                          ? Colors.grey.shade800.withOpacity(0.85)
                          : Colors.grey.shade200.withOpacity(0.9),
                      side: BorderSide(
                        color: isDark
                            ? Colors.grey.shade600.withOpacity(0.5)
                            : Colors.grey.shade400.withOpacity(0.5),
                      ),
                      label: Text(
                        DateFormat('MMM dd, yyyy').format(_selectedDate!),
                        style: TextStyle(
                          color: textPrimary,
                          fontFamily: 'Poppins',
                          fontSize: 13,
                        ),
                      ),
                      deleteIcon: Icon(Icons.close, size: 18, color: textSecondary),
                      onDeleted: _clearDateFilter,
                    ),
                  ),
                ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: kToolbarHeight +
                          MediaQuery.of(context).padding.top +
                          (_isSearching && _selectedDate != null ? 62 : 0)),
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                              color: primaryColor, strokeWidth: 2))
                      : messages.isEmpty
                          ? _buildEmptyState(textMuted)
                          : _isSearching && _filteredMessages.isEmpty
                              ? _buildNotFoundState(textMuted)
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  itemCount: _isSearching
                                      ? _filteredMessages.length
                                      : messages.length,
                                  itemBuilder: (context, index) {
                                    final displayList = _isSearching
                                        ? _filteredMessages
                                        : messages;
                                    final msg = displayList[index];
                                    final originalIndex = _isSearching
                                        ? messages.indexOf(msg)
                                        : index;
                                    final isMe =
                                        msg['senderId'] == myUserId;
                                    final isSelected = _selectedIndices
                                        .contains(originalIndex);

                                    DateTime? msgDate;
                                    bool showDateHeader = false;
                                    try {
                                      msgDate = DateTime.parse(msg['timestamp'].toString());
                                      msgDate = DateTime(msgDate.year, msgDate.month, msgDate.day);
                                    } catch (e) {}

                                    if (index == 0) {
                                      showDateHeader = msgDate != null;
                                    } else {
                                      try {
                                        final prevMsg = displayList[index - 1];
                                        final prevDate = DateTime.parse(prevMsg['timestamp'].toString());
                                        final prevDateOnly = DateTime(prevDate.year, prevDate.month, prevDate.day);
                                        showDateHeader = msgDate != null && msgDate != prevDateOnly;
                                      } catch (e) {
                                        showDateHeader = msgDate != null;
                                      }
                                    }

                                    final isMatch = _isSearching &&
                                            _searchQuery.isNotEmpty
                                        ? msg['message']
                                            .toString()
                                            .toLowerCase()
                                            .contains(_searchQuery
                                                .toLowerCase())
                                        : false;
                                    final isVoice =
                                        msg['type'] == 'voice';

                                    Widget messageWidget;

                                    if (msg['type'] == 'image') {
                                      Widget bubble = ChatImageBubble(
                                        imageFile: File(msg['mediaPath']),
                                        isMe: isMe,
                                        caption: msg['message']?.toString().isNotEmpty == true
                                            ? msg['message']
                                            : null,
                                        timestamp: DateTime.tryParse(
                                            msg['timestamp']?.toString() ?? ''),
                                        themeColor: myBubbleClr,
                                      );

                                      if (isSelected) {
                                        bubble = Container(
                                          foregroundDecoration: BoxDecoration(
                                            color: primaryColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(18),
                                            border: Border.all(color: primaryColor, width: 2),
                                          ),
                                          child: bubble,
                                        );
                                      }

                                      messageWidget = GestureDetector(
                                        onTap: _isSelectionMode
                                            ? () => _toggleSelection(originalIndex)
                                            : null,
                                        onLongPress: () => _toggleSelection(originalIndex),
                                        child: bubble,
                                      );
                                    } else if (msg['type'] == 'video') {
                                      Widget bubble = ChatVideoBubble(
                                        videoFile: File(msg['mediaPath']),
                                        isMe: isMe,
                                        caption: msg['message']?.toString().isNotEmpty == true
                                            ? msg['message']
                                            : null,
                                        timestamp: DateTime.tryParse(
                                            msg['timestamp']?.toString() ?? ''),
                                      );

                                      if (isSelected) {
                                        bubble = Container(
                                          foregroundDecoration: BoxDecoration(
                                            color: primaryColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(18),
                                            border: Border.all(color: primaryColor, width: 2),
                                          ),
                                          child: bubble,
                                        );
                                      }

                                      messageWidget = GestureDetector(
                                        onTap: _isSelectionMode
                                            ? () => _toggleSelection(originalIndex)
                                            : null,
                                        onLongPress: () => _toggleSelection(originalIndex),
                                        child: bubble,
                                      );
                                    } else {
                                      Widget? voiceWidget;
                                      if (isVoice) {
                                        voiceWidget = buildVoiceBubble(
                                            msg,
                                            isMe,
                                            iconColor,
                                            primaryColor,
                                            textTheme);
                                      }

                                      messageWidget = ChatMessageBubble(
                                        msg: msg,
                                        isMe: isMe,
                                        isSelected: isSelected,
                                        isMatch: isMatch,
                                        searchQuery: _searchQuery,
                                        onTap: _isSelectionMode
                                            ? () => _toggleSelection(
                                                originalIndex)
                                            : null,
                                        onLongPress: () =>
                                            _toggleSelection(originalIndex),
                                        isDark: isDark,
                                        primaryColor: primaryColor,
                                        searchHighlightColor:
                                            searchHighlightColor,
                                        myBubbleColor: myBubbleClr,
                                        otherBubbleColor: theirBubbleClr,
                                        myTextColor: myTextClr,
                                        otherTextColor: theirTextClr,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        textMuted: textMuted,
                                        iconColor: iconColor,
                                        voiceWidget: voiceWidget,
                                        formattedTime:
                                            _formatTime(msg['timestamp']),
                                        isRead: msg['isRead'] == true,
                                      );
                                    }

                                    if (showDateHeader && msgDate != null) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildDateHeader(msgDate, isDark, textSecondary),
                                          messageWidget,
                                        ],
                                      );
                                    }

                                    return messageWidget;
                                  },
                                ),
                ),
              ),

              if (isTyping &&
                  !_isSelectionMode &&
                  !_isSearching &&
                  !showVoiceBar)
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, bottom: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(right: 80),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkBackground
                            : AppTheme.lightSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.darkNavInactive
                                  .withOpacity(0.12)
                              : AppTheme.lightNavInactive
                                  .withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTypingDot(textSecondary, 0),
                          _buildTypingDot(textSecondary, 150),
                          _buildTypingDot(textSecondary, 300),
                        ],
                      ),
                    ),
                  ),
                ),

              if (!_isSelectionMode && !_isSearching)
                showVoiceBar
                    ? VoiceRecordBar(
                        key: voiceRecordBarKey,
                        themeColor: myBubbleClr,
                        onSend: (path, durationMs) {
                          final newMessage = {
                            'senderId': myUserId,
                            'message': '',
                            'type': 'voice',
                            'voicePath': path,
                            'duration': durationMs ~/ 1000,
                            'timestamp': DateTime.now()
                                .toIso8601String(),
                            'isRead': false,
                          };
                          setState(() {
                            messages.add(newMessage);
                            showVoiceBar = false;
                          });
                          _saveMessages();
                          scrollToBottom();
                        },
                        onCancel: () {
                          setState(() => showVoiceBar = false);
                        },
                      )
                    : ChatInputBar(
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        iconColor: iconColor,
                        actionBtnBg: actionBtnBg,
                        actionBtnIcon: actionBtnIcon,
                        themeColor: myBubbleClr,
                        controller: _messageController,
                        focusNode: _focusNode,
                        hasText: _hasText,
                        onEmojiToggle: _toggleEmojiPicker,
                        onAttach: _showAttachmentSheet,
                        onCamera: _openCustomCamera,
                        onSend: sendMessage,
                        onVoice: () =>
                            setState(() => showVoiceBar = true),
                        onChanged: (text) {
                          setState(() =>
                              _hasText = text.trim().isNotEmpty);
                          try {
                            SocketService.sendTyping(
                                widget.receiverId,
                                text.trim().isNotEmpty);
                          } catch (e) {}
                        },
                        onMediaPicked: _onMediaPicked,
                      ),

              if (_showEmojiPicker)
                SizedBox(
                  height: 280,
                  child: EmojiPicker(
                    textEditingController: _messageController,
                    config: Config(
                      height: 280,
                      checkPlatformCompatibility: true,
                      emojiViewConfig: EmojiViewConfig(
                        columns: 8,
                        emojiSizeMax: 28,
                        backgroundColor: isDark
                            ? AppTheme.darkBackground
                            : AppTheme.lightBackground,
                        verticalSpacing: 4,
                        horizontalSpacing: 4,
                      ),
                      skinToneConfig: const SkinToneConfig(),
                      categoryViewConfig: CategoryViewConfig(
                        backgroundColor: isDark
                            ? AppTheme.darkBackground
                            : AppTheme.lightBackground,
                        indicatorColor: primaryColor,
                        iconColor: isDark
                            ? AppTheme.darkNavInactive
                            : Colors.grey.shade400,
                        iconColorSelected: primaryColor,
                      ),
                      bottomActionBarConfig:
                          const BottomActionBarConfig(enabled: false),
                      searchViewConfig: const SearchViewConfig(
                        backgroundColor: Colors.transparent,
                        buttonIconColor: Colors.grey,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          if (messages.isNotEmpty && !_isSearching && !_isSelectionMode)
            Positioned(
              right: 12,
              bottom: showVoiceBar ? 160 : 140,
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 200),
                child: Material(
                  color: isDark
                      ? Colors.grey.shade800.withOpacity(0.9)
                      : Colors.white.withOpacity(0.9),
                  elevation: 3,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _toggleScrollPosition,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return RotationTransition(
                            turns: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          _isAtBottom
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          key: ValueKey<bool>(_isAtBottom),
                          size: 22,
                          color: textSecondary,
                        ),
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

  Widget _buildEmptyState(Color textMuted) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, color: textMuted, size: 22),
          const SizedBox(height: 10),
          Text(
            'Messages are end-to-end encrypted',
            style: TextStyle(
              color: textMuted,
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState(Color textMuted) {
    final bool hasDateFilter = _selectedDate != null;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, color: textMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            'Not Found',
            style: TextStyle(
              color: textMuted,
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasDateFilter
                ? 'No messages for this date'
                : 'No matching messages',
            style: TextStyle(
              color: textMuted.withOpacity(0.7),
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(Color color, int delayMs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
