import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSender;

  const ChatBubble({Key? key, required this.text, this.isSender = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: CustomPaint(
        painter: ChatBubblePainter(isSender: isSender),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class ChatBubblePainter extends CustomPainter {
  final bool isSender;
  ChatBubblePainter({required this.isSender});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = isSender ? Colors.blue : Colors.grey.shade700;

    final path = Path();
    if (isSender) {
      // Right-side bubble with pinned corner
      path.moveTo(size.width - 10, size.height);
      path.lineTo(size.width, size.height - 10);
      path.lineTo(size.width, 10);
      path.quadraticBezierTo(size.width, 0, size.width - 10, 0);
      path.lineTo(10, 0);
      path.quadraticBezierTo(0, 0, 0, 10);
      path.lineTo(0, size.height - 10);
      path.quadraticBezierTo(0, size.height, 10, size.height);
      path.close();
    } else {
      // Left-side bubble with pinned corner
      path.moveTo(10, size.height);
      path.lineTo(0, size.height - 10);
      path.lineTo(0, 10);
      path.quadraticBezierTo(0, 0, 10, 0);
      path.lineTo(size.width - 10, 0);
      path.quadraticBezierTo(size.width, 0, size.width, 10);
      path.lineTo(size.width, size.height - 10);
      path.quadraticBezierTo(size.width, size.height, size.width - 10, size.height);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
