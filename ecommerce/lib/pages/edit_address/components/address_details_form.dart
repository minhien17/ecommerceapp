import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../../api/api_end_point.dart';
import '../../../api/api_util.dart';
import '../../../components/default_button.dart';
import '../../../constants.dart';
import '../../../models/address_model.dart';
import '../../../size_config.dart';

class AddressDetailsForm extends StatefulWidget {
  final AddressModel address;
  AddressDetailsForm({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  _AddressDetailsFormState createState() => _AddressDetailsFormState();
}

class _AddressDetailsFormState extends State<AddressDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleFieldController = TextEditingController();

  final TextEditingController receiverFieldController = TextEditingController();

  final TextEditingController addressLine1FieldController =
      TextEditingController();

  final TextEditingController addressLine2FieldController =
      TextEditingController();

  final TextEditingController cityFieldController = TextEditingController();

  final TextEditingController districtFieldController = TextEditingController();

  final TextEditingController stateFieldController = TextEditingController();

  final TextEditingController landmarkFieldController = TextEditingController();

  final TextEditingController pincodeFieldController = TextEditingController();

  final TextEditingController phoneFieldController = TextEditingController();

  @override
  void dispose() {
    titleFieldController.dispose();
    receiverFieldController.dispose();
    addressLine1FieldController.dispose();
    addressLine2FieldController.dispose();
    cityFieldController.dispose();
    stateFieldController.dispose();
    districtFieldController.dispose();
    landmarkFieldController.dispose();
    pincodeFieldController.dispose();
    phoneFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: getProportionateScreenHeight(20)),
          buildTitleField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildReceiverField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildAddressLine1Field(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildAddressLine2Field(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildCityField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildDistrictField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildStateField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          // buildLandmarkField(),
          // SizedBox(height: getProportionateScreenHeight(30)),
          buildPincodeField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPhoneField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          DefaultButton(
            text: "Save Address",
            press: widget.address.addressId == 0
                ? saveNewAddressButtonCallback
                : saveEditedAddressButtonCallback,
          ),
        ],
      ),
    );
    if (widget.address != null) {
      titleFieldController.text = widget.address.title;
      receiverFieldController.text = widget.address.receiver;
      addressLine1FieldController.text = widget.address.addressLine1;
      addressLine2FieldController.text = widget.address.addressLine2;
      cityFieldController.text = widget.address.city;
      districtFieldController.text = widget.address.district;
      stateFieldController.text = widget.address.state;
      pincodeFieldController.text = widget.address.pincode;
      phoneFieldController.text = widget.address.phone;
    }
    return form;
  }

  Widget buildTitleField() {
    return TextFormField(
      controller: titleFieldController,
      keyboardType: TextInputType.name,
      maxLength: 8,
      decoration: InputDecoration(
        hintText: "Enter a title for address",
        labelText: "Title",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (value) {
        if (titleFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildReceiverField() {
    return TextFormField(
      controller: receiverFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "Enter Full Name of Receiver",
        labelText: "Receiver Name",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (value) {
        if (receiverFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildAddressLine1Field() {
    return TextFormField(
      controller: addressLine1FieldController,
      keyboardType: TextInputType.streetAddress,
      decoration: InputDecoration(
        hintText: "Enter Address Line No. 1",
        labelText: "Address Line 1",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (value) {
        if (addressLine1FieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildAddressLine2Field() {
    return TextFormField(
      controller: addressLine2FieldController,
      keyboardType: TextInputType.streetAddress,
      decoration: InputDecoration(
        hintText: "Enter Address Line No. 2",
        labelText: "Address Line 2",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (value) {
        if (addressLine2FieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildCityField() {
    return TextFormField(
      controller: cityFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "Enter City",
        labelText: "City",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (value) {
        if (cityFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildDistrictField() {
    return TextFormField(
      controller: districtFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "Enter District",
        labelText: "District",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (value) {
        if (districtFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildStateField() {
    return TextFormField(
      controller: stateFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "Enter State",
        labelText: "State",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (value) {
        if (stateFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildPincodeField() {
    return TextFormField(
      controller: pincodeFieldController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: "Enter PINCODE",
        labelText: "PINCODE",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (value) {
        if (pincodeFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
          // } else if (!isNumeric(pincodeFieldController.text)) {
          //   return "Only digits field";
        } else if (pincodeFieldController.text.length != 6) {
          return "PINCODE must be of 6 Digits only";
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildLandmarkField() {
    return TextFormField(
      controller: landmarkFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "Enter Landmark",
        labelText: "Landmark",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (value) {
        if (landmarkFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildPhoneField() {
    return TextFormField(
      controller: phoneFieldController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: "Enter Phone Number",
        labelText: "Phone Number",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (value) {
        if (phoneFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        } else if (phoneFieldController.text.length != 10) {
          return "Only 10 Digits";
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Future<void> saveNewAddressButtonCallback() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final AddressModel newAddress = generateAddressObject();
      bool status = false;
      String snackbarMessage = '';
      try {
        status = await addAddress(newAddress);
        //     await UserDatabaseHelper().addAddressForCurrentUser(newAddress);
        if (status == true) {
          snackbarMessage = "Address saved successfully";
          Navigator.pop(context);
        } else {
          throw "Coundn't save the address due to unknown reason";
        }
      } finally {
        Logger().i(snackbarMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackbarMessage),
          ),
        );
      }
    }
  }

  Future<void> saveEditedAddressButtonCallback() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final AddressModel newAddress =
          generateAddressObject(id: widget.address.addressId);

      bool status = false;
      String snackbarMessage = '';
      try {
        status = await updateAddress(newAddress);
        //     await UserDatabaseHelper().updateAddressForCurrentUser(newAddress);
        if (status == true) {
          snackbarMessage = "Address updated successfully";
          Navigator.pop(context);
        } else {
          throw "Couldn't update address due to unknown reason";
        }
      } finally {
        Logger().i(snackbarMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackbarMessage),
          ),
        );
      }
    }
  }

  Future<bool> addAddress(AddressModel address) async {
    final completer = Completer<bool>();

    ApiUtil.getInstance()!.post(
      url: ApiEndpoint.adress, // Endpoint để thêm địa chỉ
      body: address.toJson(), // Chuyển đổi AddressModel thành JSON
      onSuccess: (response) {
        completer.complete(true); // Thành công
      },
      onError: (error) {
        Logger().e("Error adding address: $error");
        completer.complete(false); // Thất bại
      },
    );

    return completer.future;
  }

  Future<bool> updateAddress(AddressModel address) async {
    final completer = Completer<bool>();

    ApiUtil.getInstance()!.post(
      url:
          "${ApiEndpoint.adress}/${address.addressId}", // Endpoint để cập nhật địa chỉ
      body: address.toJson(), // Chuyển đổi AddressModel thành JSON
      onSuccess: (response) {
        completer.complete(true); // Thành công
      },
      onError: (error) {
        Logger().e("Error updating address: $error");
        completer.complete(false); // Thất bại
      },
    );

    return completer.future;
  }

  AddressModel generateAddressObject({int? id}) {
    return AddressModel.full(
      addressId: id,
      title: titleFieldController.text,
      receiver: receiverFieldController.text,
      addressLine1: addressLine1FieldController.text,
      addressLine2: addressLine2FieldController.text,
      city: cityFieldController.text,
      district: districtFieldController.text,
      state: stateFieldController.text,
      pincode: pincodeFieldController.text,
      phone: phoneFieldController.text,
    );
  }
}
