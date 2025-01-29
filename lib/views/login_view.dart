import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sowaan_chat/models/user.dart';
import 'package:sowaan_chat/utils/dialog.dart';
import 'package:sowaan_chat/utils/shared_pref.dart';
import 'package:sowaan_chat/utils/utils.dart';

import '../networking/api_helpers.dart';
import '../networking/dio_client.dart';
import 'home_page_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final Utils _utils = Utils();
  final SharedPref pref = SharedPref();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool isRemember = false;

  @override
  void initState() {
    super.initState();
    checkRemember();
  }

  checkRemember() async {
    pref.readString(pref.prefBaseUrl).then((value) {
      if (value != "") {
        setState(() {
          isRemember = true;
          _urlController.text = value;
        });
      }
    });
    pref.readString(pref.prefUserName).then((value) {
      if (value != "") {
        setState(() {
          isRemember = true;
          _emailController.text = value;
        });
      }
    });
    pref.readString(pref.prefPassword).then((value) {
      if (value != "") {
        setState(() {
          isRemember = true;
          _passwordController.text = value;
        });
      }
    });
  }

  handleLogin() {
    // print(_emailController.text);
    // print(_passwordController.text);

    if (_utils.isValidationEmpty(_urlController.text)) {
      dialogAlert(context, _utils, "Please enter SowaanERP Url");
    } else if (_utils.isValidationEmpty(_emailController.text)) {
      dialogAlert(context, _utils, "Please enter username");
    } else if (_utils.isValidationEmpty(_passwordController.text)) {
      dialogAlert(context, _utils, "Please enter password");
    } else {
      _utils
          .isNetworkAvailable(context, _utils, showDialog: true)
          .then((value) {
        _utils.hideKeyboard(context);

        checkNetwork(value);
      });
    }
  }

  checkNetwork(bool value) async {
    if (value) {
      _utils.showProgressDialog(context);
      String token = await pref.readString(pref.prefKeyToken);
      await pref.saveString(pref.prefBaseUrl, _urlController.text);
      if (isRemember) {
        await pref.saveString(pref.prefUserName, _emailController.text);
        await pref.saveString(pref.prefPassword, _passwordController.text);
      } else {
        await pref.saveString(pref.prefUserName, "");
        await pref.saveString(pref.prefPassword, "");
      }

      var formData = FormData.fromMap({
        'usr': _emailController.text,
        'pwd': _passwordController.text,
      });
      Future<dynamic> user = APIFunction.post(
          context, _utils, ApiClient.apiLogin, formData, token);
      user.then((value) => responseApi(value));
    }
  }

  responseApi(value) {
    _utils.hideProgressDialog(context);

    if (value != null && value.statusCode == 200) {
      _utils.showToast(value.data["message"], context);
      getUserInfo(true);
    }
  }

  getUserInfo(bool value) async {
    if (value) {
      _utils.showProgressDialog(context);

      var user =
          await APIFunction.get(context, _utils, ApiClient.apiGetUserInfo, "");
      print('user: ${user["message"]["user"]}');
      responseApiUserInfo(user);
      // user.then((value) => );
    }
  }

  responseApiUserInfo(value) {
    _utils.hideProgressDialog(context);
    // print('${value && value.statusCode}, Base Url REsponse');
    // print('responseApiUserInfo: ${value.statusCode}');
    if (value != null) {
      User userModel = User.fromJson(value["message"]["user"]);
      SharedPref pref = SharedPref();
      pref.saveObject(pref.prefKeyUserData, userModel);

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (context) {
          return HomePage();
        },
      ), (route) => false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  // color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Login to continue using the app",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                controller: _urlController,
                hintText: "URL",
                isPassword: false,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _emailController,
                hintText: "Email",
                isPassword: false,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                hintText: "Password",
                isPassword: true,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Switch(
                      value: isRemember,
                      onChanged: (value) {
                        setState(() {
                          isRemember = value;
                        });
                      },
                      activeTrackColor: Colors.teal[800]!,
                      activeColor: Colors.white,
                    ),
                    Text(
                      "Remember me",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  handleLogin();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[800],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Login",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isPassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        // fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
      style: const TextStyle(color: Colors.black),
    );
  }
}
