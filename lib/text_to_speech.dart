import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeech {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isVoiceEnabled = false;

  static initTTS() {
    _flutterTts.setLanguage("en-US");
  }

  static Future speak(String text) async {
    await _flutterTts.awaitSpeakCompletion(true);
    _isVoiceEnabled = true;
    _flutterTts.speak(text).then((value) => _isVoiceEnabled = false);
  }

  static void stop() {
    _isVoiceEnabled = false;
    _flutterTts.stop();
  }

  static bool getVoiceEnabled() {
    return _isVoiceEnabled;
  }

  static setLanguage(String language) async {
    await _flutterTts.setLanguage(language);
    print("Language set to: ${language}");
    print("Language set to: ${await _flutterTts.getDefaultVoice}");
    print("Language set to: ${await _flutterTts.getVoices}");
    print("Language set to: ${await _flutterTts.getDefaultEngine}");
    print("Language set to: ${await _flutterTts.getEngines}");
    print("Language set to: ${await _flutterTts.getLanguages}");
  }

}