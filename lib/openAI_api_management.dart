import 'dart:async';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class GPTMessageManagement {
  final String apiKey = dotenv.get('OPENAI_API_KEY');

  late OpenAI openAI ;

  List<Map<String, String>> history = [];

  GPTMessageManagement() {
    debugPrint(apiKey);
    openAI = OpenAI.instance.build(
        token: apiKey,
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 120)),
        isLog: true
    );
  }

  void chatCompleteWithSSE(String text, dynamic Function(Stream<List<int>>) callback) {
    addMessageToHistory("user", text);

    final request = ChatCompleteText(
      messages: history, 
      maxToken: 2048, 
      model: ChatModel.ChatGptTurboModel
    );

    openAI.onChatCompletionSSE(
      request: request,
      complete: callback
      );
  }

  void addMessageToHistory(String role, String content) {
    history.add({"role": role, "content": content});

    if(history.length > 6) {
      history.removeAt(0);
    }
  }

  Future<String> sendMessageToGPT(String text) async {
    addMessageToHistory("user", text);

    final request = ChatCompleteText(
      model: ChatModel.ChatGptTurboModel,
      maxToken: 2048,
      messages: history,
    );
    try{
      final response = await openAI.onChatCompletion(request: request);
      if(response != null){
        String content = response.choices[0].message.content;

        addMessageToHistory("assistant", content);

        return content;
      }
    } catch(e) {
      print(e);
    }
    
    return "";
  }
}