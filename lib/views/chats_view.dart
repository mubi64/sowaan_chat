import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:intl/intl.dart';
import 'package:sowaan_chat/box.dart';
import 'package:sowaan_chat/models/chats.dart';
import 'package:sowaan_chat/utils/constants.dart';
import 'package:sowaan_chat/utils/shared_pref.dart';
import 'package:sowaan_chat/views/chat_detail_view.dart';
import 'package:sowaan_chat/widgets/list_view.dart';

import '../data/database.dart';
import '../widgets/image_view.dart';

class ChatsView extends StatefulWidget {
  PagewiseLoadController<Chats>? chatsLoadController;
  List<Chats> chats;
  List<Chats> dbChats;
  String baseURL;
  ChatsView(
      {super.key,
      required this.chatsLoadController,
      required this.chats,
      required this.dbChats,
      required this.baseURL});

  @override
  State<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView> {
  final SharedPref prefs = SharedPref();
  DataBase db = DataBase();

  @override
  void initState() {
    super.initState();
    loadDB();
  }

  Future loadDB() async {
    if (boxChats.get("CHATS") != null) {
      db.loadChats();
    }
  }

  FutureOr onGoBack(dynamic value) async {
    await loadDB();
    widget.chats = db.chats;
    widget.chatsLoadController!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ScrollablePagewiseListView(
            onRefresh: () async {
              widget.chats = db.chats;
              widget.chatsLoadController!.reset();
            },
            pageLoadController: widget.chatsLoadController,
            itemBuilder: (entry) {
              var e = entry as Chats;
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailView(
                        id: e.id.toString(),
                        name: e.idName.toString(),
                        isGroup: e.isGroup!,
                      ),
                    ),
                  ).then(onGoBack);
                },
                child: widgetListTile(e, widget.baseURL),
              );
            },
            loadingViewWidget: ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: db.chats.length,
                itemBuilder: ((context, index) {

                  var e = widget.dbChats[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailView(
                            id: e.id.toString(),
                            name: e.idName.toString(),
                            isGroup: e.isGroup!,
                          ),
                        ),
                      ).then(onGoBack);
                    },
                    child: widgetListTile(e, widget.baseURL),
                  );
                })),
          ),
        ),
      ],
    );
  }
}

Widget widgetListTile(e, baseURL) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.teal,
          child: Hero(
            tag: 'imageHero${e.id}',
            child: widgetCommonProfile(
              imagePath: e.profilePhoto.toString(),
              userName: e.idName.toString(),
              baseURL: baseURL,
              isBackGroundColorGray: false,
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 240,
                    child: Text(
                      e.idName.toString(),
                      overflow: TextOverflow
                          .ellipsis, // Prevent overflow with ellipsis
                      maxLines: 1, // Limit to a single line
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xDD242424),
                      ),
                    ),
                  ),
                  Text(
                    e.timestamp != ""
                        ? DateFormat(Constants.dateFormathhmmA)
                            .format(DateTime.parse(e.timestamp.toString()))
                        : "",
                    style: TextStyle(fontSize: 12, color: Colors.teal),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                e.lastMessage.toString(),
                overflow:
                    TextOverflow.ellipsis, // Prevent overflow with ellipsis
                maxLines: 1, // Limit to a single line
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
              ),
              SizedBox(height: 4),
            ],
          ),
        ),
      ],
    ),
  );
}
