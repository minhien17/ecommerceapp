import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';

import '../../../api/api_end_point.dart';
import '../../../api/api_util.dart';
import '../../../components/default_button.dart';
import '../../../services/database/user_database_helper.dart';
import '../../../shared_preference.dart';
import '../../../size_config.dart';

class ChangePhoneNumberForm extends StatefulWidget {
  const ChangePhoneNumberForm({
    Key? key,
  }) : super(key: key);

  @override
  _ChangePhoneNumberFormState createState() => _ChangePhoneNumberFormState();
}

class _ChangePhoneNumberFormState extends State<ChangePhoneNumberForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController newPhoneNumberController =
      TextEditingController();
  final TextEditingController currentPhoneNumberController =
      TextEditingController();

  @override
  void dispose() {
    newPhoneNumberController.dispose();
    currentPhoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: SizeConfig.screenHeight * 0.1),
          buildCurrentPhoneNumberField(),
          SizedBox(height: SizeConfig.screenHeight * 0.05),
          buildNewPhoneNumberField(),
          SizedBox(height: SizeConfig.screenHeight * 0.2),
          DefaultButton(
            text: "Update Phone Number",
            press: () {
              final updateFuture = updatePhoneNumberButtonCallback();
              showDialog(
                context: context,
                builder: (context) {
                  return FutureProgressDialog(
                    updateFuture,
                    message: Text("Updating Phone Number"),
                  );
                },
              );
              updateFuture.then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Phone number updated")),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to update Phone number")),
                );
              });
            },
          ),
        ],
      ),
    );

    return form;
  }

  Future<void> updatePhoneNumberButtonCallback() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newPhoneNumber = newPhoneNumberController.text.trim();
      final completer = Completer<void>();

      ApiUtil.getInstance()!.post(
        url: ApiEndpoint.updateUser, // endpoint cập nhật user
        body: {"phone": newPhoneNumber}, // truyền vào body
        onSuccess: (response) async {
          await SharedPreferenceUtil.savePhone(
              newPhoneNumber); // Lưu phone mới vào SharedPreferences
          completer.complete();
        },
        onError: (error) {
          completer.completeError(error);
        },
      );

      return completer.future;
    }
  }

  Widget buildNewPhoneNumberField() {
    return TextFormField(
      controller: newPhoneNumberController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: "Enter New Phone Number",
        labelText: "New Phone Number",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: Icon(Icons.phone),
      ),
      validator: (value) {
        if (newPhoneNumberController.text.isEmpty) {
          return "Phone Number cannot be empty";
        } else if (newPhoneNumberController.text.length != 10) {
          return "Only 10 digits allowed";
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildCurrentPhoneNumberField() {
    return FutureBuilder<String>(
      future: SharedPreferenceUtil.getPhone(), // Lấy phone từ SharedPreferences
      builder: (context, snapshot) {
        String currentPhone = '';
        if (snapshot.hasError) {
          final error = snapshot.error;
          Logger().w(error.toString());
        }
        if (snapshot.hasData && snapshot.data != null) {
          currentPhone = snapshot.data!;
        }
        final textField = TextFormField(
          controller: currentPhoneNumberController,
          decoration: InputDecoration(
            hintText: "No Phone Number available",
            labelText: "Current Phone Number",
            floatingLabelBehavior: FloatingLabelBehavior.always,
            suffixIcon: Icon(Icons.phone),
          ),
          readOnly: true,
        );
        if (currentPhone != "") {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            currentPhoneNumberController.text = currentPhone;
          });
        }
        return textField;
      },
    );
  }
}
