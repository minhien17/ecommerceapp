import 'dart:async';

import 'package:flutter/material.dart';

import '../../../api/api_end_point.dart';
import '../../../api/api_util.dart';
import '../../../common/widgets/flutter_toast.dart';
import '../../../components/default_button.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/product_model.dart';
import '../../../size_config.dart';

class CheckoutCard extends StatelessWidget {
  final VoidCallback onCheckoutPressed;
  final List<CartItemModel> cartItems;

  const CheckoutCard({
    Key? key,
    required this.onCheckoutPressed,
    required this.cartItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFDADADA).withOpacity(0.6),
            offset: Offset(0, -15),
            blurRadius: 20,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: getProportionateScreenHeight(20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FutureBuilder<num>(
                  future: getCartTotal(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final cartTotal = snapshot.data;
                      return Text.rich(
                        TextSpan(text: "Total\n", children: [
                          TextSpan(
                            text: "\₹$cartTotal",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ]),
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
                SizedBox(
                  width: getProportionateScreenWidth(190),
                  child: DefaultButton(
                    text: "Checkout",
                    press: onCheckoutPressed,
                  ),
                ),
              ],
            ),
            SizedBox(height: getProportionateScreenHeight(20)),
          ],
        ),
      ),
    );
  }

  Future<num> getCartTotal() async {
    final Completer<num> completer = Completer();
    num total = 0.0;
    for (final doc in cartItems) {
      CartItemModel item = doc;
      String productId = item.id;
      int itemsCount = item.itemCount;
      final product = await getProductWithID(productId);

      total += (itemsCount * (product.discountPrice));
    }
    return total;
  }

  Future<ProductModel> getProductWithID(String productId) async {
    final completer = Completer<ProductModel>();

    ApiUtil.getInstance()!.get(
      url: "${ApiEndpoint.product}/$productId",
      onSuccess: (response) {
        ProductModel product = ProductModel.fromJson(response.data['data']);
        completer.complete(product);
      },
      onError: (error) {
        if (error is TimeoutException) {
          toastInfo(msg: "Time out");
        } else {
          toastInfo(msg: error.toString());
        }
        completer.completeError(error); // note: cẩn thận với lỗi
      },
    );
    return completer.future;
  }
}
