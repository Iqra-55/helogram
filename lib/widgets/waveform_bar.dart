import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Interactive Waveform Bar Component with Scrubbing & Dual-Color Progress
class AnimatedWaveformBar extends StatelessWidget {
  final List<double> amplitudes; // Raw or static dB values
  final bool isPlaying;
  final double progress; // Progress from 0.0 to 1.0
  final Color activeColor;
  final Color inactiveColor;
  final double barWidth;
  final double maxBarHeight;
  final int barCount;
  final double noiseFloorDb;
  final double maxDb;
  final ValueChanged<double>? onSeek; // Callback when user taps/drags

  const AnimatedWaveformBar({
    super.key,
    required this.amplitudes,
    required this.isPlaying,
    required this.progress,
    required this.activeColor,
    this.inactiveColor = Colors.grey,
    this.barWidth = 3,
    this.maxBarHeight = 28,
    this.barCount = 30,
    this.noiseFloorDb = -50.0,
    this.maxDb = -2.0,
    this.onSeek,
  });

  double _normalizeAmplitude(double rawDb) {
    if (rawDb <= noiseFloorDb) return 0.0;
    if (rawDb >= maxDb) return 1.0;
    return (rawDb - noiseFloorDb) / (maxDb - noiseFloorDb);
  }

  void _handleGesture(Offset localPosition, double totalWidth) {
    if (onSeek == null || totalWidth <= 0) return;
    // Calculate progress ratio (0.0 to 1.0) based on drag position
    final double newProgress = (localPosition.dx / totalWidth).clamp(0.0, 1.0);
    onSeek!(newProgress);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => _handleGesture(details.localPosition, totalWidth),
          onHorizontalDragUpdate: (details) => _handleGesture(details.localPosition, totalWidth),
          child: RepaintBoundary(
            child: SizedBox(
              height: maxBarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(barCount, (index) {
                  double normalizedAmp = 0.0;

                  if (index < amplitudes.length) {
                    normalizedAmp = _normalizeAmplitude(amplitudes[index]);
                  }

                  // Height logic: maintain minimal height if quiet or stopped
                  final double targetHeight = 2.0 + (normalizedAmp * (maxBarHeight - 2.0));

                  // Dual-color logic: determine if this bar has been played yet
                  final double barRatio = index / barCount;
                  final bool isPlayed = barRatio <= progress;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 60),
                    curve: Curves.easeOutQuad,
                    width: barWidth,
                    height: targetHeight,
                    decoration: BoxDecoration(
                      color: isPlayed
                          ? activeColor
                          : inactiveColor.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(barWidth / 2),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Full Interactive Audio Player Screen
class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  bool isPlaying = false;
  double currentPositionMs = 0.0;
  double totalDurationMs = 10000.0; // 10 seconds audio message
  late List<double> amplitudes;
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    // Generate static amplitude profile for a pre-recorded voice note
    amplitudes = List.generate(30, (index) {
      return -50.0 + math.Random().nextDouble() * 45;
    });
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _togglePlayback() {
    if (isPlaying) {
      _pausePlayback();
    } else {
      _startPlayback();
    }
  }

  void _startPlayback() {
    if (currentPositionMs >= totalDurationMs) {
      currentPositionMs = 0.0;
    }

    setState(() {
      isPlaying = true;
    });

    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;

      setState(() {
        currentPositionMs += 100;

        if (currentPositionMs >= totalDurationMs) {
          _pausePlayback(autoReset: true);
        }
      });
    });
  }

  void _pausePlayback({bool autoReset = false}) {
    _playbackTimer?.cancel();
    if (!mounted) return;

    setState(() {
      isPlaying = false;
      if (autoReset) {
        currentPositionMs = 0.0;
      }
    });
  }

  // Handle seeking from waveform drag/tap
  void _onSeek(double progressRatio) {
    setState(() {
      currentPositionMs = progressRatio * totalDurationMs;
    });
  }

  String _formatDuration(double milliseconds) {
    final seconds = (milliseconds / 1000).toInt();
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (currentPositionMs / totalDurationMs).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              // Play/Pause Control
              IconButton(
                iconSize: 36,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_filled_rounded,
                  color: Colors.greenAccent,
                ),
                onPressed: _togglePlayback,
              ),

              const SizedBox(width: 12),

              // Interactive Waveform
              Expanded(
                child: AnimatedWaveformBar(
                  amplitudes: amplitudes,
                  isPlaying: isPlaying,
                  progress: progress,
                  activeColor: Colors.greenAccent,
                  inactiveColor: Colors.white38,
                  barCount: 30,
                  maxBarHeight: 28,
                  onSeek: _onSeek,
                ),
              ),

              const SizedBox(width: 12),

              // Time Indicator
              Text(
                _formatDuration(currentPositionMs),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}