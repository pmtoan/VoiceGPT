import 'dart:async';
import 'dart:io';

import 'package:chat_app_gpt/message_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MessageManagement {
  MessageManagement._();
  static final MessageManagement db = MessageManagement._();

  static Database? _database;
  static String databaseName = 'Message';

  Future<Database> get database async =>
      _database ??= await initDB();

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "message_history.db");
    return await openDatabase(path, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE $databaseName ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT , "
          "text TEXT , "
          "isMe BIT , "
          "isFirstReading BIT "
          ");");
    });
  }
  
  newMessage(Message newMessage) async {
    final db = await database;
    var res = await db.insert(databaseName, newMessage.toMap());
    return res;
  }

  Future<List<Message>> getAllMessages() async {
    final db = await database;
    var res = await db.query(databaseName);
    List<Message> list =
        res.isNotEmpty ? res.map((m) => Message.fromMap(m)).toList() : [];
    return list;
  }

  markedFirstReading(Message message) async {
    final db = await database;
    Message readMessage = Message(
        id: message.id,
        text: message.text,
        isMe: message.isMe,
        isFirstReading: true);
    var res = await db.update(databaseName, readMessage.toMap(),
        where: "id = ?", whereArgs: [readMessage.id]);
    return res;
  }
  
  deleteAll() async {
    final db = await database;
    db.rawDelete("DELETE FROM $databaseName");
  }
}