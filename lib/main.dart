import 'package:chat_app_gpt/chat_screen.dart';
import 'package:chat_app_gpt/text_to_speech.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  TextToSpeech.initTTS();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoiceGPT',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SafeArea(child: ChatScreen()),
    );
  }
}