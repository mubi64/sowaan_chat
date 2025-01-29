import 'package:flutter/material.dart';
import 'package:sowaan_chat/box.dart';
import 'package:sowaan_chat/models/chats.dart';
import 'package:sowaan_chat/views/chats_view.dart';
import 'package:sowaan_chat/views/splash_view.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/messages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeHive(); // Initialize Hive and register adapters.
  await openHiveBoxes(); // Open Hive boxes.
  runApp(const MyApp());
}

Future<void> initializeHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ChatsAdapter());
  Hive.registerAdapter(MessagesAdapter());
}

Future<void> openHiveBoxes() async {
  boxChats = await Hive.openBox('CHATS');
  boxChatsDetails = await Hive.openBox('CHATSDETAILS');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sowaan Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: SplashView(),
    );
  }
}


class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> statuses = [
      {'name': 'Alice', 'status': 'Today, 12:00 PM'},
      {'name': 'Bob', 'status': 'Yesterday, 5:00 PM'},
      {'name': 'Charlie', 'status': 'Today, 9:00 AM'},
    ];

    return ListView.builder(
      itemCount: statuses.length,
      itemBuilder: (context, index) {
        final status = statuses[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(status['name']![0]),
          ),
          title: Text(status['name']!),
          subtitle: Text(status['status']!),
        );
      },
    );
  }
}

class CallsPage extends StatelessWidget {
  const CallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> calls = [
      {'name': 'Alice', 'time': 'Today, 12:00 PM'},
      {'name': 'Bob', 'time': 'Yesterday, 5:00 PM'},
      {'name': 'Charlie', 'time': 'Today, 9:00 AM'},
    ];

    return ListView.builder(
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = calls[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(call['name']![0]),
          ),
          title: Text(call['name']!),
          subtitle: Text(call['time']!),
          trailing: Icon(Icons.call, color: Colors.teal),
        );
      },
    );
  }
}
