import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:flutter/material.dart';

class CustomMessageBar extends StatelessWidget {
  final Function(String) onSend;
  final VoidCallback onShowOptions;
  const CustomMessageBar(
      {super.key, required this.onSend, required this.onShowOptions});

  @override
  Widget build(BuildContext context) {
    return MessageBar(
      messageBarHintStyle: TextStyle(
        color: Colors.grey,
        fontSize: 16,
      ),
      textFieldTextStyle: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
      ),
      messageBarColor: Colors.transparent,
      onSend: (message) async {
        await onSend(message);
      },
      sendButtonColor: Colors.teal,
    );
  }
}
