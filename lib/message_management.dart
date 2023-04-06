import 'dart:async';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

class GPTMessageManagement {
  final String apiKey = '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';

  late OpenAI openAI ;
  final tController = StreamController<CTResponse?>.broadcast();

  List<Map<String, String>> history = [];

  GPTMessageManagement() {
    openAI = OpenAI.instance.build(
        token: apiKey,
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 50)),
        isLog: true
    );
  }

  Future<String> sendMessageToGPT(String text) async {
    final request = ChatCompleteText(
      model: ChatModel.ChatGptTurbo0301Model,
      maxToken: 2048,
      messages: history,
    );

    addMessageToHistory("user", text);

    final response = await openAI.onChatCompletion(request: request);

    String content = response!.choices[0].message.content;

    addMessageToHistory("assistant", content);

    return content;
  }

  void addMessageToHistory(String role, String content) {
    history.add({"role": role, "content": content});

    if(history.length > 6) {
      history.removeAt(0);
    }
  }

  void dispose() {
    tController.close();
  }

}