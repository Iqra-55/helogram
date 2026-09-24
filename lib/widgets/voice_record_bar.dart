import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../services/voice_recorder_service.dart';
import '../services/voice_player_service.dart';
import 'waveform_bar.dart';

class VoiceRecordBar extends StatefulWidget {
  final void Function(String path, int durationMs) onSend;
  final VoidCallback onCancel;
  final Color? themeColor;

  const VoiceRecordBar({
    super.key,
    required this.onSend,
    required this.onCancel,
    this.themeColor,
  });

  @override
  State<VoiceRecordBar> createState() => VoiceRecordBarState();
}

class VoiceRecordBarState extends State<VoiceRecordBar>
    with TickerProviderStateMixin {
  final _recorderService = VoiceRecorderService();
  VoicePlayerService _playerService = VoicePlayerService();

  bool _isRecording = false;
  bool _isPaused = false;
  bool _showPreview = false;
  String? _recordedPath;
  int _recordedDurationMs = 0;
  int _currentDurationMs = 0;
  List<double> _amplitudes = [];

  bool _isPreviewPlaying = false;
  int _previewPositionMs = 0;
  bool _isPreviewCompleted = false;
  StreamSubscription? _previewPositionSub;
  StreamSubscription? _playerStateSub;
  StreamSubscription? _completionSub;

  late AnimationController _pulseController;
  StreamSubscription? _durationSub;
  StreamSubscription? _ampSub;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _startRecording();
  }

  @override
  void dispose() {
    _cleanupStreams();
    _pulseController.dispose();
    _recorderService.dispose();
    _playerService.dispose();
    super.dispose();
  }

  void _cleanupStreams() {
    _durationSub?.cancel();
    _ampSub?.cancel();
    _previewPositionSub?.cancel();
    _playerStateSub?.cancel();
    _completionSub?.cancel();
    _durationSub = null;
    _ampSub = null;
    _previewPositionSub = null;
    _playerStateSub = null;
    _completionSub = null;
  }

  Future<void> stopRecordingAndPreview() async {
    if (_showPreview) return;
    try {
      if (_isPaused) {
        await _recorderService.resumeRecording();
        await Future.delayed(const Duration(milliseconds: 50));
      }
      final result = await _recorderService.stopRecording();
      if (result != null && result.path.isNotEmpty) {
        _recordedPath = result.path;
        _recordedDurationMs =
            result.durationMs > 0 ? result.durationMs : _currentDurationMs;
      }
    } catch (e) {
      debugPrint("Error stopping recorder for preview: $e");
    }
    if (_recordedPath == null || _recordedPath!.isEmpty) return;
    _pulseController.stop();
    if (mounted) {
      setState(() {
        _isRecording = false;
        _isPaused = false;
        _showPreview = true;
        _previewPositionMs = 0;
        _isPreviewPlaying = false;
        _isPreviewCompleted = false;
      });
    }
    await _setupPreviewPlayer();
  }

  Future<void> _setupPreviewPlayer() async {
    if (_recordedPath == null || _recordedPath!.isEmpty) return;
    final success = await _playerService.preparePlayer(_recordedPath!);
    if (!success) {
      debugPrint("Failed to prepare preview player");
      return;
    }
    _previewPositionSub?.cancel();
    _previewPositionSub = _playerService.positionStream.listen((duration) {
      if (mounted) {
        setState(() => _previewPositionMs = duration.inMilliseconds);
      }
    });
    _playerStateSub?.cancel();
    _playerStateSub = _playerService.stateStream.listen((state) {
      if (mounted) {
        setState(() => _isPreviewPlaying = (state == PlayerState.playing));
      }
    });
    _completionSub?.cancel();
    _completionSub = _playerService.completionStream.listen((_) {
      if (mounted) {
        setState(() {
          _isPreviewPlaying = false;
          _isPreviewCompleted = true;
          _previewPositionMs = _recordedDurationMs;
        });
      }
    });
  }

  Future<void> _backToRecordingMode() async {
    await _playerService.stop();
    _previewPositionSub?.cancel();
    _playerStateSub?.cancel();
    _completionSub?.cancel();
    if (mounted) {
      setState(() {
        _showPreview = false;
        _isPreviewCompleted = false;
        _previewPositionMs = 0;
        _isPreviewPlaying = false;
      });
    }
    final path = await _recorderService.startRecording();
    if (path == null) {
      _showPermissionDenied();
      widget.onCancel();
      return;
    }
    if (mounted) {
      setState(() {
        _isRecording = true;
        _isPaused = false;
        _recordedPath = path;
      });
    }
    _pulseController.repeat(reverse: true);
    _durationSub?.cancel();
    _ampSub?.cancel();
    _durationSub = _recorderService.durationStream.listen((duration) {
      if (mounted) {
        setState(() => _currentDurationMs = _recordedDurationMs + duration.inMilliseconds);
      }
    });
    _ampSub = _recorderService.amplitudesStream.listen((amps) {
      if (mounted) setState(() => _amplitudes = amps);
    });
  }

  Future<void> _stopAndSendDirectly() async {
    if (_isRecording || _isPaused) {
      try {
        if (_isPaused) {
          await _recorderService.resumeRecording();
          await Future.delayed(const Duration(milliseconds: 50));
        }
        final result = await _recorderService.stopRecording();
        if (result != null && result.path.isNotEmpty) {
          _recordedPath = result.path;
          _recordedDurationMs =
              result.durationMs > 0 ? result.durationMs : _currentDurationMs;
        }
      } catch (e) {
        debugPrint("Error stopping recorder for send: $e");
      }
    }
    await _sendVoiceMessage();
  }

  Future<void> _startRecording() async {
    final path = await _recorderService.startRecording();
    if (path == null) {
      _showPermissionDenied();
      widget.onCancel();
      return;
    }
    if (mounted) {
      setState(() {
        _isRecording = true;
        _isPaused = false;
        _showPreview = false;
        _recordedPath = path;
        _recordedDurationMs = 0;
        _currentDurationMs = 0;
        _previewPositionMs = 0;
        _isPreviewPlaying = false;
        _isPreviewCompleted = false;
        _amplitudes = [];
      });
    }
    _pulseController.repeat(reverse: true);
    _durationSub = _recorderService.durationStream.listen((duration) {
      if (mounted) {
        setState(() => _currentDurationMs = duration.inMilliseconds);
      }
    });
    _ampSub = _recorderService.amplitudesStream.listen((amps) {
      if (mounted) setState(() => _amplitudes = amps);
    });
  }

  Future<void> _togglePauseResume() async {
    if (!_isRecording && !_isPaused) return;
    try {
      if (_isPaused) {
        await _recorderService.resumeRecording();
        _durationSub?.cancel();
        _ampSub?.cancel();
        _durationSub = _recorderService.durationStream.listen((duration) {
          if (mounted) {
            setState(() => _currentDurationMs = duration.inMilliseconds);
          }
        });
        _ampSub = _recorderService.amplitudesStream.listen((amps) {
          if (mounted) setState(() => _amplitudes = amps);
        });
        if (mounted) {
          setState(() {
            _isPaused = false;
            _isRecording = true;
          });
        }
        _pulseController.repeat(reverse: true);
      } else {
        await _recorderService.pauseRecording();
        if (mounted) setState(() => _isPaused = true);
        _pulseController.stop();
      }
    } catch (e) {
      debugPrint("Pause/Resume Error: $e");
    }
  }

  Future<void> _sendVoiceMessage() async {
    if (_recordedPath == null || _recordedPath!.isEmpty) return;
    if (_isPreviewPlaying) {
      await _playerService.stop();
    }
    final finalPath = _recordedPath!;
    final finalDuration =
        _recordedDurationMs > 0 ? _recordedDurationMs : _currentDurationMs;
    _cleanupAndReset();
    widget.onSend(finalPath, finalDuration);
  }

  Future<void> _cancelVoice() async {
    _cleanupStreams();
    try {
      if (_isPaused) {
        await _recorderService.resumeRecording();
        await Future.delayed(const Duration(milliseconds: 50));
      }
      if (_isRecording || _isPaused) {
        await _recorderService.cancelRecording();
      }
      if (_isPreviewPlaying) {
        await _playerService.stop();
      }
    } catch (e) {
      debugPrint("Error canceling recording: $e");
    }
    _cleanupAndReset();
    widget.onCancel();
  }

  void _cleanupAndReset() {
    _pulseController.stop();
    if (mounted) {
      setState(() {
        _isRecording = false;
        _isPaused = false;
        _showPreview = false;
        _recordedPath = null;
        _recordedDurationMs = 0;
        _currentDurationMs = 0;
        _previewPositionMs = 0;
        _isPreviewPlaying = false;
        _isPreviewCompleted = false;
        _amplitudes = [];
      });
    }
  }

  Future<void> _togglePreviewPlayback() async {
    if (_recordedPath == null) return;
    if (_isPreviewPlaying) {
      await _playerService.pause();
      if (mounted) setState(() => _isPreviewPlaying = false);
    } else {
      if (_isPreviewCompleted || _previewPositionMs >= _recordedDurationMs) {
        await _playerService.seekTo(0);
        await _setupPreviewPlayer();
        if (mounted) {
          setState(() {
            _previewPositionMs = 0;
            _isPreviewCompleted = false;
          });
        }
      }
      await _playerService.play();
      if (mounted) setState(() => _isPreviewPlaying = true);
    }
  }

  void _showPermissionDenied() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Microphone permission is required.'),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_showPreview) return _buildPreviewBar();
    if (_isRecording || _isPaused) {
      return _buildRecordingBar();
    }
    return const SizedBox.shrink();
  }

  // ==================== RECORDING BAR ====================
  Widget _buildRecordingBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = widget.themeColor ?? Theme.of(context).colorScheme.primary;
    
    // ✅ Background: Light = White, Dark = Theme color dark
    final barBg = isDark 
        ? (widget.themeColor?.withOpacity(0.12) ?? Colors.grey.shade900) 
        : Colors.white;
    
    // ✅ Waves: Light = Black, Dark = White
    final waveActive = isDark ? Colors.white : Colors.black;
    final waveInactive = isDark ? Colors.white.withOpacity(0.25) : Colors.black.withOpacity(0.2);
    
    // ✅ Timer text: Light = Black, Dark = White
    final timerText = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: barBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: _cancelVoice,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline,
                    color: Colors.redAccent, size: 24),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.white.withOpacity(0.06) 
                      : Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _isPaused ? Colors.grey : Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: _isPaused
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(
                                              0.5 * _pulseController.value),
                                          blurRadius: 6,
                                          spreadRadius: 2,
                                        ),
                                      ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDuration(_currentDurationMs),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: timerText,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AnimatedWaveformBar(
                            amplitudes: _amplitudes,
                            isPlaying: !_isPaused,
                            progress: 1.0,
                            activeColor: waveActive,
                            inactiveColor: waveInactive,
                            barWidth: 2.5,
                            maxBarHeight: 22,
                            barCount: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _togglePauseResume,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isPaused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              color: primary,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isPaused ? "Resume" : "Pause",
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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
            const SizedBox(width: 6),
            GestureDetector(
              onTap: stopRecordingAndPreview,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_circle_filled_rounded,
                  color: primary,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _stopAndSendDirectly,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PREVIEW BAR ====================
  Widget _buildPreviewBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = widget.themeColor ?? Theme.of(context).colorScheme.primary;
    
    // ✅ Background: Light = White, Dark = Theme dark
    final barBg = isDark 
        ? (widget.themeColor?.withOpacity(0.12) ?? Colors.grey.shade900) 
        : Colors.white;
    
    // ✅ Waves: Light = Black, Dark = White
    final waveActive = isDark ? Colors.white : Colors.black;
    final waveInactive = isDark ? Colors.white.withOpacity(0.25) : Colors.black.withOpacity(0.2);
    
    // ✅ Timer text: Light = Black, Dark = White
    final timerText = isDark ? Colors.white : Colors.black;

    double maxVal =
        _recordedDurationMs > 0 ? _recordedDurationMs.toDouble() : 1.0;
    double progress = (_previewPositionMs / maxVal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: barBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: _cancelVoice,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline,
                    color: Colors.redAccent, size: 24),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.white.withOpacity(0.06) 
                      : Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _togglePreviewPlayback,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPreviewPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: primary,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDuration(_previewPositionMs)} / ${_formatDuration(_recordedDurationMs)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: timerText,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AnimatedWaveformBar(
                        amplitudes: _amplitudes.isEmpty
                            ? List.filled(22, -30.0)
                            : _amplitudes,
                        isPlaying: _isPreviewPlaying,
                        progress: progress,
                        activeColor: waveActive,
                        inactiveColor: waveInactive,
                        barWidth: 2.5,
                        maxBarHeight: 22,
                        barCount: 22,
                        onSeek: (newRatio) async {
                          final seekMs = (newRatio * maxVal).toInt();
                          setState(() {
                            _previewPositionMs = seekMs;
                            _isPreviewCompleted = false;
                          });
                          await _playerService.seekTo(seekMs);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _backToRecordingMode,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mic_rounded,
                  color: primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _sendVoiceMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}