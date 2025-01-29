import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sowaan_chat/utils/utils.dart';

import '../utils/dialog.dart';
import '../utils/shared_pref.dart';
import '../utils/strings.dart';

class ApiClient {
  // static String baseUrl = 'http://192.168.208.128:8000';
  // static String baseUrl = 'http://192.168.0.107:8000/api/';

  // header key
  static String headerKeyKey = 'key';
  static String headerKeyToken = 'token';

  // api
  static String apiLogin = '/api/method/login';
  static String apiGetUserInfo =
      '/api/method/whatsapp_management.whatsapp_management.apis.api.get_user_info';
  static String apiGetChats =
      '/api/method/whatsapp_management.whatsapp_management.apis.mobile_api.sync_conversation_mobile';
  static String apiGetPersionChats =
      '/api/method/whatsapp_management.whatsapp_management.apis.mobile_api.get_person_chats';
  static String apiSentMessage =
      '/api/method/whatsapp_management.whatsapp_management.apis.mobile_api.sent_message';
  static String apiCreateContact =
      '/api/method/whatsapp_management.whatsapp_management.apis.mobile_api.create_conversation';

  static String? cookies;

  Future<Dio> apiClientInstance(context, baseURL) async {
    Utils utils = Utils();
    var cookieJar = await getCookiePath();

    BaseOptions options = BaseOptions(
      baseUrl: baseURL,
      connectTimeout: Duration(milliseconds: 60000),
      receiveTimeout: Duration(milliseconds: 60000),
    );
    // Locale myLocale = Localizations.localeOf(context);
    // String selectedLanguage = myLocale.languageCode;
    // _utils.loggerPrint("Language code: $selectedLanguage");

    Dio dio = Dio(options);

    // _utils.loggerPrint("Token : " + token);
    utils.loggerPrint("Token : " + baseURL);

    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    dio.interceptors.add(LogInterceptor(responseBody: true));
    dio.interceptors.add(CookieManager(cookieJar));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (RequestOptions option, RequestInterceptorHandler handler) async {
          // var header = {
          //   headerKeyKey: headerKeyValue,
          //   // 'lang': selectedLanguage,
          // };
          //
          // option.headers.addAll(header);
          // option.headers['Authorization'] =
          //     "Bearer " + token.replaceAll('"', '').toString();
          option.headers['withCredentials'] = true;
          utils.loggerPrint(option.headers);
          return handler.next(option);
        },
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          return handler.next(response);
        },
        onError: (DioError e, ErrorInterceptorHandler handler) {
          utils.hideProgressDialog(context);
          dialogAlert(context, utils, e.response!.data["message"].toString());
          // if(e.response != null)
          //   dialogAlert(context, _utils, e.response?.statusMessage.toString());
          // else
          //   dialogAlert(context, _utils, e.response.toString());
          if (e.response != null) {
            dialogAlert(context, utils, e.response.toString());
            utils.loggerPrint(e.response?.statusCode);
          } else {
            utils.loggerPrint(e.message);
            dialogAlert(context, utils, Strings.msgTryAgain);
          }

          // utils.loggerPrint(
          //     'Dio DEFAULT Error Message :---------------> ${e.message} ${e.response}');
          // if (e.type == DioErrorType.other) {
          //   utils
          //       .loggerPrint('<<<<<<<-------------other Error---------->>>>>>');
          // } else if (e.type == DioErrorType.connectTimeout) {
          //   utils.loggerPrint(
          //       '<<<<<<<-------------CONNECT_TIMEOUT---------->>>>>>');
          // } else if (e.type == DioErrorType.receiveTimeout) {
          //   utils.loggerPrint(
          //       '<<<<<<<-------------RECEIVE_TIMEOUT---------->>>>>>');
          // }

          // utils.alertDialog(Strings.msgTryAgain, contextDialog: context);
          // dialogAlert(context, _utils, Strings.msgTryAgain);

          return handler.next(e);
        },
      ),
    );
    return dio;
  }

  static Future initCookies() async {
    cookies = await getCookies();
  }

  static Future<PersistCookieJar> getCookiePath() async {
    Directory appDocDir = await getApplicationSupportDirectory();
    String appDocPath = appDocDir.path;
    return PersistCookieJar(
        ignoreExpires: true, storage: FileStorage(appDocPath));
  }

  static Future<String?> getCookies() async {
    var cookieJar = await getCookiePath();
    SharedPref prefs = SharedPref();
    String baseURL = await prefs.readString(prefs.prefBaseUrl);

    if (baseURL != "") {
      var cookies = await cookieJar.loadForRequest(Uri.parse(baseURL));

      var cookie = CookieManager.getCookies(cookies);

      return cookie;
    } else {
      return null;
    }
  }
}
