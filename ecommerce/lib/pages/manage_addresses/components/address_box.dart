import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../../constants.dart';
import '../../../models/address_model.dart';

class AddressBox extends StatelessWidget {
  const AddressBox({
    Key? key,
    required this.address,
  }) : super(key: key);

  final AddressModel address;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${address.title}",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "${address.receiver}",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "${address.addressLine1}",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "${address.addressLine2}",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "City: ${address.city}",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "District: ${address.district}",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "State: ${address.state}",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "PIN: ${address.pincode}",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Phone: ${address.phone}",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
