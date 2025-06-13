import 'dart:async';

import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';

import '../../../api/api_end_point.dart';
import '../../../api/api_util.dart';
import '../../../common/widgets/flutter_toast.dart';
import '../../../components/custom_suffix_icon.dart';
import '../../../components/default_button.dart';
import '../../../constants.dart';
import '../../../size_config.dart';

class ChangePasswordForm extends StatefulWidget {
  @override
  _ChangePasswordFormState createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
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
            buildCurrentPasswordFormField(),
            SizedBox(height: getProportionateScreenHeight(30)),
            buildNewPasswordFormField(),
            SizedBox(height: getProportionateScreenHeight(30)),
            buildConfirmNewPasswordFormField(),
            SizedBox(height: getProportionateScreenHeight(40)),
            DefaultButton(
              text: "Change Password",
              press: () {
                final updateFuture = changePasswordButtonCallback();
                showDialog(
                  context: context,
                  builder: (context) {
                    return FutureProgressDialog(
                      updateFuture,
                      message: Text("Updating Password"),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildConfirmNewPasswordFormField() {
    return TextFormField(
      controller: confirmNewPasswordController,
      obscureText: true,
      decoration: InputDecoration(
        hintText: "Confirm New Password",
        labelText: "Confirm New Password",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(
          svgIcon: "assets/icons/Lock.svg",
        ),
      ),
      validator: (value) {
        if (confirmNewPasswordController.text != newPasswordController.text) {
          return "Not matching with Password";
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildCurrentPasswordFormField() {
    return TextFormField(
      controller: currentPasswordController,
      obscureText: true,
      decoration: InputDecoration(
        hintText: "Enter Current Password",
        labelText: "Current Password",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(
          svgIcon: "assets/icons/Lock.svg",
        ),
      ),
      validator: (value) {
        return null;
      },
      autovalidateMode: AutovalidateMode.disabled,
    );
  }

  Widget buildNewPasswordFormField() {
    return TextFormField(
      controller: newPasswordController,
      obscureText: true,
      decoration: InputDecoration(
        hintText: "Enter New password",
        labelText: "New Password",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(
          svgIcon: "assets/icons/Lock.svg",
        ),
      ),
      validator: (value) {
        if (newPasswordController.text.isEmpty) {
          return "Password cannot be empty";
        } else if (newPasswordController.text.length < 6) {
          return "Password too short";
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Future<void> changePasswordButtonCallback() async {
    if (!_formKey.currentState!.validate()) return;

    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final completer = Completer<void>();

    ApiUtil.getInstance()!.post(
      url: ApiEndpoint.updateUserPassword, // Endpoint cập nhật user
      body: {
        "current_password": currentPassword, // Truyền mật khẩu hiện tại
        "new_password": newPassword, // Truyền mật khẩu mới
      },
      onSuccess: (response) async {
        final data = response.data;
        if (data['data']['success'] == true) {
          toastInfo(msg: "Password changed successfully");
          completer.complete();
        } else {
          toastInfo(msg: data['message'] ?? "Failed to change password");
          completer.complete();
        }
      },
      onError: (error) {
        toastInfo(msg: error.toString());
        completer.complete(error);
      },
    );

    return completer.future;
  }
}
