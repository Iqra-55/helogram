class VoiceMessageModel {
  final String id;
  final String filePath; // Local path ya remote URL
  final int durationMs;
  final DateTime timestamp;
  final bool isFromMe;
  final List<double>? waveformData; // Optional: real waveform heights

  VoiceMessageModel({
    required this.id,
    required this.filePath,
    required this.durationMs,
    required this.timestamp,
    required this.isFromMe,
    this.waveformData,
  });

  String get formattedDuration {
    final seconds = (durationMs ~/ 1000);
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}