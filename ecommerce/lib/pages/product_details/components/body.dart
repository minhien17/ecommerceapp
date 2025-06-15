import 'package:ecommerce/pages/product_details/components/product_actions_section.dart';
import 'package:ecommerce/pages/product_details/components/product_images.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../../constants.dart';
import '../../../models/product_model.dart';
import '../../../size_config.dart';
import 'product_review_section.dart';

class Body extends StatelessWidget {
  final ProductModel product;

  const Body({
    Key? key,
    required this.product,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(screenPadding)),
            child: Column(
              children: [
                ProductImages(product: product),
                SizedBox(height: getProportionateScreenHeight(20)),
                ProductActionsSection(product: product),
                SizedBox(height: getProportionateScreenHeight(20)),
                ProductReviewsSection(product: product),
                SizedBox(height: getProportionateScreenHeight(100)),
              ],
            )),
      ),
    );
  }
}
