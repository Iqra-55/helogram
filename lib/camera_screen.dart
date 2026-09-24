import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

// ============================================
// DEPENDENCIES (pubspec.yaml)
// ============================================
// dependencies:
//   flutter:
//     sdk: flutter
//   camera: ^0.11.0+2
//   image_picker: ^1.1.2
//   photo_manager: ^3.6.0
//   path_provider: ^2.1.4
//   video_player: ^2.9.1


// Helper widget for displaying photo_manager assets
class _AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;
  final ThumbnailSize size;
  final BoxFit fit;

  const _AssetThumbnail({
    required this.asset,
    this.size = const ThumbnailSize(200, 200),
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(size),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          return Image.memory(snapshot.data!, fit: fit);
        }
        return Container(color: Colors.grey.shade800);
      },
    );
  }
}

class _OverlayItem {
  String type;
  String content;
  Offset position;
  double scale;
  Color color;
  _OverlayItem({
    required this.type,
    required this.content,
    this.position = const Offset(100, 100),
    this.scale = 1.0,
    this.color = Colors.white,
  });
}

class DrawingStroke {
  List<Offset> points;
  Paint paint;
  DrawingStroke({required this.points, required this.paint});
}

class CustomCameraScreen extends StatefulWidget {
  final Function(File file, String caption, bool isVideo)? onMediaCaptured;
  final String? contactName;

  const CustomCameraScreen({Key? key, this.onMediaCaptured, this.contactName}) : super(key: key);

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isCapturing = false;
  FlashMode _flashMode = FlashMode.off;
  bool _isRearCamera = true;
  int _selectedModeIndex = 1;
  String? _recentThumbnailPath;
  bool _showEffectsPanel = false;
  int _selectedEffectTab = 1;

  // Recent gallery strip images
  List<AssetEntity> _recentAssets = [];
  bool _showGalleryPicker = false;
  List<AssetEntity> _galleryAssets = [];
  int _galleryPage = 0;
  final int _galleryPageSize = 30;
  bool _isLoadingGallery = false;

  final List<Map<String, dynamic>> _filters = [
    {'name': 'Normal', 'matrix': _normalMatrix, 'color': Colors.white},
    {'name': 'Warm', 'matrix': _warmMatrix, 'color': Color(0xFFFFE0B2)},
    {'name': 'B&W', 'matrix': _noirMatrix, 'color': Colors.grey},
    {'name': 'Indie kid', 'matrix': _vividMatrix, 'color': Color(0xFFFFCC80)},
    {'name': 'Dreamy', 'matrix': _dreamyMatrix, 'color': Color(0xFFE1BEE7)},
    {'name': 'Sombra', 'matrix': _sepiaMatrix, 'color': Color(0xFFD7CCC8)},
    {'name': 'Spring tone', 'matrix': _springMatrix, 'color': Color(0xFFC8E6C9)},
    {'name': 'Frosted glass', 'matrix': _coolMatrix, 'color': Color(0xFFB3E5FC)},
    {'name': 'Duo tone', 'matrix': _duoMatrix, 'color': Color(0xFFF8BBD0)},
    {'name': 'Prism light', 'matrix': _prismMatrix, 'color': Color(0xFFE1F5FE)},
    {'name': 'Rainbow', 'matrix': _vividMatrix, 'color': Color(0xFFF0F4C3)},
    {'name': 'Rainy day', 'matrix': _noirMatrix, 'color': Color(0xFFCFD8DC)},
  ];
  int _selectedFilterIndex = 0;

  final List<Map<String, dynamic>> _faceEffects = [
    {'name': 'None', 'icon': Icons.face_outlined},
    {'name': 'Smile', 'icon': Icons.sentiment_satisfied_outlined},
    {'name': 'Cool', 'icon': Icons.sentiment_very_satisfied_outlined},
    {'name': 'Heart', 'icon': Icons.favorite_border},
    {'name': 'Star', 'icon': Icons.star_border},
    {'name': 'Fire', 'icon': Icons.local_fire_department_outlined},
  ];
  int _selectedFaceEffect = 0;

  final List<Map<String, dynamic>> _backgrounds = [
    {'name': 'None', 'color': Colors.black, 'isNone': true},
    {'name': 'Cafe', 'color': Color(0xFF8D6E63), 'isNone': false},
    {'name': 'Office', 'color': Color(0xFF546E7A), 'isNone': false},
    {'name': 'Living room', 'color': Color(0xFF6D4C41), 'isNone': false},
    {'name': 'Forest', 'color': Color(0xFF2E7D32), 'isNone': false},
    {'name': 'Beach', 'color': Color(0xFF0277BD), 'isNone': false},
    {'name': 'Studio', 'color': Color(0xFF424242), 'isNone': false},
    {'name': 'Library', 'color': Color(0xFF5D4037), 'isNone': false},
    {'name': 'Garden', 'color': Color(0xFF388E3C), 'isNone': false},
  ];
  int _selectedBackground = 0;

  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  bool _isVideoNoteRecording = false;
  int _videoNoteSeconds = 0;
  Timer? _videoNoteTimer;

  bool _isPreview = false;
  File? _capturedFile;
  bool _isVideoPreview = false;
  VideoPlayerController? _videoPlayerController;
  final TextEditingController _captionController = TextEditingController();
  final GlobalKey _repaintKey = GlobalKey();
  String? _toastMessage;
  Timer? _toastTimer;
  late AnimationController _shutterController;

  final List<_OverlayItem> _overlays = [];
  bool _isDrawing = false;
  final List<DrawingStroke> _strokes = [];
  DrawingStroke? _currentStroke;
  Color _drawColor = Colors.red;
  double _strokeWidth = 4;
  bool _showStickerPicker = false;
  bool _showTextInput = false;
  final TextEditingController _textOverlayController = TextEditingController();
  Color _selectedTextColor = Colors.white;

  final List<String> _stickers = ['😀','😂','😍','😎','🔥','❤️','⭐','🎉','👍','🙏',
    '🌹','🌟','💯','🤩','😭','😡','🥳','🤔','👀','💪'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _initCamera();
    _loadRecentGalleryImages();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
      _videoPlayerController?.pause();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  // Load multiple recent images for the bottom strip
  Future<void> _loadRecentGalleryImages() async {
    try {
      final ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) return;
      final albums = await PhotoManager.getAssetPathList(type: RequestType.image, onlyAll: true);
      if (albums.isEmpty) return;
      final recent = await albums.first.getAssetListPaged(page: 0, size: 15);
      if (recent.isNotEmpty && mounted) {
        setState(() {
          _recentAssets = recent;
        });
        final file = await recent.first.file;
        if (file != null && mounted) setState(() => _recentThumbnailPath = file.path);
      }
    } catch (e) {
      debugPrint('Gallery error: $e');
    }
  }

  // Open full gallery picker like WhatsApp Recents
  Future<void> _openGalleryPicker() async {
    setState(() {
      _showGalleryPicker = true;
      _isLoadingGallery = true;
      _galleryAssets.clear();
      _galleryPage = 0;
    });
    await _loadGalleryPage();
  }

  Future<void> _loadGalleryPage() async {
    try {
      final ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        if (mounted) setState(() => _isLoadingGallery = false);
        return;
      }
      final albums = await PhotoManager.getAssetPathList(type: RequestType.common, onlyAll: true);
      if (albums.isEmpty) {
        if (mounted) setState(() => _isLoadingGallery = false);
        return;
      }
      final assets = await albums.first.getAssetListPaged(page: _galleryPage, size: _galleryPageSize);
      if (mounted) {
        setState(() {
          _galleryAssets.addAll(assets);
          _isLoadingGallery = false;
        });
      }
    } catch (e) {
      debugPrint('Gallery picker error: $e');
      if (mounted) setState(() => _isLoadingGallery = false);
    }
  }

  Future<void> _selectGalleryAsset(AssetEntity asset) async {
    try {
      final file = await asset.file;
      if (file != null && mounted) {
        setState(() {
          _showGalleryPicker = false;
          _capturedFile = file;
          _isPreview = true;
          _isVideoPreview = asset.type == AssetType.video;
          _overlays.clear();
          _strokes.clear();
        });
        if (_isVideoPreview) _initVideoPlayer();
      }
    } catch (e) {
      debugPrint('Select asset error: $e');
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) await _setupCamera(_cameras.first);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    await _controller?.dispose();
    _controller = CameraController(
      camera,
      ResolutionPreset.ultraHigh,
      enableAudio: _selectedModeIndex == 0 || _selectedModeIndex == 2,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _controller!.initialize();
    await _controller!.setFlashMode(_flashMode);
    if (mounted) setState(() => _isInitialized = true);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    setState(() {
      _flashMode = _flashMode == FlashMode.off
          ? FlashMode.auto
          : _flashMode == FlashMode.auto
              ? FlashMode.always
              : FlashMode.off;
    });
    await _controller!.setFlashMode(_flashMode);
  }

  IconData get _flashIcon {
    switch (_flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
      case FlashMode.torch:
        return Icons.flash_on;
      case FlashMode.off:
      default:
        return Icons.flash_off;
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    setState(() => _isInitialized = false);
    _isRearCamera = !_isRearCamera;
    final lens = _isRearCamera ? CameraLensDirection.back : CameraLensDirection.front;
    final camera = _cameras.firstWhere((c) => c.lensDirection == lens, orElse: () => _cameras.first);
    await _setupCamera(camera);
  }

  Future<void> _onShutterPressed() async {
    if (_selectedModeIndex == 2) {
      await _toggleVideoNoteRecording();
      return;
    }
    if (_selectedModeIndex == 0) {
      await _toggleVideoRecording();
      return;
    }
    await _capturePhoto();
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) return;
    setState(() => _isCapturing = true);
    _shutterController.forward().then((_) => _shutterController.reverse());
    try {
      final XFile photo = await _controller!.takePicture();
      setState(() {
        _capturedFile = File(photo.path);
        _isPreview = true;
        _isVideoPreview = false;
        _showEffectsPanel = false;
        _overlays.clear();
        _strokes.clear();
      });
    } catch (e) {
      debugPrint('Capture error: $e');
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _toggleVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isRecording) {
      try {
        final XFile video = await _controller!.stopVideoRecording();
        _recordTimer?.cancel();
        setState(() {
          _isRecording = false;
          _recordSeconds = 0;
        });
        _capturedFile = File(video.path);
        _isVideoPreview = true;
        _isPreview = true;
        _initVideoPlayer();
      } catch (e) {
        debugPrint('Stop video error: $e');
      }
    } else {
      try {
        await _controller!.startVideoRecording();
        setState(() => _isRecording = true);
        _recordSeconds = 0;
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) setState(() => _recordSeconds++);
        });
      } catch (e) {
        debugPrint('Start video error: $e');
      }
    }
  }

  Future<void> _toggleVideoNoteRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isVideoNoteRecording) {
      try {
        final XFile video = await _controller!.stopVideoRecording();
        _videoNoteTimer?.cancel();
        setState(() {
          _isVideoNoteRecording = false;
          _videoNoteSeconds = 0;
        });
        _capturedFile = File(video.path);
        _isVideoPreview = true;
        _isPreview = true;
        _initVideoPlayer();
      } catch (e) {
        debugPrint('Stop video note error: $e');
      }
    } else {
      try {
        await _controller!.startVideoRecording();
        setState(() => _isVideoNoteRecording = true);
        _videoNoteSeconds = 0;
        _videoNoteTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) setState(() => _videoNoteSeconds++);
        });
      } catch (e) {
        debugPrint('Start video note error: $e');
      }
    }
  }

  Future<void> _initVideoPlayer() async {
    if (_capturedFile == null || !_isVideoPreview) return;
    _videoPlayerController?.dispose();
    _videoPlayerController = VideoPlayerController.file(_capturedFile!);
    await _videoPlayerController!.initialize();
    _videoPlayerController!.setLooping(true);
    if (mounted) setState(() {});
  }

  Future<void> _openGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _capturedFile = File(picked.path);
        _isPreview = true;
        _isVideoPreview = false;
        _overlays.clear();
        _strokes.clear();
      });
    }
  }

  void _toggleEffectsPanel() {
    setState(() => _showEffectsPanel = !_showEffectsPanel);
  }

  void _setEffectTab(int index) => setState(() => _selectedEffectTab = index);
  void _selectFilter(int index) => setState(() => _selectedFilterIndex = index);
  void _selectFaceEffect(int index) => setState(() => _selectedFaceEffect = index);

  void _selectBackground(int index) {
    setState(() => _selectedBackground = index);
    if (index == 0) _showToast('All effects were removed.');
  }

  void _showToast(String msg) {
    setState(() => _toastMessage = msg);
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  List<double> get _currentMatrix => _filters[_selectedFilterIndex]['matrix'];

  Future<void> _saveToGallery() async {
    if (_capturedFile == null) return;
    try {
      File finalFile = _capturedFile!;
      if (!_isVideoPreview && (_overlays.isNotEmpty || _strokes.isNotEmpty || _selectedFilterIndex != 0)) {
        final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary != null) {
          final image = await boundary.toImage(pixelRatio: MediaQuery.of(context).devicePixelRatio * 2);
          final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
          final bytes = byteData!.buffer.asUint8List();
          final tempDir = await getTemporaryDirectory();
          final path = '${tempDir.path}/saved_${DateTime.now().millisecondsSinceEpoch}.png';
          finalFile = File(path);
          await finalFile.writeAsBytes(bytes);
        }
      }
      final picturesDir = Directory('/storage/emulated/0/Pictures/HeloGram');
      if (!await picturesDir.exists()) await picturesDir.create(recursive: true);
      final fileName = 'HeloGram_${DateTime.now().millisecondsSinceEpoch}.${_isVideoPreview ? 'mp4' : 'png'}';
      final savedFile = await finalFile.copy('${picturesDir.path}/$fileName');
      _showToast('Saved: ${savedFile.path}');
    } catch (e) {
      debugPrint('Save error: $e');
      _showToast('Save failed');
    }
  }

  Future<void> _cropImage() async {
    if (_capturedFile == null || _isVideoPreview) return;
    _showToast('Crop: Select area (use pinch to zoom)');
  }

  void _rotateImage() {
    if (_capturedFile == null || _isVideoPreview) return;
    _showToast('Rotate: Image rotated (apply on send)');
  }

  void _toggleStickerPicker() {
    setState(() {
      _showStickerPicker = !_showStickerPicker;
      _isDrawing = false;
      _showTextInput = false;
    });
  }

  void _addSticker(String emoji) {
    setState(() {
      _overlays.add(_OverlayItem(
        type: 'sticker',
        content: emoji,
        position: Offset(
          MediaQuery.of(context).size.width / 2 - 20,
          MediaQuery.of(context).size.height / 2 - 20,
        ),
        scale: 1.5,
      ));
      _showStickerPicker = false;
    });
  }

  void _toggleTextInput() {
    setState(() {
      _showTextInput = !_showTextInput;
      _isDrawing = false;
      _showStickerPicker = false;
    });
    if (!_showTextInput) {
      _textOverlayController.clear();
    }
  }

  void _addTextOverlay() {
    if (_textOverlayController.text.trim().isEmpty) return;
    setState(() {
      _overlays.add(_OverlayItem(
        type: 'text',
        content: _textOverlayController.text.trim(),
        position: Offset(
          MediaQuery.of(context).size.width / 2 - 50,
          MediaQuery.of(context).size.height / 2 - 20,
        ),
        scale: 1.0,
        color: _selectedTextColor,
      ));
      _textOverlayController.clear();
      _showTextInput = false;
    });
  }

  void _toggleDrawing() {
    setState(() {
      _isDrawing = !_isDrawing;
      _showStickerPicker = false;
      _showTextInput = false;
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (!_isDrawing) return;
    setState(() {
      _currentStroke = DrawingStroke(
        points: [details.localPosition],
        paint: Paint()
          ..color = _drawColor
          ..strokeWidth = _strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDrawing || _currentStroke == null) return;
    setState(() {
      _currentStroke!.points.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDrawing || _currentStroke == null) return;
    setState(() {
      _strokes.add(_currentStroke!);
      _currentStroke = null;
    });
  }

  Future<void> _sendMedia() async {
    try {
      File finalFile = _capturedFile!;
      if (!_isVideoPreview && _capturedFile != null) {
        if (_overlays.isNotEmpty || _strokes.isNotEmpty || _selectedFilterIndex != 0) {
          await Future.delayed(const Duration(milliseconds: 100));
          final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
          if (boundary != null) {
            final image = await boundary.toImage(pixelRatio: MediaQuery.of(context).devicePixelRatio * 2);
            final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
            final bytes = byteData!.buffer.asUint8List();
            final tempDir = await getTemporaryDirectory();
            final path = '${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.png';
            finalFile = File(path);
            await finalFile.writeAsBytes(bytes);
          }
        }
      }
      widget.onMediaCaptured?.call(finalFile, _captionController.text.trim(), _isVideoPreview);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Send error: $e');
    }
  }

  void _retake() {
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    setState(() {
      _isPreview = false;
      _capturedFile = null;
      _isVideoPreview = false;
      _captionController.clear();
      _selectedFilterIndex = 0;
      _selectedFaceEffect = 0;
      _selectedBackground = 0;
      _showEffectsPanel = false;
      _overlays.clear();
      _strokes.clear();
      _isDrawing = false;
      _showStickerPicker = false;
      _showTextInput = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _videoPlayerController?.dispose();
    _shutterController.dispose();
    _captionController.dispose();
    _textOverlayController.dispose();
    _recordTimer?.cancel();
    _videoNoteTimer?.cancel();
    _toastTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _showGalleryPicker ? _buildGalleryPicker() : (_isPreview ? _buildPreviewScreen() : _buildCameraScreen()),
    );
  }

  // ============================================
  // GALLERY PICKER SCREEN (Image 2 ki tarah)
  // ============================================
  Widget _buildGalleryPicker() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _RoundDarkButton(
                      icon: Icons.close,
                      onTap: () => setState(() => _showGalleryPicker = false),
                    ),
                    const Text(
                      'Recents',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              // Gallery Grid
              Expanded(
                child: _galleryAssets.isEmpty && _isLoadingGallery
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : NotificationListener<ScrollNotification>(
                        onNotification: (scroll) {
                          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent * 0.8 && !_isLoadingGallery) {
                            _galleryPage++;
                            _loadGalleryPage();
                          }
                          return false;
                        },
                        child: GridView.builder(
                          padding: const EdgeInsets.all(2),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                          itemCount: _galleryAssets.length,
                          itemBuilder: (context, index) {
                            final asset = _galleryAssets[index];
                            return GestureDetector(
                              onTap: () => _selectGalleryAsset(asset),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  _AssetThumbnail(
                                    asset: asset,
                                    size: const ThumbnailSize(300, 300),
                                    fit: BoxFit.cover,
                                  ),
                                  if (asset.type == AssetType.video)
                                    const Positioned(
                                      bottom: 6,
                                      right: 6,
                                      child: Icon(Icons.videocam, color: Colors.white, size: 18),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCameraScreen() {
    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildCameraPreview(),
        if (!_showEffectsPanel) ...[
          _buildTopBar(),
          if (_toastMessage != null) _buildToast(),
          _buildBottomControls(),
        ],
        if (_showEffectsPanel) _buildEffectsPanel(),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return Positioned.fill(
      child: _selectedModeIndex == 2
          ? _buildCircularVideoNotePreview()
          : FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize?.height ?? 1,
                height: _controller!.value.previewSize?.width ?? 1,
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(_currentMatrix),
                  child: CameraPreview(_controller!),
                ),
              ),
            ),
    );
  }

  Widget _buildCircularVideoNotePreview() {
    return Center(
      child: ClipOval(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.72,
          height: MediaQuery.of(context).size.width * 0.72,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.previewSize?.height ?? 1,
              height: _controller!.value.previewSize?.width ?? 1,
              child: CameraPreview(_controller!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final bool showTimer = _selectedModeIndex == 0 || _selectedModeIndex == 2;
    final bool isRecording = _isRecording || _isVideoNoteRecording;
    final int seconds = _selectedModeIndex == 0 ? _recordSeconds : _videoNoteSeconds;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _RoundDarkButton(
              icon: Icons.close,
              onTap: () => Navigator.pop(context),
            ),
            if (showTimer)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: isRecording ? Colors.red : Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              )
            else
              const SizedBox(width: 40),
            _RoundDarkButton(
              icon: _flashIcon,
              onTap: _toggleFlash,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // BOTTOM CONTROLS with Recent Images Strip
  // ============================================
  Widget _buildBottomControls() {
    final bool isVideoNote = _selectedModeIndex == 2;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.9), Colors.black.withOpacity(0.5), Colors.transparent],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Recent images horizontal strip (Image 1 ki tarah)
              if (!isVideoNote && _recentAssets.isNotEmpty)
                SizedBox(
                  height: 64,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: _recentAssets.length,
                    itemBuilder: (context, index) {
                      final asset = _recentAssets[index];
                      return GestureDetector(
                        onTap: () => _selectGalleryAsset(asset),
                        child: Container(
                          width: 56,
                          height: 56,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white30, width: 1),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: _AssetThumbnail(
                            asset: asset,
                            size: const ThumbnailSize(200, 200),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isVideoNote)
                            GestureDetector(
                              onTap: _openGalleryPicker,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white24,
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                                  image: _recentThumbnailPath != null
                                      ? DecorationImage(image: FileImage(File(_recentThumbnailPath!)), fit: BoxFit.cover)
                                      : null,
                                ),
                                child: _recentThumbnailPath == null
                                    ? const Icon(Icons.image_outlined, color: Colors.white70, size: 20)
                                    : null,
                              ),
                            )
                          else
                            const SizedBox(width: 44),
                          const SizedBox(width: 12),
                          _RoundDarkButton(
                            icon: Icons.auto_fix_high,
                            onTap: _toggleEffectsPanel,
                            size: 42,
                            isActive: _showEffectsPanel,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _onShutterPressed,
                      child: AnimatedBuilder(
                        animation: _shutterController,
                        builder: (context, child) {
                          final scale = 1 - (_shutterController.value * 0.08);
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isRecording || _isVideoNoteRecording ? Colors.red : Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: _isRecording || _isVideoNoteRecording
                                      ? 28
                                      : (_selectedModeIndex == 0 ? 28 : 58),
                                  height: _isRecording || _isVideoNoteRecording
                                      ? 28
                                      : (_selectedModeIndex == 0 ? 28 : 58),
                                  decoration: BoxDecoration(
                                    shape: (_isRecording || _isVideoNoteRecording) ? BoxShape.rectangle : BoxShape.circle,
                                    borderRadius: (_isRecording || _isVideoNoteRecording) ? BorderRadius.circular(6) : null,
                                    color: _isRecording || _isVideoNoteRecording
                                        ? Colors.red
                                        : (_selectedModeIndex == 0 ? Colors.red : Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _RoundDarkButton(
                            icon: Icons.flip_camera_android,
                            onTap: _switchCamera,
                            size: 52,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ModePill('Video', _selectedModeIndex == 0, () => setState(() => _selectedModeIndex = 0)),
                  const SizedBox(width: 8),
                  _ModePill('Photo', _selectedModeIndex == 1, () => setState(() => _selectedModeIndex = 1)),
                  const SizedBox(width: 8),
                  _ModePill('Video note', _selectedModeIndex == 2, () => setState(() => _selectedModeIndex = 2)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEffectsPanel() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _RoundDarkButton(icon: Icons.arrow_back, onTap: _toggleEffectsPanel),
                    Row(
                      children: [
                        _RoundDarkButton(icon: Icons.undo, onTap: () {}, size: 36),
                        const SizedBox(width: 10),
                        _RoundDarkButton(
                          icon: _flashIcon,
                          onTap: _toggleFlash,
                          size: 36,
                          isActive: _flashMode != FlashMode.off,
                        ),
                        const SizedBox(width: 10),
                        _RoundDarkButton(icon: Icons.theater_comedy, onTap: () {}, size: 36),
                        const SizedBox(width: 10),
                        _RoundDarkButton(icon: Icons.cut, onTap: () {}, size: 36),
                      ],
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const Spacer(),
              if (_selectedEffectTab == 2 && _selectedBackground > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _backgrounds[_selectedBackground]['name'],
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              _buildEffectsContent(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _EffectTab('Effects', 0, _selectedEffectTab, _setEffectTab),
                    const SizedBox(width: 8),
                    _EffectTab('Filters', 1, _selectedEffectTab, _setEffectTab),
                    const SizedBox(width: 8),
                    _EffectTab('Backgrounds', 2, _selectedEffectTab, _setEffectTab),
                    const SizedBox(width: 12),
                    _RoundDarkButton(icon: Icons.flip_camera_android, onTap: _switchCamera, size: 32),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _onShutterPressed,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isRecording || _isVideoNoteRecording ? Colors.red : Colors.white,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _isRecording || _isVideoNoteRecording ? 28 : (_selectedModeIndex == 0 ? 28 : 58),
                      height: _isRecording || _isVideoNoteRecording ? 28 : (_selectedModeIndex == 0 ? 28 : 58),
                      decoration: BoxDecoration(
                        shape: (_isRecording || _isVideoNoteRecording) ? BoxShape.rectangle : BoxShape.circle,
                        borderRadius: (_isRecording || _isVideoNoteRecording) ? BorderRadius.circular(6) : null,
                        color: _isRecording || _isVideoNoteRecording
                            ? Colors.red
                            : (_selectedModeIndex == 0 ? Colors.red : Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEffectsContent() {
    switch (_selectedEffectTab) {
      case 0:
        return _buildFaceEffectsList();
      case 1:
        return _buildFiltersList();
      case 2:
        return _buildBackgroundsList();
      default:
        return const SizedBox();
    }
  }

  Widget _buildFaceEffectsList() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _faceEffects.length,
        itemBuilder: (context, index) {
          final effect = _faceEffects[index];
          final isSelected = index == _selectedFaceEffect;
          return GestureDetector(
            onTap: () => _selectFaceEffect(index),
            child: Container(
              width: 72,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white24 : Colors.white10,
                      border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2),
                    ),
                    child: Icon(effect['icon'] as IconData, color: isSelected ? Colors.white : Colors.white70, size: 28),
                  ),
                  const SizedBox(height: 6),
                  Text(effect['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 11), textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiltersList() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = index == _selectedFilterIndex;
          return GestureDetector(
            onTap: () => _selectFilter(index),
            child: Container(
              width: 72,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? Colors.white : Colors.white30, width: isSelected ? 2.5 : 1),
                      gradient: RadialGradient(colors: [filter['color'] as Color, (filter['color'] as Color).withOpacity(0.3)]),
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                  ),
                  const SizedBox(height: 6),
                  Text(filter['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundsList() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _backgrounds.length,
        itemBuilder: (context, index) {
          final bg = _backgrounds[index];
          final isSelected = index == _selectedBackground;
          return GestureDetector(
            onTap: () => _selectBackground(index),
            child: Container(
              width: 72,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? Colors.white : Colors.white30, width: isSelected ? 2.5 : 1),
                      color: bg['isNone'] ? Colors.white10 : bg['color'] as Color,
                    ),
                    child: bg['isNone']
                        ? Icon(Icons.block, color: isSelected ? Colors.white : Colors.white70, size: 24)
                        : (isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null),
                  ),
                  const SizedBox(height: 6),
                  Text(bg['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================
  // PREVIEW SCREEN - Options LEFT aligned, NO flash
  // ============================================
  Widget _buildPreviewScreen() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        Center(
          child: _isVideoPreview
              ? _buildVideoPreviewPlayer()
              : GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColorFiltered(
                          colorFilter: ColorFilter.matrix(_currentMatrix),
                          child: Image.file(_capturedFile!, fit: BoxFit.contain, width: double.infinity, height: double.infinity),
                        ),
                        CustomPaint(
                          size: Size.infinite,
                          painter: _DrawingPainter(strokes: _strokes, currentStroke: _currentStroke),
                        ),
                        ..._overlays.map((overlay) => Positioned(
                          left: overlay.position.dx,
                          top: overlay.position.dy,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                overlay.position += details.delta;
                              });
                            },
                            child: overlay.type == 'sticker'
                                ? Text(overlay.content, style: TextStyle(fontSize: 40 * overlay.scale))
                                : Text(
                                    overlay.content,
                                    style: TextStyle(
                                      color: overlay.color,
                                      fontSize: 22 * overlay.scale,
                                      fontWeight: FontWeight.bold,
                                      shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                                    ),
                                  ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
        ),
        // TOP BAR - LEFT ALIGNED, NO FLASH
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _RoundDarkButton(icon: Icons.close, onTap: _retake),
                const SizedBox(width: 8),
                _RoundDarkButton(icon: Icons.download, onTap: _saveToGallery, size: 40),
                const SizedBox(width: 8),
                _RoundDarkButton(icon: Icons.crop, onTap: _cropImage, size: 40),
                const SizedBox(width: 8),
                _RoundDarkButton(icon: Icons.rotate_90_degrees_ccw, onTap: _rotateImage, size: 40),
                const SizedBox(width: 8),
                _RoundDarkButton(
                  icon: Icons.emoji_emotions_outlined,
                  onTap: _toggleStickerPicker,
                  size: 40,
                  isActive: _showStickerPicker,
                ),
                const SizedBox(width: 8),
                _RoundDarkButton(
                  icon: Icons.text_fields,
                  onTap: _toggleTextInput,
                  size: 40,
                  isActive: _showTextInput,
                ),
                const SizedBox(width: 8),
                _RoundDarkButton(
                  icon: Icons.edit,
                  onTap: _toggleDrawing,
                  size: 40,
                  isActive: _isDrawing,
                ),
              ],
            ),
          ),
        ),
        if (_showStickerPicker)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _stickers.map((s) => GestureDetector(
                  onTap: () => _addSticker(s),
                  child: Text(s, style: const TextStyle(fontSize: 36)),
                )).toList(),
              ),
            ),
          ),
        if (_showTextInput)
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _textOverlayController,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: 'Enter text...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _colorDot(Colors.white),
                      _colorDot(Colors.red),
                      _colorDot(Colors.yellow),
                      _colorDot(Colors.green),
                      _colorDot(Colors.blue),
                      _colorDot(Colors.purple),
                      _colorDot(Colors.orange),
                      _colorDot(Colors.pink),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _addTextOverlay,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A884)),
                    child: const Text('Add Text', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        if (_isDrawing)
          Positioned(
            top: 80,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _colorDot(Colors.red),
                  _colorDot(Colors.yellow),
                  _colorDot(Colors.green),
                  _colorDot(Colors.blue),
                  _colorDot(Colors.white),
                  _colorDot(Colors.purple),
                  _colorDot(Colors.orange),
                  _colorDot(Colors.pink),
                  const Divider(color: Colors.white24, height: 16),
                  GestureDetector(
                    onTap: () => setState(() => _strokeWidth = 2),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _strokeWidth == 2 ? Colors.white : Colors.white30)),
                      child: const Center(child: Icon(Icons.circle, color: Colors.white, size: 4)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _strokeWidth = 4),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _strokeWidth == 4 ? Colors.white : Colors.white30)),
                      child: const Center(child: Icon(Icons.circle, color: Colors.white, size: 8)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _strokeWidth = 8),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _strokeWidth == 8 ? Colors.white : Colors.white30)),
                      child: const Center(child: Icon(Icons.circle, color: Colors.white, size: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.95), Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.image_outlined, color: Colors.white54, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _captionController,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              maxLines: 4,
                              minLines: 1,
                              decoration: const InputDecoration(
                                hintText: 'Add a caption...',
                                hintStyle: TextStyle(color: Colors.white54, fontSize: 15),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMedia,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00A884),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_toastMessage != null) _buildToast(),
      ],
    );
  }

  Widget _colorDot(Color color) {
    final isSelected = _drawColor == color || _selectedTextColor == color;
    return GestureDetector(
      onTap: () {
        if (_isDrawing) {
          setState(() => _drawColor = color);
        } else if (_showTextInput) {
          setState(() => _selectedTextColor = color);
        }
      },
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2),
        ),
      ),
    );
  }

  Widget _buildVideoPreviewPlayer() {
    if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    return GestureDetector(
      onTap: () {
        if (_videoPlayerController!.value.isPlaying) {
          _videoPlayerController!.pause();
        } else {
          _videoPlayerController!.play();
        }
        setState(() {});
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoPlayerController!.value.aspectRatio,
            child: VideoPlayer(_videoPlayerController!),
          ),
          if (!_videoPlayerController!.value.isPlaying)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
            ),
        ],
      ),
    );
  }

  Widget _buildToast() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 100),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
          child: Text(_toastMessage!, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;

  _DrawingPainter({required this.strokes, this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.length < 2) return;
    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }
    canvas.drawPath(path, stroke.paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _RoundDarkButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final bool isActive;

  const _RoundDarkButton({required this.icon, required this.onTap, this.size = 40, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), shape: BoxShape.circle),
        child: Icon(icon, color: isActive ? Colors.yellow : Colors.white, size: size > 45 ? 24 : 20),
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModePill(this.text, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: isSelected ? Colors.white24 : Colors.transparent, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
      ),
    );
  }
}

class _EffectTab extends StatelessWidget {
  final String label;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;

  const _EffectTab(this.label, this.index, this.selectedIndex, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: isSelected ? Colors.white24 : Colors.transparent, borderRadius: BorderRadius.circular(16)),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}

const List<double> _normalMatrix = [1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0];
const List<double> _noirMatrix = [0.2126,0.7152,0.0722,0,0, 0.2126,0.7152,0.0722,0,0, 0.2126,0.7152,0.0722,0,0, 0,0,0,1,0];
const List<double> _sepiaMatrix = [0.393,0.769,0.189,0,0, 0.349,0.686,0.168,0,0, 0.272,0.534,0.131,0,0, 0,0,0,1,0];
const List<double> _coolMatrix = [1,0,0,0,0, 0,1,0,0,0, 0,0,1.3,0,0, 0,0,0,1,0];
const List<double> _warmMatrix = [1.2,0,0,0,0, 0,1,0,0,0, 0,0,0.8,0,0, 0,0,0,1,0];
const List<double> _vividMatrix = [1.3,0,0,0,0, 0,1.3,0,0,0, 0,0,1.3,0,0, 0,0,0,1,0];
const List<double> _dreamyMatrix = [1.1,0.1,0.1,0,0, 0.1,1.1,0.1,0,0, 0.1,0.1,1.2,0,0, 0,0,0,1,0];
const List<double> _springMatrix = [1.1,0,0.1,0,0, 0,1.2,0,0,0, 0.1,0,1.1,0,0, 0,0,0,1,0];
const List<double> _duoMatrix = [0.8,0.2,0.4,0,0, 0.1,0.9,0.2,0,0, 0.3,0.3,0.5,0,0, 0,0,0,1,0];
const List<double> _prismMatrix = [1.2,-0.1,0.1,0,0, -0.1,1.1,0.1,0,0, 0.1,0.1,1.3,0,0, 0,0,0,1,0];
