import 'package:chat_app_gpt/message_management.dart';
import 'package:chat_app_gpt/tts.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:velocity_x/velocity_x.dart';

import 'ThreeDots.dart';
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

  @override
  void initState() {
    super.initState();
    gptMessageManagement = GPTMessageManagement();
    _initSpeech();
  }


  @override
  void dispose() {
    gptMessageManagement.dispose();
    super.dispose();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    print('start listening');

    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    print('stop listening');
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    print('_onSpeechResult ${result.recognizedWords}');
    setState(() {
      _textController.text = result.recognizedWords;
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

    final response = gptMessageManagement.sendMessageToGPT(myMessage).then((value) =>
    {
      setState(() {
        _isTyping = false;
        _messages.insert(0, ChatMessage(
          text: value,
          sender: 'J.A.R.V.I.S.',
          isMe: false,
        ));
      })
    });

    print(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatGPT Demo'),
      ),
      body: SafeArea(
        child: Column(
          children: [
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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: context.cardColor,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 300,
                        ),
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
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
                  ),
                  IconButton(
                    icon: Icon(
                        _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                        color: _speechToText.isListening ? Colors.red : Colors.black
                    ),
                    tooltip: 'Listen',
                    onPressed: () {
                      _speechToText.isNotListening ? _startListening() : _stopListening();

                      print('Listening: ${_speechToText.isListening}');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      _sendMessage();
                    },
                  )
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}