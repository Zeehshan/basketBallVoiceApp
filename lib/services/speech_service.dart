import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vibration/vibration.dart';
import '../models/shot_tracker.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  final ShotTracker _shotTracker;
  bool _isInitialized = false;

  SpeechService(this._shotTracker);

  Future<bool> initialize() async {
    try {
      if (!_isInitialized) {
        _isInitialized = await _speechToText.initialize(
          onError: (errorNotification) {
            if (kDebugMode) {
              debugPrint(
                'Speech recognition error: ${errorNotification.errorMsg}',
              );
            }
            _shotTracker.recognitionText =
                'Speech error: ${errorNotification.errorMsg}';
          },
          onStatus: (status) {
            if (kDebugMode) {
              debugPrint('Speech recognition status: $status');
            }
          },
        );
      }
      return _isInitialized;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize speech recognition: $e');
      }
      return false;
    }
  }

  String _lastPartialText = '';
  bool _isProcessing = false;
  Timer? _finalResultTimer;

  bool hasStoped = false;

  Future<void> toggleListening() async {
    if (!_isInitialized) {
      final isAvailable = await initialize();
      if (!isAvailable) {
        _shotTracker.recognitionText = 'Speech recognition not available';
        return;
      }
    }

    if (_speechToText.isListening) {
      hasStoped = true;
      // Cancel any pending final result timer
      _finalResultTimer?.cancel();

      // Don't process the last partial text when stopping
      _lastPartialText = '';
      await _speechToText.stop();
      _shotTracker.setListening(false);
      _isProcessing = false;
    } else {
      hasStoped = false;
      _lastPartialText =
          ''; // Reset the last partial text when starting new listening
      _isProcessing = false;

      await _speechToText.listen(
        onResult: (result) {
          final text = result.recognizedWords.toLowerCase();

          if (result.finalResult) {
            // Only process final results that are valid commands
            _finalResultTimer?.cancel();
            _processText(text);
          } else if (text.isNotEmpty) {
            // For partial results, update the last partial text
            _lastPartialText = text;

            // Set a timer to process the last partial text if it's a valid command
            _finalResultTimer?.cancel();
            _finalResultTimer = Timer(const Duration(milliseconds: 100), () {
              if (!_isProcessing && _isValidCommand(_lastPartialText)) {
                _isProcessing = true;
                _processText(_lastPartialText);
                _lastPartialText = '';
                _isProcessing = false;
              }
            });
          }
        },
        localeId: 'en_US',
        listenOptions: SpeechListenOptions(
          partialResults: true,
          onDevice: false,
          cancelOnError: true,
          autoPunctuation: true,
          enableHapticFeedback: true,
        ),
      );
      _shotTracker.setListening(true);
    }
  }

  bool _isValidCommand(String word) {
    return word.contains('good') || word.contains('miss');
  }

  void _processText(String text) {
    if (hasStoped) {
      return;
    }
    final words = text.split(' ');
    final lastWord = words.last.toLowerCase().trim();

    // Only process if the last word is a valid command
    if (!_isValidCommand(lastWord)) {
      return;
    }

    if (lastWord.contains('good') &&
        !_shotTracker.recognitionText.contains('✅')) {
      _shotTracker.incrementGood();
      _playSound('success');
    } else if (lastWord.contains('miss') &&
        !_shotTracker.recognitionText.contains('❌')) {
      _shotTracker.incrementMiss();
      _playSound('');
    }
  }

  Future<void> _playSound(String type) async {
    try {
      // Play system sound for better reliability
      final soundType = type == 'success'
          ? SystemSoundType.click
          : SystemSoundType.alert;
      await SystemSound.play(soundType);

      // Add haptic feedback
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        if (Platform.isIOS) {
          Vibration.vibrate(duration: 100);
        } else {
          Vibration.vibrate(duration: 50);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error playing sound: $e');
      }
    }
  }

  void dispose() {
    _finalResultTimer?.cancel();
    _speechToText.stop();
  }
}
