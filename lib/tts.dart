import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeech {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isVoiceEnabled = false;

  static initTTS() async {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setVoice({"name": "en-NG-language", "locale": "en-NG"});
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

}