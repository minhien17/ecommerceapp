import 'package:ecommerce/models/product_model.dart';
import 'package:ecommerce/pages/product_details/provider_models/ProductActions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/body.dart';
import 'components/fab.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({
    Key? key,
    required this.product,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProductActions(),
      child: Scaffold(
        backgroundColor: Color(0xFFF5F6F9),
        appBar: AppBar(
          backgroundColor: Color(0xFFF5F6F9),
        ),
        body: Body(
          product: product,
        ),
        floatingActionButton: AddToCartFAB(product: product),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
