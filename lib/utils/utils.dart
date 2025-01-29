import 'dart:async';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sowaan_chat/responsive/responsive_flutter.dart';
import 'package:sowaan_chat/utils/dialog.dart';
import 'package:sowaan_chat/utils/strings.dart';

import 'constants.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class Utils {
  void darkStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          Platform.isAndroid ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.grey,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  void lightStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness:
          Platform.isAndroid ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.grey,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  static void screenPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void showProgressDialog(BuildContext buildContext) {
    showDialog(
      context: buildContext,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Center(
            child: Container(
              width: ResponsiveFlutter.of(context).moderateScale(80),
              height: ResponsiveFlutter.of(context).moderateScale(80),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00695C),
                    offset: const Offset(0.0, 1.0),
                    blurRadius: 8.0,
                  )
                ],
                borderRadius: BorderRadius.circular(
                  ResponsiveFlutter.of(context).moderateScale(100),
                ),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: ResponsiveFlutter.of(context).verticalScale(20),
                  ),
                  CircularProgressIndicator(
                    color: const Color(0xFF00695C),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void hideProgressDialog(BuildContext buildContext) {
    Navigator.of(buildContext, rootNavigator: true).pop();
  }

  String getDeviceType() {
    if (Platform.isAndroid) {
      return Constants.deviceTypeAndroid;
    } else {
      return Constants.deviceTypeIos;
    }
  }

  bool emailValidator(String email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(p);

    if (regExp.hasMatch(email)) {
      return true;
    }

    return false;
  }

  bool phoneValidator(String contact) {
    String p =
        r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$';

    RegExp regExp = RegExp(p);

    if (regExp.hasMatch(contact)) {
      return true;
    }

    return false;
  }

  bool isValidationEmpty(String? val) {
    if (val == null) {
      return true;
    } else {
      val = val.trim();
      if (val.isEmpty ||
          val == "null" ||
          val == "" ||
          val.isEmpty ||
          val == "NULL") {
        return true;
      } else {
        return false;
      }
    }
  }

  bool isValidationEmptyWithZero(String? val) {
    if (val == null) {
      return true;
    } else {
      val = val.trim();
      if (val.isEmpty ||
          val == "null" ||
          val == "" ||
          val.isEmpty ||
          val == "NULL" ||
          val == "0" ||
          val == "00") {
        return true;
      } else {
        return false;
      }
    }
  }

  bool validateMobile(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    }
    return true;
  }

  Future<bool> isNetworkAvailable(
    BuildContext? context,
    Utils? utils, {
    bool? showDialog,
  }) async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    try {
      if (connectivityResult.contains(ConnectivityResult.mobile)) {
        return true;
      } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
        return true;
      } else {
        if (showDialog!) {
          // alertDialog('Your internet is not available, please try again later', contextDialog: context);
          dialogAlert(context!, utils!, Strings.extraInternetConnection);
        }
        return false;
      }
      // switch (result) {
      //   case ConnectivityResult.wifi:
      //     return true;
      //   case ConnectivityResult.mobile:
      //     return true;
      //   default:
      //     if (showDialog!) {
      //       // alertDialog('Your internet is not available, please try again later', contextDialog: context);
      //       dialogAlert(context!, utils, Strings.extraInternetConnection);
      //     }
      //     return false;
      // }
    } on PlatformException catch (e) {
      utils!.loggerPrint(e.toString());
      if (showDialog!) {
        // alertDialog('Your internet is not available, please try again later', contextDialog: context);
        dialogAlert(context!, utils, Strings.extraInternetConnection);
      }
      return false;
    }
  }

  static transformMilliSeconds(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String strTime = '';
    if (hoursStr == '00' || hoursStr == '0') {
      strTime = '$minutesStr:$secondsStr';
    } else {
      strTime = '$hoursStr:$minutesStr:$secondsStr';
    }
    return strTime;
  }

  void showToast(Object message, BuildContext context) {
    Fluttertoast.showToast(
      msg: message.toString(),
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[300],
      fontSize: ResponsiveFlutter.of(context).fontSize(1.7),
      textColor: Colors.white,
    );
  }

  String currentTime() {
    String month = DateFormat.M().format(DateTime.now().toUtc());
    String day = DateFormat.d().format(DateTime.now().toUtc());
    String time = DateFormat.Hm().format(DateTime.now().toUtc());
    String timeDate =
        '${DateFormat.y().format(DateTime.now().toUtc())}-${month.length == 1 ? '0$month' : month}-${day.length == 1 ? '0$day' : day} $time';
    return timeDate;
  }

  String currentDate(String outputFormat) {
    var now = DateTime.now().toUtc();
    var formatter = DateFormat(outputFormat);
    String formattedDate = formatter.format(now);

    return formattedDate;
  }

  List<String> fillSlots() {
    List<String> list = [];
    for (int i = 1; i <= 100; i++) {
      list.add("$i");
    }
    return list;
  }

  String changeDateFormat(
    String? date,
    String? formatInput,
    String? formatOutput,
  ) {
    if (date != null && date.isNotEmpty) {
      final format = DateFormat(formatInput);
      DateTime gettingDate = format.parse(date);
      final DateFormat formatter = DateFormat(formatOutput);
      final String formatted = formatter.format(gettingDate);
      return formatted;
    }
    return '';
  }

  String getDayOfMonthSuffix(int dayNum) {
    if (!(dayNum >= 1 && dayNum <= 31)) {
      throw Exception('Invalid day of month');
    }

    if (dayNum >= 11 && dayNum <= 13) {
      return 'th';
    }

    switch (dayNum % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat('dd-yyyy,MM HH:mm a');
    var date = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
    var diff = date.difference(now);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else {
      if (diff.inDays == 1) {
        time = '${diff.inDays}DAY AGO';
      } else {
        time = '${diff.inDays}DAYS AGO';
      }
    }

    return time;
  }

  String removeTag(String content) {
    content = content.replaceAll("<b>", "").replaceAll("</b>", "");
    return content;
  }

  void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void loggerPrint(Object? object) {
    if (object == null || isValidationEmpty(object.toString())) {
      debugPrint('>---> Empty Message');
    } else {
      debugPrint('>---> $object');
    }
  }

  String customDateTimeFormatDate(
    Utils? utils, {
    required String dateTime,
    required String inputDateFormat,
    required String outputDateFormat,
  }) {
    if (!utils!.isValidationEmpty(dateTime)) {
      var inputFormat = DateFormat(inputDateFormat);
      var inputDate = inputFormat.parse(dateTime);
      // var inputDate = inputFormat.parseUTC(dateTime);
      // var inputDate = inputFormat.parseUtc(dateTime);

      var outputFormat = DateFormat(outputDateFormat);
      return outputFormat.format(inputDate);
    } else {
      return dateTime;
    }
  }

  String customDateTimeFormatDuration(
    Utils? utils, {
    required String dateTime,
    required String inputDateFormat,
    required String outputDateFormat,
  }) {
    if (!utils!.isValidationEmpty(dateTime)) {
      dateTime = utils.customDateTimeFormatDate(
        utils,
        dateTime: dateTime,
        inputDateFormat: inputDateFormat,
        outputDateFormat: inputDateFormat,
      );

      String minute = utils.customDateTimeFormatDate(
        utils,
        dateTime: dateTime,
        inputDateFormat: inputDateFormat,
        outputDateFormat: Constants.dateFormatMM,
      );

      // if (minute.startsWith('0')) {
      //   minute = minute.replaceFirst('0', '');
      // }

      String second = utils.customDateTimeFormatDate(
        utils,
        dateTime: dateTime,
        inputDateFormat: inputDateFormat,
        outputDateFormat: Constants.dateFormatSS,
      );

      // if (second.startsWith('0')) {
      //   second = second.replaceFirst('0', '');
      // }
      String milliSec = utils.customDateTimeFormatDate(
        utils,
        dateTime: dateTime,
        inputDateFormat: inputDateFormat,
        outputDateFormat: Constants.dateFormatMS,
      );

      // if (milliSec.startsWith('0')) {
      //   milliSec = milliSec.replaceFirst('0', '');
      // }

      /*if (_utils.isValidationEmptyWithZero(milliSec)) {
        return '00:00:00';
      } else if (_utils.isValidationEmptyWithZero(second)) {
        return milliSec + Strings.hintAudioDurationMilliSecond;
      } else if (_utils.isValidationEmptyWithZero(minute)) {
        return second + Strings.hintAudioDurationSecond+ ' ' + milliSec + Strings.hintAudioDurationMilliSecond;
      } else {
        return minute + Strings.hintAudioDurationMinute + ' ' + second + Strings.hintAudioDurationSecond+ ' ' + milliSec + Strings.hintAudioDurationMilliSecond;
      }*/
      // return minute + Strings.hintAudioDurationMinute + ' ' + second + Strings.hintAudioDurationSecond + ' ' + milliSec + Strings.hintAudioDurationMilliSecond;
      return '$minute${Strings.hintAudioDurationMinute} $second${Strings.hintAudioDurationSecond} $milliSec${Strings.hintAudioDurationMilliSecond}';
    } else {
      return dateTime;
    }
  }

  String convertToAgo({
    required Utils? utils,
    required String? dateTime,
  }) {
    var dateFormat =
        DateFormat("dd-MM-yyyy hh:mm aa"); // you can change the format here
    var utcDate =
        dateFormat.format(DateTime.parse(dateTime!)); // pass the UTC time here
    var localDate = dateFormat.parse(utcDate, true).toLocal().toString();

    DateTime input = DateTime.parse(localDate);

    Duration diff = DateTime.now().difference(input);

    if (diff.inDays >= 1) {
      if (diff.inDays > 1) {
        // return utils!.customDateTimeFormatDate(
        //   utils,
        //   dateTime: DateTime.parse('').toLocal().toString(),
        //   inputDateFormat: Constants.dateFormatYYYYMMDDTHHMMSSSSSZ,
        //   outputDateFormat: Constants.dateFormatDDMMMYYYYSlashHHMMSSCommaAA,
        // );

        var strToDateTime = DateTime.parse(dateTime);
        final convertLocal = strToDateTime.toLocal();
        var newFormat = DateFormat(Constants.dateFormatMMMDD);
        return newFormat.format(convertLocal);
      } else {
        // return '${diff.inDays} day(s) ago';
        return Strings.lblAgoDays(diff.inDays);
      }
    } else if (diff.inHours >= 1) {
      // return '${diff.inHours} hour(s) ago';
      return Strings.lblAgoHours(diff.inHours);
    } else if (diff.inMinutes >= 1) {
      // return '${diff.inMinutes} minute(s) ago';
      return Strings.lblAgoMinutes(diff.inMinutes);
    } else if (diff.inSeconds >= 1) {
      // return '${diff.inSeconds} second(s) ago';
      return Strings.lblAgoSeconds(diff.inSeconds);
    } else {
      // return 'Just now';
      return Strings.lblJustNow;
    }
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    // return (to.difference(from).inHours / 24).round();
    return to.difference(from).inDays;
  }

  String getMilliSecToTime({
    required int? milliseconds,
    required String? outputDateFormat,
    required Utils? utils,
  }) {
    var date = DateTime.fromMillisecondsSinceEpoch(milliseconds!, isUtc: true);
    var txt = DateFormat(outputDateFormat, 'en_GB').format(date);
    utils!.loggerPrint('test_max_duration_3: $txt');

    if (txt.length > 8) {
      return txt.substring(0, 8);
    } else {
      return txt;
    }
  }

  String? getHttpsToHttp(String? url) {
    if (Platform.isAndroid) {
      return url!.replaceAll('https', 'http');
    } else {
      return url;
    }
  }

  String getInitials(String txt) {
    List<String> names = txt.split(" ");
    String initials = "";
    int numWords = 2;

    if (names.length < numWords) {
      numWords = names.length;
    }
    for (var i = 0; i < numWords; i++) {
      initials += names[i] != '' ? names[i][0].toUpperCase() : "";
    }
    return initials;
  }
}
