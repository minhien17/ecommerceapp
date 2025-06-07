import 'dart:async';

import 'package:ecommerce/api/api_end_point.dart';
import 'package:ecommerce/api/api_util.dart';
import 'package:ecommerce/common/loading.dart';
import 'package:ecommerce/components/custom_suffix_icon.dart';
import 'package:ecommerce/components/default_button.dart';
import 'package:ecommerce/models/user_model.dart';
import 'package:ecommerce/shared_preference.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/flutter_toast.dart';
import '../../../constants.dart';
import '../../../size_config.dart';
import '../../home/home_page.dart';

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formkey = GlobalKey<FormState>();

  final TextEditingController emailFieldController = TextEditingController();
  final TextEditingController passwordFieldController = TextEditingController();

  @override
  void dispose() {
    emailFieldController.dispose();
    passwordFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Column(
        children: [
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildForgotPasswordWidget(context),
          SizedBox(height: getProportionateScreenHeight(30)),
          DefaultButton(
            text: "Sign in",
            press: signInButtonCallback,
          ),
        ],
      ),
    );
  }

  Row buildForgotPasswordWidget(BuildContext context) {
    return Row(
      children: [
        Spacer(),
        GestureDetector(
          // onTap: () {
          //   Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => ForgotPasswordScreen(),
          //       ));
          // },
          child: Text(
            "Forgot Password",
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
        )
      ],
    );
  }

  Widget buildPasswordFormField() {
    return TextFormField(
      controller: passwordFieldController,
      obscureText: true,
      decoration: InputDecoration(
        hintText: "Enter your password",
        labelText: "Password",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(
          svgIcon: "assets/icons/Lock.svg",
        ),
      ),
      validator: (value) {
        if (passwordFieldController.text.isEmpty) {
          return kPassNullError;
        } else if (passwordFieldController.text.length < 6) {
          return kShortPassError;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildEmailFormField() {
    return TextFormField(
      controller: emailFieldController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: "Enter your email",
        labelText: "Email",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(
          svgIcon: "assets/icons/Mail.svg",
        ),
      ),
      validator: (value) {
        if (emailFieldController.text.isEmpty) {
          return kEmailNullError;
        } else if (!emailValidatorRegExp.hasMatch(emailFieldController.text)) {
          return kInvalidEmailError;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Future<void> signInButtonCallback() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();

      AppLoading.show(context);

      var body = {
        "email": emailFieldController.text.trim(),
        "password": passwordFieldController.text.trim()
      };

      var res = ApiUtil.getInstance()!.post(
        url: ApiEndpoint.login,
        body: body,
        onSuccess: (response) {
          UserModel user = UserModel.fromJson(response.data['data']);
          // print(user);

          SharedPreferenceUtil.saveToken(user.userId);
          SharedPreferenceUtil.saveEmail(user.email);
          SharedPreferenceUtil.saveUsername(user.username);
          SharedPreferenceUtil.saveImage(user.displayPicture);
          AppLoading.hide(context);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Home()),
            (Route<dynamic> route) => false,
          );
          // Navigator.of(context).pop();
        },
        onError: (error) {
          AppLoading.hide(context);
          print(error);
          if (error is TimeoutException) {
            toastInfo(msg: "Time out");
          } else {
            toastInfo(msg: error.toString());
          }
        },
      );
    }
  }
}
