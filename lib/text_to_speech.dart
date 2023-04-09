import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechManager {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isVoiceEnabled = false;

  static initTTS() {
    _flutterTts.setLanguage("en-US");

    _flutterTts.setCompletionHandler(() {
      _isVoiceEnabled = false;
    });

    _flutterTts.setStartHandler(() {
      _isVoiceEnabled = true;
    });
    
    _flutterTts.setCancelHandler(() {
      _isVoiceEnabled = false;
    });
  }

  static void speak(String text) {
    _flutterTts.speak(text);
  }

  static void stop() {
    _flutterTts.stop();
  }

  static bool getVoiceEnabled() {
    return _isVoiceEnabled;
  }

  static Future<void> setLanguage(String language) async {
    await _flutterTts.setLanguage(language);
    debugPrint("Language set to: ${await _flutterTts.getLanguages}");
  }

}