import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sowaan_chat/utils/utils.dart';

import '../config/sowaan_palette.dart';
import '../utils/image_path.dart';

Widget widgetCommonProfile({
  String? imagePath,
  String baseURL = "",
  String userName = "",
  bool isFile = false,
  File? imageFile,
  bool isBackGroundColorGray = false,
  String type = "",
}) {
  Utils utils = Utils();
  if (imagePath == "") {
    return renderShape(size: 100.0, txt: utils.getInitials(userName));
  }
  return CachedNetworkImage(
    imageUrl: imagePath!.startsWith("https://")
        ? imagePath.toString()
        : imagePath != null
            ? '$baseURL$imagePath'
            : '',
    imageBuilder: (context, imageProvider) {
      return Container(
        decoration: BoxDecoration(
          color: isBackGroundColorGray ? Colors.white : Colors.grey,
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.contain,
          ),
        ),
      );
    },
    placeholder: (context, url) {
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isBackGroundColorGray ? Colors.white : Colors.grey,
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(ImagePath.icNoImage),
                fit: BoxFit.contain,
              ),
            ),
          ),
          CircularProgressIndicator(),
        ],
      );
    },
    errorWidget: (context, url, error) {
      return Container(
        decoration: isFile && imageFile != null
            ? BoxDecoration(
                color: isBackGroundColorGray ? Colors.white : Colors.grey,
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: FileImage(imageFile),
                  fit: BoxFit.contain,
                ),
              )
            : BoxDecoration(
                color: isBackGroundColorGray ? Colors.white : Colors.grey,
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(ImagePath.icNoImage),
                  fit: BoxFit.contain,
                ),
              ),
      );
    },
  );
}

Widget renderShape({
  String? txt,
  ImageProvider? imageProvider,
  double? size,
}) {
  var random = Random();
  var colorIdx = random.nextInt(SowaanPalette.colors.length);
  var backgroundColor = SowaanPalette.colors[colorIdx][100];
  var textColor = SowaanPalette.colors[colorIdx][600];

  return CircleAvatar(
    radius: size,
    backgroundColor: backgroundColor,
    child: txt != null
        ? Center(
            child: Text(
              txt,
              style: TextStyle(
                fontSize: 20,
                color: textColor,
              ),
            ),
          )
        : null,
  );
}
