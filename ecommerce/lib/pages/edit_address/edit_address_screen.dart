import 'package:ecommerce/models/address_model.dart';
import 'package:flutter/material.dart';

import 'components/body.dart';

class EditAddressScreen extends StatelessWidget {
  final AddressModel address;

  const EditAddressScreen({Key? key, required this.address}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Body(address: address),
    );
  }
}
