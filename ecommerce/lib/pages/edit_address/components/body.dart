import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../models/address_model.dart';
import '../../../services/database/user_database_helper.dart';
import '../../../size_config.dart';
import 'address_details_form.dart';

class Body extends StatelessWidget {
  final AddressModel address;

  const Body({Key? key, required this.address}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(screenPadding)),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: getProportionateScreenHeight(20)),
                Text(
                  "Fill Address Details",
                  style: headingStyle,
                ),
                SizedBox(height: getProportionateScreenHeight(30)),
                address.addressId == ''
                    ? AddressDetailsForm(
                        address: AddressModel(),
                      )
                    : AddressDetailsForm(address: address),
                SizedBox(height: getProportionateScreenHeight(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
