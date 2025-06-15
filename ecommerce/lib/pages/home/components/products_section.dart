import 'dart:async';

import 'package:ecommerce/components/nothingtoshow.dart';
import 'package:ecommerce/pages/home/components/section_tile.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../../api/api_end_point.dart';
import '../../../api/api_util.dart';
import '../../../common/widgets/flutter_toast.dart';
import '../../../components/product_card.dart';
import '../../../models/product_model.dart';
import 'package:ecommerce/common/loading.dart';

class ProductsSection extends StatefulWidget {
  final String sectionTitle;
  final String emptyListMessage;
  final Function onProductCardTapped;

  ProductsSection({
    Key? key,
    required this.sectionTitle,
    this.emptyListMessage = "No Products to show here",
    required this.onProductCardTapped,
  }) : super(key: key);

  @override
  State<ProductsSection> createState() => _ProductsSectionState();
}

class _ProductsSectionState extends State<ProductsSection> {
  late Future<List<ProductModel>> _productsFuture;
  List<ProductModel> _products = [];

  @override
  void initState() {
    super.initState();
    _productsFuture = getListProduct();
  }

  Future<List<ProductModel>> getListProduct() async {
    final completer = Completer<List<ProductModel>>();

    if (widget.sectionTitle == "Products You Like") {
      ApiUtil.getInstance()!.get(
        url: ApiEndpoint.productYouLike,
        onSuccess: (response) {
          List<ProductModel> products = (response.data as List)
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
    } else if (widget.sectionTitle == "Discovery") {
      ApiUtil.getInstance()!.get(
        url: ApiEndpoint.discovery,
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
    } else {
      ApiUtil.getInstance()!.get(
        url: ApiEndpoint.product,
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
            print(error);
          }
          completer.complete([]);
        },
      );
    }
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          SectionTile(
            title: widget.sectionTitle,
            press: () {},
          ),
          SizedBox(height: getProportionateScreenHeight(15)),
          Expanded(
            child: buildProductsList(),
          ),
        ],
      ),
    );
  }

  Widget buildProductsList() {
    return FutureBuilder<List<ProductModel>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.length == 0) {
            return Center(
              child: NothingToShowContainer(
                secondaryMessage: widget.emptyListMessage,
              ),
            );
          }
          return buildProductGrid(snapshot.data ?? []);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          final error = snapshot.error;
          Logger().w(error.toString());
        }
        return Center(
          child: NothingToShowContainer(
            iconPath: "assets/icons/network_error.svg",
            primaryMessage: "Something went wrong",
            secondaryMessage: "Unable to connect to Server",
          ),
        );
      },
    );
  }

  Widget buildProductGrid(List<ProductModel> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          press: () {
            widget.onProductCardTapped.call(products[index]);
          },
        );
      },
    );
  }
}
