import 'dart:convert';

import 'package:sowaan_chat/models/messages.dart';

import '../box.dart';
import '../models/chats.dart';

class DataBase {
  List<Chats> chats = [];
  Map<String, List<Messages>> messages = {};

  void loadChats() async {
    List<dynamic> dynamicChats = await boxChats.get("CHATS");
    chats = dynamicChats.map((item) {
      return item as Chats;
    }).toList();
  }

  void updateChats() {
    boxChats.put("CHATS", chats);
  }

  Future<void> loadMessages(String id) async {
    List<dynamic> dynamicMessages = await boxChatsDetails.get(id);
    messages[id] = dynamicMessages.map((item) {
      return item as Messages;
    }).toList();
  }

  void updateMessages(String id) {
    if (messages.containsKey(id)) {
      boxChatsDetails.put(id, messages[id]);
    }
  }

  void addMessage(String id, message) {
    if (!messages.containsKey(id)) {
      messages[id] = [];
    }
    messages[id]!.insert(0, Messages.fromJson(message));
    updateMessages(id);
  }
}
