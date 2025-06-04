import 'dart:async';

import 'package:ecommerce/pages/product_details/components/product_description.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../../api/api_end_point.dart';
import '../../../api/api_util.dart';
import '../../../common/widgets/flutter_toast.dart';
import '../../../models/product_model.dart';
import '../../../services/authentication/authentification_service.dart';
import '../../../services/database/user_database_helper.dart';
import '../../../size_config.dart';
import '../../../utils.dart';
import '../../home/components/top_rounded_container.dart';
import '../provider_models/ProductActions.dart';

class ProductActionsSection extends StatelessWidget {
  final ProductModel product;

  const ProductActionsSection({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final column = Column(
      children: [
        Stack(
          children: [
            TopRoundedContainer(
              child: ProductDescription(product: product),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: buildFavouriteButton(),
            ),
          ],
        ),
      ],
    );

    // Check if the product is in the user's favourite list
    checkProductFavouriteStatus(context);

    return column;
  }

  Widget buildFavouriteButton() {
    return Consumer<ProductActions>(
      builder: (context, productDetails, child) {
        return InkWell(
          onTap: () async {
            bool success = false;

            final future = postFavoriteProduct().then((status) {
              success = status;
            }).catchError((e) {
              Logger().e(e.toString());
              success = false;
            });
            // success when post ok - switch the status

            await showDialog(
              context: context,
              builder: (context) {
                return FutureProgressDialog(
                  future,
                  message: Text(
                    productDetails.productFavStatus
                        ? "Removing from Favourites"
                        : "Adding to Favourites",
                  ),
                );
              },
            );
            if (success) {
              productDetails.switchProductFavStatus();
            }
          },
          child: Container(
            padding: EdgeInsets.all(getProportionateScreenWidth(8)),
            decoration: BoxDecoration(
              color: productDetails.productFavStatus
                  ? Color(0xFFFFE6E6)
                  : Color(0xFFF5F6F9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Padding(
              padding: EdgeInsets.all(getProportionateScreenWidth(8)),
              child: Icon(
                Icons.favorite,
                color: productDetails.productFavStatus
                    ? Color(0xFFFF4848)
                    : Color(0xFFD8DEE4),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Post the product to the user's favourite list - switch the status
  /// if successful, return true, otherwise return false
  Future<bool> postFavoriteProduct() async {
    final completer = Completer<bool>();
    bool status = false;
    ApiUtil.getInstance()!.post(
      url: ApiEndpoint.productYouLike,
      onSuccess: (response) {
        // Xử lý thành công, trả về true
        status = response.data['status'] ?? false;
        completer.complete(status);
      },
      onError: (error) {
        if (error is TimeoutException) {
          toastInfo(msg: "Time out");
        } else {
          toastInfo(msg: error.toString());
        }
        completer.complete(false);
      },
    );
    return completer.future;
  }

  Future<List<ProductModel>> getListProductFavourite() async {
    final completer = Completer<List<ProductModel>>();

    ApiUtil.getInstance()!.get(
      url: ApiEndpoint.productYouLike,
      onSuccess: (response) {
        List<ProductModel> products = (response.data['data'] as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();
        completer.complete(products);
      },
      onError: (error) {
        if (error is TimeoutException) {
          toastInfo(msg: "Time out");
        } else {
          toastInfo(msg: error.toString());
        }
        completer.complete([]);
      },
    );
    return completer.future;
  }

  void checkProductFavouriteStatus(BuildContext context) async {
    List<ProductModel> products = [];
    products = await getListProductFavourite();

    // check if the product is in the list of favourite products
    bool value = products.any((element) => element.id == product.id);
    final productActions = Provider.of<ProductActions>(context, listen: false);
    productActions.productFavStatus = value; // ghi trạng thái
  }
}
