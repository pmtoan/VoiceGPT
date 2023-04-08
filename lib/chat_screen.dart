import 'package:chat_app_gpt/message_management.dart';
import 'package:chat_app_gpt/text_to_speech.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:velocity_x/velocity_x.dart';

import 'three_dots.dart';
import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>{
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  bool _isTyping = false;
  late GPTMessageManagement gptMessageManagement;

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  final List<Map<String, String>> supportedLanguages = [
    {'imageUrl': 'assets/images/united-states.png', 'name': 'English', 'value':'en-US'},
    {'imageUrl': 'assets/images/vietnam.png', 'name': 'Vietnamese', 'value':'vi-VN'},
  ];
  Map<String, String>? _currentLanguage;
  LocaleName _selectedLocale = LocaleName('en_US', 'English');

  @override
  void initState() {
    super.initState();
    gptMessageManagement = GPTMessageManagement();

    _currentLanguage = supportedLanguages.first;
    setLocale(_currentLanguage!);

    _initSpeech();
  }

  void setLocale(Map<String, String> locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale_value', locale['value']!);
    await prefs.setString('locale_name', locale['name']!);
  }

  void _setTextToSpeechLocale() async {
    if(_speechToText.isAvailable && _speechEnabled) {
      var locales = await _speechToText.locales();

      _selectedLocale = locales
      .firstWhere((locale) => 
        locale.localeId == _currentLanguage!['value'].toString().replaceAll('-', '_')
      );
    }
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();

   _setTextToSpeechLocale();

    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: _selectedLocale.localeId,
      listenMode: ListenMode.confirmation,
    );
    setState(() {
      debugPrint('start listening: ${_speechToText.isListening} ... ${_speechEnabled}');
    });
  } 

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      debugPrint('stop listening: ${_speechToText.isListening} ... ${_speechEnabled}');
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    debugPrint('_onSpeechResult ${result.recognizedWords}');
    setState(() {
      _textController.text = result.recognizedWords;
      if(result.finalResult){
        _sendMessage();
      }
    });
  }

  void _sendMessage() {
    String myMessage = _textController.text;
    _textController.clear();

    ChatMessage message = ChatMessage(
      text: myMessage,
      sender: 'MToan',
      isMe: true,
    );

    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    gptMessageManagement.sendMessageToGPT(myMessage).then((value) =>
    { 
      setState(() {
        _isTyping = false;
        _messages.insert(0, ChatMessage(
          text: value,
          sender: 'GPT',
          isMe: false,
        ));

        TextToSpeech.speak(value);
      })
    }).timeout(const Duration(seconds: 60), onTimeout: () => {
      setState(() {
        _isTyping = false;
        _messages.insert(0, ChatMessage(
          text: 'I have some error, please try again later!',
          sender: 'GPT',
          isMe: false,
        ));
      })
    });
  }

  Widget _buildDropdown(){
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        isExpanded: true,
        isDense: true,
        items: supportedLanguages.map((e) => DropdownMenuItem(
          value: e,
          child: Row(
            children: [
              Image.asset(e['imageUrl']!, width: 30, height: 30,),
              SizedBox(width: 10,),
              Text(e['name']!, style: TextStyle(fontSize: 14, color: Colors.black),)
            ],
          ),
        )).toList(),
        value: _currentLanguage,
        onChanged: (value) {
          setState(() {
            _currentLanguage = value as Map<String, String>?;
            TextToSpeech.setLanguage(_currentLanguage!['value']!);  
            _setTextToSpeechLocale();
          });
        },
        buttonStyleData: ButtonStyleData(
          height: 45,
          width: 200,
          padding: const EdgeInsets.only(left: 14, right: 14),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
            border: Border.all(
              color: Color.fromARGB(66, 83, 80, 80),
            ),
            color: Color.fromARGB(255, 216, 221, 217),
          ),
          elevation: 2,
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.arrow_forward_ios_outlined,
          ),
          iconSize: 14,
          iconEnabledColor: Colors.black,
          iconDisabledColor: Colors.grey,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          width: 200,
          padding: null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Color.fromARGB(255, 216, 221, 217),
          ),
          elevation: 8,
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all(6),
            thumbVisibility: MaterialStateProperty.all(true),
          )
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.only(left: 14, right: 14),
        ),
      )
    );
  }

  Widget _buildChatInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: context.cardColor,
      ),
      child: Row(
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 300,
              ),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Type your message here...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                onChanged: (value) {
                  setState(() {
                    _isTyping = value.isNotEmpty;
                  });
                },
              ),
            ),
          ),
          IconButton(
            icon: Icon(
                _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                color: _speechToText.isNotListening ? Colors.black : Colors.red
            ),
            tooltip: 'Listen',
            onPressed: () {
              _speechToText.isNotListening ? _startListening() : _stopListening();
            },
          ),
          _speechToText.isNotListening ?
          IconButton(
            icon: const Icon(Icons.send, color: Colors.green),
            onPressed: () {
              _sendMessage();
            },
          ) : Container(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: const Text('VoiceGPT'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed:(){
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => SettingScreen()),
              // );
            }
          ),
        ],
      ),
      body: Column(
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildDropdown()
                ],
              ),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              ),
            ),
            _isTyping ? Center(
              child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: ThreeDots()
              ),
            ) : Container(),
            const Divider(height: 1),
            _buildChatInput()
          ],
        ),
    );
  }
}