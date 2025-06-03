import 'dart:async';

import 'package:ecommerce/common/loading.dart';
import 'package:ecommerce/models/product_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';

import '../../../api/api_end_point.dart';
import '../../../api/api_util.dart';
import '../../../common/widgets/flutter_toast.dart';
import '../../../services/authentication/authentification_service.dart';
import '../../../services/database/user_database_helper.dart';
import '../../../utils.dart';

class AddToCartFAB extends StatelessWidget {
  const AddToCartFAB({
    Key? key,
    required this.product,
  }) : super(key: key);

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        bool addedSuccessfully = false;
        String snackbarMessage = '';
        // addedSuccessfully =
        //     await UserDatabaseHelper().addProductToCart(productId);
        await postProductToCart(context);
        print('object');
      },
      label: const Text(
        "Add to Cart",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      icon: const Icon(
        Icons.shopping_cart,
      ),
    );
  }

  Future<void> postProductToCart(BuildContext context) async {
    AppLoading.show(context);
    //await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    ApiUtil.getInstance()!.post(
      url: "${ApiEndpoint.userCart}/${product.id}",
      onSuccess: (response) {
        AppLoading.hide(context);
      },
      onError: (error) {
        if (error is TimeoutException) {
          toastInfo(msg: "Time out");
        } else {
          toastInfo(msg: error.toString());
        }
        AppLoading.hide(context);
      },
    );
  }
}
