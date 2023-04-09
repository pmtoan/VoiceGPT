import 'dart:convert';

Message messageFromJson(String str) {
  final jsonData = json.decode(str);
  return Message.fromMap(jsonData);
}

String messageToJson(Message data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Message {
  int id;
  String text;
  bool isMe;
  bool isFirstReading;

  Message({
    this.id = 0,
    required this.text,
    required this.isMe,
    this.isFirstReading = true,
  });

  factory Message.fromMap(Map<String, dynamic> json) => Message(
        id: json["id"],
        text: json["text"],
        isMe: json["isMe"] == 1 ? true : false,
        isFirstReading: json["isFirstReading"] == 1 ? true : false,
      );

  Map<String, dynamic> toMap() => {
    "text": text,
    "isMe": isMe ? 1 : 0,
    "isFirstReading": isFirstReading ? 1 : 0,
  };
}