import 'package:ecommerce/pages/home/home_page.dart';
import 'package:ecommerce/pages/sign_in/sign_in.dart';
import 'package:ecommerce/services/authentication/authentification_service.dart';
import 'package:flutter/material.dart';

class AuthentificationWrapper extends StatelessWidget {
  static const String routeName = "/authentification_wrapper";
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthentificationService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Home();
        } else {
          return SignInScreen();
        }
      },
    );
  }
}
