import 'package:flutter/material.dart';

import '../constants.dart';
import '../size_config.dart';

class RoundedIconButton extends StatelessWidget {
  final IconData iconData;
  final GestureTapCallback press;
  const RoundedIconButton({
    Key? key,
    required this.iconData,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getProportionateScreenWidth(40),
      width: getProportionateScreenWidth(40),
      child: TextButton(
        onPressed: press,
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
              EdgeInsets.zero), // Zero padding
          backgroundColor: MaterialStateProperty.all<Color>(
              Colors.white), // Background color
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50), // Circular shape
            ),
          ),
        ),
        child: Icon(
          iconData,
          color: kTextColor, // Icon color
        ),
      ),
    );
  }
}
