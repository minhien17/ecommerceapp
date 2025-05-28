import 'package:ecommerce/components/nothingtoshow.dart';
import 'package:ecommerce/pages/home/components/section_tile.dart';
import 'package:ecommerce/services/data_stream/data_stream.dart';
import 'package:ecommerce/services/data_stream/favourite_product_stream.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../../components/product_card.dart';
import '../../../models/product_model.dart';

class ProductsSection extends StatelessWidget {
  final String sectionTitle;
  final String emptyListMessage;
  final Function onProductCardTapped;

  // List<Product> listProduct = [];

  ProductsSection({
    Key? key,
    required this.sectionTitle,
    this.emptyListMessage = "No Products to show here",
    required this.onProductCardTapped,
  }) : super(key: key);

  Future<List<Product>> getListProduct() async {
    if (sectionTitle == "Products You Like") {
      return [];
    } else {
      return []; // api cho all
    }
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
            title: sectionTitle,
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
    return FutureBuilder<List<Product>>(
      future: getListProduct(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.length == 0) {
            return Center(
              child: NothingToShowContainer(
                secondaryMessage: emptyListMessage,
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

  Widget buildProductGrid(List<Product> products) {
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
          productId: products[index].id,
          press: () {
            onProductCardTapped.call(products[index].id);
          },
        );
      },
    );
  }
}
