class VoiceMessageModel {
  final String id;
  final String filePath;
  final int durationMs;
  final DateTime timestamp;
  final bool isFromMe;

  VoiceMessageModel({
    required this.id,
    required this.filePath,
    required this.durationMs,
    required this.timestamp,
    required this.isFromMe,
  });
}