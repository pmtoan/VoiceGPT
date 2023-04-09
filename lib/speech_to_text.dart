import 'package:easy_settings/easy_settings.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextManager {
  final SpeechToText _speechToText = SpeechToText();
  bool _isSpeechEnabled = false;

  static final List<Map<String, String>> supportedLanguages = [
    {'imageUrl': 'assets/images/united-states.png', 'name': 'English', 'value':'en_US'},
    {'imageUrl': 'assets/images/vietnam.png', 'name': 'Vietnamese', 'value':'vi_VN'},
  ];
  Map<String, String> _currentLanguage = supportedLanguages[0];

  LocaleName _selectedLocale = LocaleName('en_US', 'English');

  void _setLocale(Map<String, String> locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale_value', locale['value']!);
    await prefs.setString('locale_name', locale['name']!);
  }
  
  void getCurrentLanguageFromSetting() {
    switch(getSettingsPropertyValue('language')) {
      case 0:
        _currentLanguage = supportedLanguages
          .where((element) => 'English' == element['name']).first;
        break;
      case 1:
        _currentLanguage = supportedLanguages
          .where((element) => 'Vietnamese' == element['name']).first;
        break;
      default:
        _currentLanguage = supportedLanguages[0];
    }

    _setLocale(_currentLanguage!);
  }

  void setSpeechToTextLocale() async {
    if(_speechToText.isAvailable && _isSpeechEnabled) {
      var locales = await _speechToText.locales();

      _selectedLocale = locales
      .firstWhere((locale) => 
        locale.localeId == _currentLanguage!['value'].toString()
      );
    }
  }

  void initSpeech(Function(Function()) setStateCallBack) async {
    _isSpeechEnabled = await _speechToText.initialize();

    _speechToText.statusListener = (status) {
      if(status == 'done') {
        setStateCallBack(() {});
      }
       if(status == 'notListening') {
        setStateCallBack(() {});
      }
    };

    getCurrentLanguageFromSetting();  

    setSpeechToTextLocale();

    setStateCallBack(() {});
  }

  Future<void> startListening(
    void Function(SpeechRecognitionResult)? onSpeechResult, 
    void Function(void Function()) setStateCallBack
    ) async {
    await _speechToText.listen(
      onResult: onSpeechResult,
      localeId: _selectedLocale.localeId,
      listenMode: ListenMode.dictation,
    );

    setStateCallBack(() {
      debugPrint('start listening: ${_speechToText.isListening} ... $_isSpeechEnabled');
    });
  } 

  Future<void> stopListening(Function(Function()) setStateCallBack) async {
    await _speechToText.stop();

    setStateCallBack(() {
      debugPrint('stop listening: ${_speechToText.isListening} ... $_isSpeechEnabled');
    });
  }

  bool isSpeechEnabledOnDevice() {
    return _isSpeechEnabled;
  }

  bool isListening() {
    return _speechToText.isListening;
  }

  bool isNotListening() {
    return _speechToText.isNotListening;
  }

  Map<String, String> getCurrentLanguage(){
    return _currentLanguage;
  }
}