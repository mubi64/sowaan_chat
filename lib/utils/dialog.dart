import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:sowaan_chat/utils/strings.dart';
import 'package:sowaan_chat/utils/utils.dart';

void dialogAlert(BuildContext context, Utils utils, String? msg,
    {String? title = ""}) {
  if (utils.isValidationEmpty(title!)) {
    title = Strings.appName;
  }

  AwesomeDialog(
    context: context,
    dialogType: DialogType.warning,
    animType: AnimType.rightSlide,
    title: title,
    desc: msg,
  ).show();
}
