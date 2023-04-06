import 'package:chat_app_gpt/tts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatMessage extends StatefulWidget{
  ChatMessage({required this.text, required this.sender, required this.isMe});

  final String text;
  final String sender;
  final bool isMe;

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !widget.isMe ? const CircleAvatar(
            backgroundImage: AssetImage('assets/images/jarvis.png'),
          ) : Container(),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.isMe ? Colors.green : Colors.grey[300],
                borderRadius: widget.isMe ? const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ) : const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.sender,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
          widget.isMe ? const CircleAvatar(
            backgroundImage: AssetImage('assets/images/tony.jpg'),
          ) : Center(
            child: IconButton(
              icon: Icon(TextToSpeech.getVoiceEnabled() ? Icons.volume_off : Icons.volume_up),
              onPressed: () {
                if(TextToSpeech.getVoiceEnabled()) {
                  TextToSpeech.stop();
                } else {
                  TextToSpeech.speak(widget.text).then((value) =>  print('done' + TextToSpeech.getVoiceEnabled().toString()));
                }

                setState(() {});
              },
            )
            ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}