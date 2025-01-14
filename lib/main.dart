import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sowaan Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[800],
        title: const Text('Sowaan Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'CHATS'),
            Tab(text: 'STATUS'),
            Tab(text: 'CALLS'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ChatsPage(),
          StatusPage(),
          CallsPage(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.teal[800],
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> chats = [
      {'name': 'Alice', 'message': 'Hello!'},
      {'name': 'Bob', 'message': 'How are you?'},
      {'name': 'Charlie', 'message': 'Let\'s meet up!'},
    ];

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(chat['name']![0], style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.teal,
          ),
          title: Text(chat['name']!),
          subtitle: Text(chat['message']!),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailPage(name: chat['name']!),
              ),
            );
          },
        );
      },
    );
  }
}

class ChatDetailPage extends StatelessWidget {
  final String name;

  const ChatDetailPage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> messages = [
      {'text': 'Hello!', 'isSent': true},
      {'text': 'Hi, how are you?', 'isSent': false},
      {'text': 'I am good, thanks!', 'isSent': true},
      {'text': 'Great to hear!', 'isSent': false},
    ];
    final TextEditingController _controller = TextEditingController();

    void _sendMessage() {
      if (_controller.text.isNotEmpty) {
        messages.add({'text': _controller.text, 'isSent': true});
        _controller.clear();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message['isSent'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: message['isSent'] ? Colors.teal[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(message['text']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
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
