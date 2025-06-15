import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

import '../../../api/api_end_point.dart';
import '../../../api/api_util.dart';
import '../../../common/widgets/flutter_toast.dart';
import '../../../components/nothingtoshow.dart';
import '../../../components/product_card.dart';
import '../../../components/rounded_icon_button.dart';
import '../../../components/search_field.dart';
import '../../../constants.dart';
import '../../../models/product_model.dart';
import '../../../size_config.dart';
import '../../product_details/product_details_screen.dart';
import '../../search_result/search_result_screen.dart';

class Body extends StatefulWidget {
  final ProductType productType;

  Body({
    Key? key,
    required this.productType,
  }) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshPage,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(screenPadding)),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(height: getProportionateScreenHeight(20)),
                  buildHeadBar(),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.13,
                    child: buildCategoryBanner(),
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.68,
                    child: FutureBuilder<List<ProductModel>>(
                      future: getListProduct(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<ProductModel> products =
                              snapshot.data as List<ProductModel>;
                          if (products.length == 0) {
                            return Center(
                              child: NothingToShowContainer(
                                secondaryMessage:
                                    "No Products in ${EnumToString.convertToString(widget.productType)}",
                              ),
                            );
                          }

                          return buildProductsGrid(products);
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                            secondaryMessage: "Unable to connect to Database",
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<ProductModel>> getListProductSearch(String query) async {
    final completer = Completer<List<ProductModel>>();

    ApiUtil.getInstance()!.get(
      url: ApiEndpoint.product,
      params: {
        "query": query,
        "category": EnumToString.convertToString(widget.productType)
      },
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
    return completer.future;
  }

  Future<List<ProductModel>> getListProduct() async {
    final completer = Completer<List<ProductModel>>();

    ApiUtil.getInstance()!.get(
      url: ApiEndpoint.product,
      params: {"category": EnumToString.convertToString(widget.productType)},
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
          completer.complete([]);
        }
      },
    );
    return completer.future;
  }

  Widget buildHeadBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RoundedIconButton(
          iconData: Icons.arrow_back_ios,
          press: () {
            Navigator.pop(context);
          },
        ),
        SizedBox(width: 5),
        Expanded(
          child: SearchField(
            onSubmit: (value) async {
              final query = value.toString();
              if (query.length <= 0) return;
              List<ProductModel> searchedProducts = [];
              try {
                // call api
                searchedProducts = await getListProductSearch(query);

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultScreen(
                      searchQuery: query,
                      searchResultProducts: searchedProducts,
                      searchIn:
                          EnumToString.convertToString(widget.productType),
                    ),
                  ),
                );
                await refreshPage();
              } catch (e) {
                final error = e.toString();
                Logger().e(error);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$error"),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> refreshPage() {
    return getListProduct();
  }

  Widget buildCategoryBanner() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(bannerFromProductType()),
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(
                kPrimaryColor,
                BlendMode.hue,
              ),
            ),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              EnumToString.convertToString(widget.productType),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildProductsGrid(List<ProductModel> products) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: GridView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: products.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ProductCard(
            product: products[index],
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(
                    product: products[index],
                  ),
                ),
              ).then(
                (_) async {
                  await refreshPage();
                },
              );
            },
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 2,
          mainAxisSpacing: 8,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 12,
        ),
      ),
    );
  }

  String bannerFromProductType() {
    switch (widget.productType) {
      case ProductType.electronic:
        return "assets/images/electronics_banner.jpg";
      case ProductType.book:
        return "assets/images/books_banner.jpg";
      case ProductType.fashion:
        return "assets/images/fashions_banner.jpg";
      case ProductType.grocery:
        return "assets/images/groceries_banner.jpg";
      case ProductType.art:
        return "assets/images/arts_banner.jpg";
      case ProductType.other:
        return "assets/images/others_banner.jpg";
      default:
        return "assets/images/others_banner.jpg";
    }
  }
}
