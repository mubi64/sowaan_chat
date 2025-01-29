// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class NoData extends StatelessWidget {
  String? message;
  IconData? icon;
  double? iconSize;
  NoData({this.message, this.icon, this.iconSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: Colors.grey[400],
            size: iconSize ?? 24,
          ),
          Text(
            message ?? "No data to show",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
