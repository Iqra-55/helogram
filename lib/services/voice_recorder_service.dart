import 'dart:async';

import 'dart:io';

import 'dart:math' as math;

import 'package:audio_waveforms/audio_waveforms.dart';

import 'package:flutter/foundation.dart';

import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';



class VoiceRecorderService {

  RecorderController? _recorderController;

  bool _isInitialized = false;

  String? _currentPath;

  bool _isPaused = false; // 🆕 ADDITION 1



  // 🆕 ADDITION 2 — Getter taake VoiceRecordBar path access kar sake

  String? get currentPath => _currentPath;



  final List<double> _amplitudes = [];

  final _amplitudesController = StreamController<List<double>>.broadcast();

  final _durationController = StreamController<Duration>.broadcast();



  Stream<List<double>> get amplitudesStream => _amplitudesController.stream;

  Stream<Duration> get durationStream => _durationController.stream;



  RecorderController? get controller => _recorderController;

  bool get isInitialized => _isInitialized;



  Timer? _durationTimer;

  Timer? _ampTimer;

  int _elapsedSeconds = 0;



  Future<void> initialize() async {

    if (_isInitialized) return;

    _recorderController = RecorderController();

    _isInitialized = true;

  }



  Future<bool> requestPermission() async {

    final status = await Permission.microphone.request();

    return status.isGranted;

  }



  Future<String?> startRecording() async {

    if (!_isInitialized) await initialize();

    if (!await requestPermission()) return null;



    try {

      final dir = await getTemporaryDirectory();

      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      _currentPath = '${dir.path}/$fileName';

      _amplitudes.clear();

      _elapsedSeconds = 0;

      _isPaused = false; // 🆕 Reset



      await _recorderController?.record(path: _currentPath!);

     

      _startAmplitudeSimulation();

      _startDurationTimer();



      return _currentPath;

    } catch (e) {

      _currentPath = null;

      return null;

    }

  }



  void _startAmplitudeSimulation() {

    _ampTimer?.cancel();

    _ampTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {

      if (_recorderController == null || _isPaused) { // 🆕 Check _isPaused

        return;

      }

      final random = math.Random();

      final amplitude = -140 + random.nextDouble() * 120;

      _amplitudes.add(amplitude);

      if (_amplitudes.length > 35) _amplitudes.removeAt(0);

      _amplitudesController.add(List.unmodifiable(_amplitudes));

    });

  }



  void _startDurationTimer() {

    _durationTimer?.cancel();

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {

      if (_isPaused) return; // 🆕 Don't increment if paused

      _elapsedSeconds++;

      _durationController.add(Duration(seconds: _elapsedSeconds));

    });

  }



  // 🔴 PAUSE RECORDING

  Future<void> pauseRecording() async {

    if (!_isInitialized) return;

    await _recorderController?.pause();

    _isPaused = true; // 🆕 Mark as paused

    _durationTimer?.cancel();

    _ampTimer?.cancel();

  }



  // 🔴 RESUME RECORDING — Same file continue hogi

  Future<void> resumeRecording() async {

    if (!_isInitialized) return;

   

    // 🆕 ADDITION 3 — Same path pe dubara record shuru karo

    if (_currentPath != null) {

      await _recorderController?.record(path: _currentPath!);

    }

   

    _isPaused = false;

    _startAmplitudeSimulation();

    _startDurationTimer();

  }



  Future<({String path, int durationMs})?> stopRecording() async {

    if (!_isInitialized) return null;

    try {

      _durationTimer?.cancel();

      _ampTimer?.cancel();

      final path = await _recorderController?.stop();

      final elapsedMs = _elapsedSeconds * 1000;

      final finalPath = path ?? _currentPath;

      _currentPath = null;

      _amplitudes.clear();

      _isPaused = false; // 🆕 Reset

      if (finalPath == null) return null;

      return (path: finalPath, durationMs: elapsedMs);

    } catch (e) {

      return null;

    }

  }



  Future<void> cancelRecording() async {

    if (!_isInitialized) return;

    _durationTimer?.cancel();

    _ampTimer?.cancel();

    try {

      await _recorderController?.stop();

      if (_currentPath != null) {

        final file = File(_currentPath!);

        if (await file.exists()) await file.delete();

        _currentPath = null;

      }

      _amplitudes.clear();

      _isPaused = false; // 🆕 Reset

    } catch (e) {}

  }



  void dispose() {

    _durationTimer?.cancel();

    _ampTimer?.cancel();

    _recorderController?.dispose();

    _recorderController = null;

    _amplitudesController.close();

    _durationController.close();

    _isInitialized = false;

  }

} 

