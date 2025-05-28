import 'package:ecommerce/pages/home/home_page.dart';
import 'package:ecommerce/pages/sign_in/sign_in.dart';
import 'package:ecommerce/shared_preference.dart';
import 'package:flutter/material.dart';

import '../size_config.dart';

class AuthentificationWrapper extends StatelessWidget {
  static const String routeName = "/authentification_wrapper";
  Future<bool> _checkLoggedIn() async {
    final token = await SharedPreferenceUtil.getToken();
    return token != "";
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig()
        .init(context); // Đảm bảo gọi init() trước khi sử dụng SizeConfig
    return FutureBuilder<bool>(
      future: _checkLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data == true) {
          return Home(); // người dùng đã đăng nhập
        } else {
          return SignInScreen(); // chưa đăng nhập
        }
      },
    );
  }
}
