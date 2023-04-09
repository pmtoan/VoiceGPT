import 'dart:async';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:sqflite/sqflite.dart';

class GPTMessageManagement {
  final String apiKey = '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';

  late OpenAI openAI ;

  List<Map<String, String>> history = [];

  GPTMessageManagement() {
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

    if(history.length > 8) {
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