import 'dart:async';

import 'package:ecommerce/models/user_model.dart';
import 'package:ecommerce/shared_preference.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';

import '../../../api/api_end_point.dart';
import '../../../api/api_util.dart';
import '../../../common/widgets/flutter_toast.dart';
import '../../../components/default_button.dart';
import '../../../services/authentication/authentification_service.dart';
import '../../../size_config.dart';

class ChangeDisplayNameForm extends StatefulWidget {
  const ChangeDisplayNameForm({
    Key? key,
  }) : super(key: key);

  @override
  _ChangeDisplayNameFormState createState() => _ChangeDisplayNameFormState();
}

class _ChangeDisplayNameFormState extends State<ChangeDisplayNameForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController newDisplayNameController =
      TextEditingController();

  final TextEditingController currentDisplayNameController =
      TextEditingController();

  @override
  void dispose() {
    newDisplayNameController.dispose();
    currentDisplayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: SizeConfig.screenHeight * 0.1),
          buildCurrentDisplayNameField(),
          SizedBox(height: SizeConfig.screenHeight * 0.05),
          buildNewDisplayNameField(),
          SizedBox(height: SizeConfig.screenHeight * 0.2),
          DefaultButton(
            text: "Change Display Name",
            press: () {
              final uploadFuture = changeDisplayNameButtonCallback();
              showDialog(
                context: context,
                builder: (context) {
                  return FutureProgressDialog(
                    uploadFuture,
                    message: Text("Updating Display Name"),
                  );
                },
              );
              uploadFuture.then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Display Name updated")),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to update Display Name")),
                );
              });
            },
          ),
        ],
      ),
    );

    return form;
  }

  Widget buildNewDisplayNameField() {
    return TextFormField(
      controller: newDisplayNameController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "Enter New Display Name",
        labelText: "New Display Name",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        if (newDisplayNameController.text.isEmpty) {
          return "Display Name cannot be empty";
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildCurrentDisplayNameField() {
    return FutureBuilder<String>(
      future: getCurrentUserModel(),
      builder: (context, snapshot) {
        String displayName = '';
        if (snapshot.hasData && snapshot.data != null)
          displayName = snapshot.data ?? '';
        final textField = TextFormField(
          controller: currentDisplayNameController,
          decoration: InputDecoration(
            hintText: "No Display Name available",
            labelText: "Current Display Name",
            floatingLabelBehavior: FloatingLabelBehavior.always,
            suffixIcon: Icon(Icons.person),
          ),
          readOnly: true,
        );
        if (displayName != '') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (currentDisplayNameController.text != displayName) {
              currentDisplayNameController.text = displayName;
            }
          });
        }
        return textField;
      },
    );
  }

  Future<void> changeDisplayNameButtonCallback() async {
    if (!_formKey.currentState!.validate()) return;

    final newDisplayName = newDisplayNameController.text.trim();
    final completer = Completer<void>();

    ApiUtil.getInstance()!.post(
      url: ApiEndpoint.updateUser, // endpoint cập nhật user
      body: {"name": newDisplayName}, // truyền vào body
      onSuccess: (response) async {
        await SharedPreferenceUtil.saveUsername(newDisplayName);
        completer.complete();
      },
      onError: (error) {
        completer.completeError(error);
      },
    );

    return completer.future;
  }

  Future<String> getCurrentUserModel() async {
    return await SharedPreferenceUtil.getUsername();
  }
}
