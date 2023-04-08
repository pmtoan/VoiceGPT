import 'dart:async';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

class GPTMessageManagement {
  final String apiKey = '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';

  late OpenAI openAI ;

  List<Map<String, String>> history = [];

  GPTMessageManagement() {
    openAI = OpenAI.instance.build(
        token: apiKey,
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 60)),
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
      model: ChatModel.ChatGptTurbo0301Model,
      maxToken: 2048,
      messages: history,
    );

    final response = await openAI.onChatCompletion(request: request);

    String content = response!.choices[0].message.content;

    addMessageToHistory("assistant", content);

    return content;
  }
}