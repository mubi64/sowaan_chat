import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sowaan_chat/utils/shared_pref.dart';
import 'package:sowaan_chat/utils/utils.dart';

import 'dio_client.dart';

class APIFunction {
  static Future<dynamic> get(
      BuildContext context, Utils? utils, String url, String? token) async {
    try {
      SharedPref prefs = SharedPref();
      String baseURL = await prefs.readString(prefs.prefBaseUrl);
      var clientInstance =
          await ApiClient().apiClientInstance(context, baseURL);
      Response response = await clientInstance.get(url);
      return response.data;
    } catch (e) {
      utils!.loggerPrint(e);
      throw e;
    }
  }

  static Future<dynamic> post(BuildContext context, Utils? utils, String url,
      FormData formData, String? token) async {
    SharedPref prefs = SharedPref();
    try {
      String baseURL = await prefs.readString(prefs.prefBaseUrl);
      utils!.loggerPrint(formData);
      var clientInstance =
          await ApiClient().apiClientInstance(context, baseURL);
      Response response = await clientInstance.post(url, data: formData);
      return response;
    } on DioException catch (e) {
      // Handle Dio-specific errors
      utils!.loggerPrint("Dio error occurred: $e");

      // Check the type of Dio error
      if (e.type == DioExceptionType.connectionTimeout) {
        utils.loggerPrint("Connection timeout");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        utils.loggerPrint("Receive timeout");
      } else if (e.type == DioExceptionType.sendTimeout) {
        utils.loggerPrint("Send timeout");
      } else if (e.type == DioExceptionType.badResponse) {
        utils.loggerPrint(
            "Bad response: ${e.response?.statusCode} - ${e.response?.statusMessage}");
      } else if (e.type == DioExceptionType.cancel) {
        utils.loggerPrint("Request cancelled");
      } else if (e.type == DioExceptionType.unknown) {
        prefs.saveObject(prefs.prefKeyUserData, null);
        utils.loggerPrint("Unknown error: ${e.error}");
      } else if (e.error is SocketException) {
        utils.loggerPrint("Network issue: ${e.error}");
      } else if (e.message != null && e.message!.contains("No route to host")) {
        utils.loggerPrint(
            "No route to host: The server might be down or unreachable.");
      }
      utils
          .loggerPrint("Failed to load chats: ${e.message ?? "Unknown error"}");

      // Return an empty list to indicate failure
      return null;
    } catch (e) {
      utils!.loggerPrint('error post print: $e');
      if (e is DioException) {
        utils.loggerPrint(e.response!.data);
      } else {
        utils.loggerPrint(e);
      }
      return null;
    }
  }

  static Future<dynamic> postJson(BuildContext context, Utils? utils,
      String url, formData, String? token) async {
    try {
      SharedPref prefs = SharedPref();
      String baseURL = await prefs.readString(prefs.prefBaseUrl);
      utils!.loggerPrint(formData);
      var clientInstance =
          await ApiClient().apiClientInstance(context, baseURL);
      Response response = await clientInstance.post(url, data: formData);
      return response;
    } catch (e) {
      if (e is DioException) {
        utils!.loggerPrint(e.response!.data);
      } else {
        utils!.loggerPrint(e);
      }
      return null;
    }
  }

  static Future<dynamic> put(BuildContext context, Utils? utils, String url,
      FormData formData, String? token) async {
    try {
      SharedPref prefs = SharedPref();
      String baseURL = await prefs.readString(prefs.prefBaseUrl);
      utils!.loggerPrint(formData);
      var clientInstance =
          await ApiClient().apiClientInstance(context, baseURL);
      Response response = await clientInstance.put(url, data: formData);
      return response;
    } catch (e) {
      utils!.loggerPrint(e);
      return null;
    }
  }

  static Future<dynamic> delete(
      BuildContext context, Utils? utils, String url, String? token) async {
    try {
      SharedPref prefs = SharedPref();
      String baseURL = await prefs.readString(prefs.prefBaseUrl);
      var clientInstance =
          await ApiClient().apiClientInstance(context, baseURL);
      Response response = await clientInstance.delete(url);
      return response.data;
    } catch (e) {
      utils!.loggerPrint(e);
      return null;
    }
  }
}
