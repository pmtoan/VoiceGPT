import 'package:chat_app_gpt/message_management.dart';
import 'package:chat_app_gpt/message_model.dart';
import 'package:chat_app_gpt/text_to_speech.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatefulWidget{
  ChatMessage({
    required this.message,
    required this.isAutoReading,
    });

  Message message;
  bool isAutoReading;
  bool isReading = false;

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  done(bool status){
    debugPrint('done ${status}');
    setState(() {
      widget.isReading = status;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(widget.isAutoReading && !widget.message.isFirstReading) {
      TextToSpeechManager.speak(widget.message.text, done);
    }

    widget.message.isFirstReading = true;
    MessageManagement.db.markedFirstReading(widget.message);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: widget.message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !widget.message.isMe ? const CircleAvatar(
            backgroundImage: AssetImage('assets/images/gpt_avt_02.webp'),
          ) : SizedBox(width: 40),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.message.isMe ? Colors.green : Color.fromARGB(255, 230, 230, 230),
                borderRadius: widget.message.isMe ? const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ) : const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Text(
                widget.message.text,
                style: TextStyle(
                  fontSize: 16.0,
                  color: widget.message.isMe ? Colors.white : Colors.black,
                )
              ),
            ),
          ),
          widget.message.isMe ? const SizedBox(width: 10) : 
          IconButton(
            icon: Icon(
              widget.isReading ? 
              Icons.stop_circle : 
              Icons.play_circle_outline_outlined,
              color: Theme.of(context).primaryColor,
              ),
            onPressed: () {
              if(widget.isReading) {
                TextToSpeechManager.stop(done);
              } else {
                TextToSpeechManager.speak(widget.message.text, done);
              }
            }
          ),
        ],
      ),
    );
  }
}