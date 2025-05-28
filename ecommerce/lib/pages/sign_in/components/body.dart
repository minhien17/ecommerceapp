import 'package:ecommerce/components/no_account_text.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/pages/sign_in/components/sign_in_form.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10)),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Text(
                  "Welcome to Ecommerce App",
                  style: headingStyle,
                ),
                SizedBox(
                  height: getProportionateScreenHeight(20),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: SizedBox(
                        child: SvgPicture.asset('assets/icons/google.svg'),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: getProportionateScreenHeight(20),
                ),
                Text(
                  "Or sign in with your email and password",
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: getProportionateScreenHeight(40),
                ),
                SignInForm(),
                SizedBox(height: SizeConfig.screenHeight * 0.08),
                NoAccountText(),
                SizedBox(height: getProportionateScreenHeight(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
