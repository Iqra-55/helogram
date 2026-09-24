import 'dart:async';
import 'package:flutter/material.dart';
import 'models/voice_message_model.dart';
import 'services/voice_player_service.dart';
import 'widgets/voice_record_bar.dart';

mixin ChatVoiceMixin<T extends StatefulWidget> on State<T> {
  // Voice State
  bool showVoiceBar = false;
  final VoicePlayerService voicePlayer = VoicePlayerService();
  int currentPlaybackPosition = 0;
  bool isPlaying = false;
  String? currentlyPlayingPath;

  StreamSubscription<dynamic>? playerStateSub;
  StreamSubscription<Duration>? playerPositionSub;
  StreamSubscription<void>? playerCompletionSub;

  // Global Key for VoiceRecordBar
  final GlobalKey<VoiceRecordBarState> voiceRecordBarKey = GlobalKey();

  Future<void> initVoicePlayer() async {
    playerStateSub = voicePlayer.stateStream.listen((state) {
      if (mounted) {
        setState(() => isPlaying = state.toString() == 'PlayerState.playing');
      }
    });

    playerPositionSub = voicePlayer.positionStream.listen((duration) {
      if (mounted) setState(() => currentPlaybackPosition = duration.inMilliseconds);
    });

    playerCompletionSub = voicePlayer.completionStream.listen((_) {
      if (mounted) {
        setState(() {
          currentPlaybackPosition = 0;
          isPlaying = false;
          currentlyPlayingPath = null;
        });
      }
    });
  }

  void disposeVoicePlayer() {
    playerStateSub?.cancel();
    playerPositionSub?.cancel();
    playerCompletionSub?.cancel();
    voicePlayer.dispose();
  }

  Future<void> playVoiceMessage(String filePath, int duration) async {
    if (currentlyPlayingPath == filePath && isPlaying) {
      await voicePlayer.pause();
      return;
    }

    if (currentlyPlayingPath != filePath) {
      await voicePlayer.stop();
      final success = await voicePlayer.preparePlayer(filePath);
      if (!success) return;
      currentlyPlayingPath = filePath;
    }

    if (currentlyPlayingPath == filePath && !isPlaying) {
      await voicePlayer.seekTo(0);
    }

    await voicePlayer.play();
  }

  String formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String formatDurationMs(int ms) {
    return formatDuration(ms ~/ 1000);
  }

  Widget buildVoiceBubble(
    Map<String, dynamic> msg,
    bool isMe,
    Color iconColor,
    Color primaryColor,
    TextTheme textTheme,
  ) {
    final duration = msg['duration'] ?? 0;
    final voicePath = msg['voicePath']?.toString() ?? '';
    final isThisPlaying = isPlaying && currentlyPlayingPath == voicePath;
    final progress = duration > 0
        ? (currentPlaybackPosition / (duration * 1000)).clamp(0.0, 1.0)
        : 0.0;

    final bubbleIconColor = isMe ? Colors.white : primaryColor;
    final bubbleWaveformActive = isMe ? Colors.white : primaryColor;
    final bubbleWaveformBg = isMe
        ? Colors.white.withOpacity(0.3)
        : iconColor.withOpacity(0.2);
    final bubbleTextColor = isMe ? Colors.white.withOpacity(0.9) : iconColor;

    return GestureDetector(
      onTap: () => playVoiceMessage(voicePath, duration),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isMe ? Colors.white.withOpacity(0.2) : primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isThisPlaying ? Icons.pause : Icons.play_arrow,
              color: bubbleIconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(20, (index) {
                      final barProgress = index / 20;
                      final isActive = barProgress <= progress;
                      final heightFactor = 0.3 + ((index * 7) % 10) / 10.0;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 2.5,
                        height: isThisPlaying && isActive
                            ? 6 + (heightFactor * 16)
                            : 4 + (heightFactor * 12),
                        decoration: BoxDecoration(
                          color: isThisPlaying && isActive ? bubbleWaveformActive : bubbleWaveformBg,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: isThisPlaying ? progress : 0.0,
                      backgroundColor: bubbleWaveformBg,
                      valueColor: AlwaysStoppedAnimation<Color>(bubbleWaveformActive),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isThisPlaying
                ? '${formatDurationMs(currentPlaybackPosition)} / ${formatDuration(duration)}'
                : formatDuration(duration),
            style: textTheme.labelSmall?.copyWith(
              color: bubbleTextColor,
              fontFamily: 'Poppins',
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
