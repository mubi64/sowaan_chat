import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:chat_message_timestamp/chat_message_timestamp.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:sowaan_chat/box.dart';
import 'package:sowaan_chat/data/database.dart';
import 'package:sowaan_chat/models/messages.dart';
import 'package:sowaan_chat/networking/api_helpers.dart';
import 'package:sowaan_chat/networking/dio_client.dart';
import 'package:sowaan_chat/utils/shared_pref.dart';
import 'package:sowaan_chat/utils/utils.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../socket/websocket_manager.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../widgets/messages_bar.dart';

class ChatDetailView extends StatefulWidget {
  final String id;
  final String name;
  final bool isGroup;

  const ChatDetailView(
      {super.key, required this.name, required this.id, required this.isGroup});

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  Utils utils = Utils();
  SharedPref prefs = SharedPref();
  DataBase db = DataBase();
  List<Messages> messages = [];
  final TextEditingController _controller = TextEditingController();
  // PagewiseLoadController<Messages>? _messagesLoadController;
  IO.Socket? socket;

  int pageSize = 100;
  final PagingController<int, Messages> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    socket = IO.io(
        'http://192.168.100.155:9010',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .enableAutoConnect()
            .build());
    setupListeners();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    initializeData();
  }

  void setupListeners() {
    socket!.onConnect((_) => print('Connected'));
    socket!.onDisconnect((_) => print('Disconnected'));

    socket!.on('fire', (data) {
      print('Received: $data');
    });
    socket!.on('send_person_chat', (data) {
      print('Received: $data');
      setState(() {
        print("data: $data");
      });
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      // Fetch messages from your data source (e.g., API or local database)
      final newMessages = await getPersonChats(pageKey);
      // Check if this is the last page
      final isLastPage = newMessages.length < pageSize;

      if (isLastPage) {
        _pagingController.appendLastPage(newMessages);
      } else {
        int nextPageKey = pageKey + 1;
        _pagingController.appendPage(newMessages, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  initializeData() async {
    await loadDB();
  }

  Future loadDB() async {
    if (boxChatsDetails.get(widget.id) != null) {
      db.loadMessages(widget.id);
    }
  }

  getPersonChats(pageIndex) async {
    bool isAvailable =
        await utils.isNetworkAvailable(context, utils, showDialog: false);
    if (!isAvailable && pageIndex == 0 && db.messages[widget.id]!.isNotEmpty) {
      return db.messages[widget.id];
    }
    var formData = FormData.fromMap(
        {"id": widget.id, "page": pageIndex + 1, "is_group": widget.isGroup});
    var response = await APIFunction.post(
        context, utils, ApiClient.apiGetPersionChats, formData, '');
    var value = response.data["message"];

    messages = [];
    if (pageIndex == 0) {
      db.messages[widget.id] = [];
    }
    value.forEach((i) {
      messages.add(Messages.fromJson(i));
      if (pageIndex == 0) {
        db.messages[widget.id]!.add(Messages.fromJson(i));
      }
    });

    db.updateMessages(widget.id);

    return messages;
  }

  void _sendMessage(message) async {
    String userMessage = message;
    var newMessage = {
      "conversation": "",
      "conversation_name": "",
      "whatsapp_group": "",
      "group_name": "",
      "message_author": '',
      "user": "",
      "media_url": "",
      "sender": "User",
      "recipient": widget.id,
      "recipient_name": widget.name,
      "message_content": userMessage,
      "timestamp": DateTime.now().toString(),
    };
    setState(() {
      db.addMessage(widget.id, newMessage);
    });
    _pagingController.itemList?.insert(0, Messages.fromJson(newMessage));
    socket?.emit('ping');
    socket!.emit('send_person_chat', newMessage);
    // _messagesLoadController!.appendItems([Messages.fromJson(newMessage)]);
    // _messagesLoadController!.retry();
    bool isAvailable =
        await utils.isNetworkAvailable(context, utils, showDialog: false);
    if (isAvailable) {
      var formData = {
        "data": {
          // Wrap the payload in "data" key
          "to": widget.id,
          "body": userMessage
        }
      };
      var response = await APIFunction.postJson(
          context, utils, ApiClient.apiSentMessage, formData, '');
      // var value = response["message"];
      print("value: $response");
    }
  }

  @override
  void dispose() {
    socket?.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PagedListView<int, Messages>(
              pagingController: _pagingController,
              reverse: true, // For chat apps, reverse the list
              builderDelegate: PagedChildBuilderDelegate<Messages>(
                itemBuilder: (context, message, index) {
                  return messageCard(_pagingController.itemList ?? [], message,
                      widget.isGroup, index);
                },
                noItemsFoundIndicatorBuilder: (context) {
                  return Center(child: Text("No messages found"));
                },
                firstPageProgressIndicatorBuilder: (context) {
                  return Center(child: CircularProgressIndicator());
                },
                newPageProgressIndicatorBuilder: (context) {
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
          CustomMessageBar(
            onSend: _sendMessage,
            onShowOptions: () {},
          ),
        ],
      ),
    );
  }
}

Widget messageCard(
    List<Messages> messages, Messages message, bool isGroup, int index) {
  return Align(
    alignment: message.sender.toString() == "User"
        ? Alignment.centerRight
        : Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: message.recipientName.toString() != "" ? 5.0 : 2.0,
            horizontal: 10.0),
        padding: EdgeInsets.only(
          top: isGroup ? 4.0 : 10.0,
          bottom: 10.0,
          left: 10.0,
          right: 10.0,
        ),
        decoration: BoxDecoration(
          color: message.sender.toString() == "User"
              ? Colors.teal[100]
              : Colors.grey[300],
          borderRadius: BorderRadius.only(
            bottomLeft: const Radius.circular(10.0),
            bottomRight: const Radius.circular(10.0),
            topLeft: message.sender.toString() == "User"
                ? const Radius.circular(10.0)
                : message.recipientName.toString() != ""
                    ? const Radius.circular(0.0)
                    : const Radius.circular(10.0),
            topRight: message.sender.toString() == "User"
                ? message.recipientName.toString() != ""
                    ? const Radius.circular(0.0)
                    : const Radius.circular(10.0)
                : const Radius.circular(10.0),
          ),
        ),
        constraints: const BoxConstraints(
          maxWidth: 300,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.recipientName.toString() != "" && isGroup)
              Text(
                message.recipientName.toString(),
                style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
            TimestampedChatMessage(
              text: message.messageContent.toString(),
              sentAt: DateFormat('HH:mm')
                  .format(DateTime.parse(message.timestamp.toString())),
              maxLines: 6,
              showMoreTextStyle: const TextStyle(color: Colors.teal),
              style: TextStyle(
                color: message.sender.toString() == "User"
                    ? Colors.black
                    : Colors.black,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
