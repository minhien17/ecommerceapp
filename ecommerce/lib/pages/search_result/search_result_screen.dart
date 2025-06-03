import 'package:ecommerce/models/product_model.dart';
import 'package:flutter/material.dart';

import 'components/body.dart';

class SearchResultScreen extends StatelessWidget {
  final String searchQuery;
  final String searchIn;
  final List<ProductModel> searchResultProducts;

  const SearchResultScreen({
    Key? key,
    required this.searchQuery,
    required this.searchResultProducts,
    required this.searchIn,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Body(
        searchQuery: searchQuery,
        searchResultProducts: searchResultProducts,
        searchIn: searchIn,
      ),
    );
  }
}
