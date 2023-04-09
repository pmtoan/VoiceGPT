import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_app_gpt/message_management.dart';
import 'package:chat_app_gpt/message_model.dart';
import 'package:chat_app_gpt/openAI_api_management.dart';
import 'package:chat_app_gpt/settings_screen.dart';
import 'package:chat_app_gpt/speech_to_text.dart';
import 'package:chat_app_gpt/text_to_speech.dart';
import 'package:easy_settings/easy_settings.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
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
  List<Message> _messages = <Message>[];

  late GPTMessageManagement _gptMessageManagement;
  bool _isTyping = false;

  final SpeechToTextManager _speechToTextManager = SpeechToTextManager();

  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();

    getMessageHistory();

    _gptMessageManagement = GPTMessageManagement();

    _speechToTextManager.initSpeech(setState);

    settingsPropertyChangedNotifier.addListener((key) {
      switch (key) {
        case 'language':
          setState(() {
            _speechToTextManager.getCurrentLanguageFromSetting();  

            _speechToTextManager.setSpeechToTextLocale();
          });
          break;
        default:
      }
      
    });
  }

  getMessageHistory() async {
    _isLoading = true;
    final messageHistory = (await MessageManagement.db.getAllMessages()).reversed.toList();
    setState(() {
      _messages = messageHistory;
      _isLoading = false;
    });
  }

  _onDoneSpeechRecognition() async {
    await Future.delayed(const Duration(seconds: 2));
    _sendMessage();
  }

  _onSpeechResult(SpeechRecognitionResult result) {
    debugPrint('_onSpeechResult ${result.recognizedWords}');

    if(result.finalResult){
      _onDoneSpeechRecognition();
    }

    setState(() {
      _textController.text = result.recognizedWords;
    });
  }

  _sendMessage() {
    String myMessage = _textController.text;
    _textController.clear();

    Message newMessageFromMe = Message(isMe: true, text: myMessage);
    MessageManagement.db.newMessage(newMessageFromMe);

    setState(() {
      _messages.insert(0, newMessageFromMe);
      _isTyping = true;
    });

    _gptMessageManagement.sendMessageToGPT(myMessage).then((value) =>
    { 
      setState(() {
        String responseContent = value != '' ? value : 'I have some error, please try again later!';
        _isTyping = false;

        Message newMessageFromGPT = Message(isMe: false, text: responseContent, isFirstReading: false);
        MessageManagement.db.newMessage(newMessageFromGPT);

        _messages.insert(0, newMessageFromGPT);
      })
    });
  }

  _listen() async {
    if(_speechToTextManager.isNotListening()){
      if(!_speechToTextManager.isSpeechEnabledOnDevice()){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Speech not enabled'),
              content: const Text('Please enable speech on your device'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
          );
      } else {
        await _speechToTextManager.startListening(_onSpeechResult, setState);
      }
    } else {
      await _speechToTextManager.stopListening(setState);
    }
  }

  Widget _buildChatInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: context.cardColor,
      ),
      child: Row(
        crossAxisAlignment: _speechToTextManager.isNotListening() ? 
                              CrossAxisAlignment.end : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 9,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 300,
              ),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(15),
                  hintText: 'Aa...',
                  fillColor: Color.fromARGB(255, 238, 237, 237),
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25),
                  ),
                  )
                ),
                maxLines: null,
              ),
            ),
          ),
          _speechToTextManager.isNotListening() ? 
          Row(
            children:[
              IconButton(
                icon: Icon(
                    Icons.mic,
                    color: Theme.of(context).primaryColor,
                ),
                highlightColor: Colors.transparent,
                tooltip: 'Voice input',
                onPressed: _listen,
              ),
              IconButton(
                icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                highlightColor: Colors.transparent,
                onPressed: () {
                  _sendMessage();
                },
              ),
            ]
          )
          : 
          Expanded(
            flex: 3,
            child: AvatarGlow(
              showTwoGlows: true,
                animate: _speechToTextManager.isListening(),
                glowColor: Colors.red,
                endRadius: 35.0,
                duration: const Duration(milliseconds: 1500),
                repeatPauseDuration: const Duration(milliseconds: 100),
                repeat: true,
                child: SizedBox(
                  height: 75,
                  child: FloatingActionButton.small(
                    backgroundColor: Colors.red,
                    onPressed: _listen,
                    child: Icon(_speechToTextManager.isListening() ? Icons.mic : Icons.mic_none, size:18),
                  ),
                ),
              ),
          )
          
        ],
      ),
    );
  }

  Widget _buildLoadProgress(){
    return Stack(
      children: [
        Container(
          alignment: AlignmentDirectional.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10.0)
              ),
              width: 170.0,
              height: 150.0,
              alignment: AlignmentDirectional.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        value: null,
                        strokeWidth: 7.0,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 25.0),
                    child: const Center(
                      child: Text(
                        "Loading ...",
                        style: TextStyle(
                          color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 40,),
            Text('Chat with GPT-3', style: TextStyle(fontSize: 18.0)),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                // padding: const EdgeInsets.all(1.0),
                child: Image(
                  image: AssetImage(_speechToTextManager.getCurrentLanguage()['imageUrl']!.toString()),
                  fit: BoxFit.cover,
                  height: 25,
                  width: 40,
                ),
              ),
            )
            ]
            ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed:(){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen(callback: getMessageHistory)),
              );
            }
          ),
        ],
      ),
      body: Column(
          children: [
            Flexible(
                child: GestureDetector(
                  onTap: (){
                    FocusScopeNode currentFocus = FocusScope.of(context);

                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  },
                  child: _isLoading ? 
                  Center(
                    child: _buildLoadProgress(),
                  ) :
                  ListView.builder(
                    padding: const EdgeInsets.all(8),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ChatMessage(
                        message: _messages[index],
                        isAutoReading: _messages[index].isMe? false : getSettingsPropertyValue('auto_reading'),
                      );
                    },
                  ),
                ),
              ),
            _isTyping ? Center(
              child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: const ThreeDots()
              ),
            ) : Container(),
            _buildChatInput(),
            SizedBox(height: 5,)
          ],
        ),
    );
  }
}