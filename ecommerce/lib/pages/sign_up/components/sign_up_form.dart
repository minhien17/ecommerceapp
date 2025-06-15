import 'dart:async';

import 'package:ecommerce/components/custom_suffix_icon.dart';
import 'package:ecommerce/components/default_button.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/pages/sign_in/sign_in.dart';
import 'package:ecommerce/pages/sign_up/sign_up_page.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';

import '../../../api/api_end_point.dart';
import '../../../api/api_util.dart';
import '../../../common/widgets/flutter_toast.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailFieldController = TextEditingController();
  final TextEditingController passwordFieldController = TextEditingController();
  final TextEditingController confirmPasswordFieldController =
      TextEditingController();

  @override
  void dispose() {
    emailFieldController.dispose();
    passwordFieldController.dispose();
    confirmPasswordFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(screenPadding)),
        child: Column(
          children: [
            buildEmailFormField(),
            SizedBox(height: getProportionateScreenHeight(30)),
            buildPasswordFormField(),
            SizedBox(height: getProportionateScreenHeight(30)),
            buildConfirmPasswordFormField(),
            SizedBox(height: getProportionateScreenHeight(40)),
            DefaultButton(
              text: "Sign up",
              press: signUpButtonCallback,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildConfirmPasswordFormField() {
    return TextFormField(
      controller: confirmPasswordFieldController,
      obscureText: true,
      decoration: InputDecoration(
        hintText: "Re-enter your password",
        labelText: "Confirm Password",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(
          svgIcon: "assets/icons/Lock.svg",
        ),
      ),
      validator: (value) {
        if (confirmPasswordFieldController.text.isEmpty) {
          return kPassNullError;
        } else if (confirmPasswordFieldController.text !=
            passwordFieldController.text) {
          return kMatchPassError;
        } else if (confirmPasswordFieldController.text.length < 6) {
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

  Future<void> signUpButtonCallback() async {
    if (!_formKey.currentState!.validate()) return;

    final completer = Completer<void>();
    final email = emailFieldController.text.trim();
    final password = passwordFieldController.text.trim();

    ApiUtil.getInstance()!.post(
      url: ApiEndpoint.signup, // Endpoint đăng ký
      body: {
        "email": email,
        "password": password,
      },
      onSuccess: (response) async {
        final data = response.data;
        if (data['data']['is_success'] == true) {
          toastInfo(msg: "Sign up successful!");

          // Điều hướng đến màn hình Login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignInScreen()),
          );
        } else {
          toastInfo(msg: data['message'] ?? "Sign up failed!");
          completer.completeError("Sign up failed!");
        }
      },
      onError: (error) {
        toastInfo(msg: error.toString());
        completer.completeError(error);
      },
    );

    return completer.future;
  }
}
