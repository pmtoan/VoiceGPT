import 'dart:async';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

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

  void _sendMessage() {
    _textController.clear();
    ChatMessage message = ChatMessage(
      text: _textController.text,
      sender: 'Me',
    );
    setState(() {
      _messages.insert(0, message);
    });

    final tController = StreamController<CTResponse?>.broadcast();

    print('Sending request to OpenAI...');
    print(openAI);

    final request = CompleteText(prompt: 'What is human life expectancy in the United States?',
        model: kCompletion, maxTokens: 200);
    openAI.onCompletionStream(request:request).listen((response) => print(response))
        .onError((err) {
      print("$err");
    });
  }


  @override
  void initState() {
    super.initState();
    openAI = OpenAI.instance.build(token: apiKey,baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),isLog: true);
  }


  @override
  void dispose() {
    _subscription?.cancel();
    tController.close();
    super.dispose();
  }

  Widget _buildTextComposer() {
    return Row(
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
    );
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
            Container(
              decoration: BoxDecoration(
                color: context.cardColor,
              ),
              child: _buildTextComposer(),
            )
          ],
        ),
      )
    );
  }
}