import 'dart:async';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
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

  final String apiKey = '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';

  late OpenAI openAI ;
  final tController = StreamController<CTResponse?>.broadcast();
  StreamSubscription? _subscription;

  bool _isTyping = false;

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

    final request = ChatCompleteText(
      model: ChatModel.ChatGptTurbo0301Model,
      maxToken: 500,
      messages: [Map.of({"role": "user", "content": myMessage})],
    );

    final response = openAI.onChatCompletion(request: request).then((value) => {
      print("data -> ${value!.choices[0].message.content}"),
      setState(() {
        _isTyping = false;
        _messages.insert(0, ChatMessage(
          text: value.choices[0].message.content,
          sender: 'J.A.R.V.I.S.',
          isMe: false,
        ));
      })
    });

    print(response);
  }

  @override
  void initState() {
    super.initState();
    openAI = OpenAI.instance.build(
        token: apiKey,
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 50)),
        isLog: true
    );
  }


  @override
  void dispose() {
    _subscription?.cancel();
    tController.close();
    super.dispose();
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
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration.collapsed(hintText: 'Send a message'),
                    ),
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