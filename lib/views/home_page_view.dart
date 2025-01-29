import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:sowaan_chat/views/login_view.dart';

import '../box.dart';
import '../data/database.dart';
import '../main.dart';
import '../models/chats.dart';
import '../networking/api_helpers.dart';
import '../networking/dio_client.dart';
import '../utils/dialog.dart';
import '../utils/shared_pref.dart';
import '../utils/strings.dart';
import '../utils/utils.dart';
import 'chat_detail_view.dart';
import 'chats_view.dart';
import 'contact_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final Utils utils = Utils();
  final SharedPref prefs = SharedPref();
  DataBase db = DataBase();
  String baseURL = '';
  PagewiseLoadController<Chats>? _chatsLoadController;
  List<Chats> chats = [];
  List<Chats> filteredChats = []; // List to hold filtered chats
  int pageSize = 50;
  final TextEditingController _searchController =
      TextEditingController(); // Controller for search bar

  @override
  void initState() {
    super.initState();
    _chatsLoadController = PagewiseLoadController<Chats>(
      pageSize: pageSize,
      pageFuture: (pageIndex) async {
        return [];
      },
    );
    initializeData();
  }

  initializeData() async {
    // Read base url from prefs
    prefs.readString(prefs.prefBaseUrl).then((value) {
      setState(() {
        baseURL = value;
      });
    });
    await loadDB();
    setState(() {
      _chatsLoadController = PagewiseLoadController<Chats>(
        pageSize: pageSize,
        pageFuture: (pageIndex) async {
          List<Chats> loadedChats = await getChatList(pageIndex) ?? [];
          return loadedChats;
        },
      );
      filteredChats = chats ?? []; // Initialize filteredChats with all chats
    });
  }

  Future loadDB() async {
    if (boxChats.get("CHATS") != null) {
      db.loadChats();
    }
  }

  getChatList(pageIndex) async {
    bool available =
        await utils.isNetworkAvailable(context, utils, showDialog: false);
    utils.hideKeyboard(context);

    // Return cached chats if offline and fetching the first page
    if (!available && db.chats.isNotEmpty && pageIndex == 0) {
      return db.chats;
    }

    try {
      var formData = FormData.fromMap({"page": pageIndex + 1});
      var response = await APIFunction.post(
          context, utils, ApiClient.apiGetChats, formData, '');

      if (response.data == null || response.data["message"] == null) {
        throw Exception("Invalid API response: Missing 'message' field.");
      }
      var value = response.data["message"];

      chats = [];
      if (pageIndex == 0) {
        db.chats = [];
      }
      value.forEach((i) {
        chats.add(Chats.fromJson(i));
        if (pageIndex == 0) {
          db.chats.add(Chats.fromJson(i));
        }
      });
      // Update the database
      db.updateChats();

      return chats;
    } catch (e) {
      utils.loggerPrint("Error in getChatList: $e");

      if (e is DioException) {
        if (e.response != null) {
          dialogAlert(
              context, utils, "API Error: ${e.response?.statusMessage}");
        } else {
          dialogAlert(context, utils, Strings.msgTryAgain);
        }
      }
      if (db.chats.isNotEmpty || pageIndex == 0) {
        setState(() {
          chats = db.chats;
        });
      }
      return chats;
    }
  }

  // Method to filter chats based on search query
  void _filterChats(String query) {
    setState(() {
      filteredChats = chats
          .where((chat) =>
              chat.idName!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _logout() {
    prefs.saveObject(prefs.prefKeyUserData, null);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
      builder: (context) {
        return LoginView();
      },
    ), (route) => false);
  }

  FutureOr onGoBack(dynamic value) async {
    await loadDB();
    chats = db.chats;
    _chatsLoadController!.reset();
  }

  @override
  void dispose() {
    _chatsLoadController!.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[800],
        title: const Text('Sowaan Chat',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ChatSearchDelegate(chats: chats),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              // Handle menu item selection
              if (value == 'logout') {
                AwesomeDialog(
                  context: context,
                  animType: AnimType.scale,
                  dialogType: DialogType.noHeader,
                  title: 'Logout',
                  desc: 'Are you sure to logout from the app?',
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {
                    _logout();
                  },
                ).show();
                //     dialogConfirm(context, utils, () {
                //                   _logout();
                // }, "Are you sure to logout from the app?");
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: ChatsView(
        chatsLoadController: _chatsLoadController,
        chats: filteredChats, // Pass filtered chats instead of all chats
        baseURL: baseURL,
        dbChats: db.chats,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactView(),
            ),
          ).then(onGoBack);
        },
        backgroundColor: Colors.teal[800],
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}

// Custom Search Delegate for Chat Search
class ChatSearchDelegate extends SearchDelegate<String> {
  final List<Chats> chats;

  ChatSearchDelegate({required this.chats});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = chats
        .where(
            (chat) => chat.idName!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final chat = results[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailView(
                  id: chat.id.toString(),
                  name: chat.idName.toString(),
                  isGroup: chat.isGroup!,
                ),
              ),
            );
          },
          child: widgetListTile(chat, ''),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = chats
        .where(
            (chat) => chat.idName!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final chat = suggestions[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailView(
                  id: chat.id.toString(),
                  name: chat.idName.toString(),
                  isGroup: chat.isGroup!,
                ),
              ),
            );
          },
          child: widgetListTile(chat, ''),
        );
      },
    );
  }
}
