import 'package:ecommerce/models/product_model.dart';
import 'package:ecommerce/pages/edit_product/components/body.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider_models/product_detail_model.dart';

class EditProductScreen extends StatelessWidget {
  Product productToEdit = Product('');

  EditProductScreen({Key? key, Product? productToEdit}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProductDetails>(
      create: (context) => ProductDetails(),
      child: Scaffold(
        appBar: AppBar(),
        body: Body(
          productToEdit: productToEdit,
        ),
      ),
    );
  }
}
