import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/foundation.dart';

class VoicePlayerService {
  PlayerController? _playerController;
  String? _currentPath;

  final _positionController = StreamController<Duration>.broadcast();
  final _stateController = StreamController<PlayerState>.broadcast();
  final _completionController = StreamController<void>.broadcast();

  Stream<Duration> get positionStream => _positionController.stream;
  Stream<PlayerState> get stateStream => _stateController.stream;
  Stream<void> get completionStream => _completionController.stream;

  String? get currentPath => _currentPath;

  Future<bool> preparePlayer(String filePath) async {
    if (_playerController != null) {
      try {
        await _playerController!.stopPlayer();
        _playerController!.dispose();
      } catch (e) {}
      _playerController = null;
    }

    try {
      _playerController = PlayerController();
      _currentPath = filePath;

      await _playerController!.preparePlayer(
        path: filePath,
        shouldExtractWaveform: false,
      );

      _playerController!.onCurrentDurationChanged.listen((ms) {
        if (!_positionController.isClosed) {
          _positionController.add(Duration(milliseconds: ms));
        }
      });

      _playerController!.onPlayerStateChanged.listen((state) {
        if (!_stateController.isClosed) {
          _stateController.add(state);
        }
      });

      _playerController!.onCompletion.listen((_) {
        if (!_completionController.isClosed) {
          _completionController.add(null);
        }
      });

      return true;
    } catch (e) {
      debugPrint("preparePlayer error: $e");
      return false;
    }
  }

  Future<void> play() async {
    if (_playerController == null) return;
    try {
      await _playerController!.startPlayer();
    } catch (e) {
      debugPrint("play error: $e");
    }
  }

  Future<void> pause() async {
    if (_playerController == null) return;
    try {
      await _playerController!.pausePlayer();
    } catch (e) {
      debugPrint("pause error: $e");
    }
  }

  Future<void> togglePlayPause() async {
    if (_playerController == null) return;
    final state = _playerController!.playerState;
    if (state == PlayerState.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seekTo(int positionMs) async {
    if (_playerController == null) return;
    try {
      await _playerController!.seekTo(positionMs);
    } catch (e) {
      debugPrint("seek error: $e");
    }
  }

  Future<void> stop() async {
    if (_playerController == null) return;
    try {
      await _playerController!.stopPlayer();
    } catch (e) {}
  }

  Future<int?> getTotalDuration() async {
    if (_playerController == null) return null;
    try {
      return await _playerController!.getDuration(DurationType.max);
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    try {
      _playerController?.stopPlayer();
      _playerController?.dispose();
    } catch (e) {}
    _playerController = null;
    _currentPath = null;
    _positionController.close();
    _stateController.close();
    _completionController.close();
  }
}