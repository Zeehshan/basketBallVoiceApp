import 'dart:async';
import 'package:flutter/foundation.dart';

class ShotTracker extends ChangeNotifier {
  int _totalShots = 0;
  int _goodShots = 0;
  bool _isListening = false;
  String _recognitionText = '';
  Timer? _messageTimer;

  int get totalShots => _totalShots;
  int get goodShots => _goodShots;
  bool get isListening => _isListening;
  String get recognitionText => _recognitionText;

  int get missShots => _totalShots - _goodShots;
  
  double get accuracy {
    return _totalShots > 0 ? (_goodShots / _totalShots * 100) : 0;
  }

  void incrementGood() {
    _goodShots++;
    _totalShots++;
    _recognitionText = '✅ Good shot!';
    notifyListeners();
    _resetMessage();
  }

  void incrementMiss() {
    _totalShots++;
    _recognitionText = '❌ Missed shot';
    notifyListeners();
    _resetMessage();
  }

  void setListening(bool listening) {
    _isListening = listening;
    if (!listening) {
      _recognitionText = 'Tap mic to start listening';
    } else {
      _recognitionText = 'Listening...';
    }
    notifyListeners();
  }
  
  set recognitionText(String text) {
    _recognitionText = text;
    notifyListeners();
  }

  void reset() {
    _totalShots = 0;
    _goodShots = 0;
    _recognitionText = '';
    _isListening = false;
    notifyListeners();
  }

  void _resetMessage() {
    _messageTimer?.cancel();
    _messageTimer = Timer(const Duration(seconds: 1), () {
      if (_recognitionText.isNotEmpty && _isListening) {
        _recognitionText = 'Listening...';
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }
}
