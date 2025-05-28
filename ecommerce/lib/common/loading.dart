import 'package:flutter/material.dart';

class AppLoading {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            height: 120,
            width: 120,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: Colors.blue,
              ),
            ),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
