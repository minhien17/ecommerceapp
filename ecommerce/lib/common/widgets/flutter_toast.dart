import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

toastInfo(
    {required String msg,
    Color bgColor = Colors.black,
    Color textColor = Colors.white}) {
  return Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      textColor: textColor,
      backgroundColor: bgColor,
      fontSize: 16);
}
