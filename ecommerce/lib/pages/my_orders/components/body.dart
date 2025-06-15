import 'dart:async';

import 'package:ecommerce/pages/my_orders/components/product_review_dialog.dart';
import 'package:ecommerce/shared_preference.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../../api/api_end_point.dart';
import '../../../api/api_util.dart';
import '../../../common/widgets/flutter_toast.dart';
import '../../../components/nothingtoshow.dart';
import '../../../components/product_short_detail_card.dart';
import '../../../constants.dart';
import '../../../models/order_product_model.dart';
import '../../../models/product_model.dart';
import '../../../models/review_model.dart';
import '../../../size_config.dart';
import '../../product_details/product_details_screen.dart';

class Body extends StatefulWidget {
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
                  SizedBox(height: getProportionateScreenHeight(10)),
                  Text(
                    "Your Orders",
                    style: headingStyle,
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.75,
                    child: buildOrderedProductsList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshPage() {
    return Future<void>.value();
  }

  Widget buildOrderedProductsList() {
    return FutureBuilder<List<OrderedProductModel>>(
      future: getListOrderProduct(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final orderedProducts = snapshot.data;
          if (orderedProducts!.length == 0) {
            return Center(
              child: NothingToShowContainer(
                iconPath: "assets/icons/empty_bag.svg",
                secondaryMessage: "Order something to show here",
              ),
            );
          }
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: orderedProducts.length,
            itemBuilder: (context, index) {
              return buildOrderedProductItem(orderedProducts[index]);
            },
          );
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
            secondaryMessage: "Unable to connect to Database",
          ),
        );
      },
    );
  }

  Widget buildOrderedProductItem(OrderedProductModel orderedProduct) {
    return FutureBuilder<ProductModel>(
      future: getProductWithID(orderedProduct.productUid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final product = snapshot.data;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kTextColor.withOpacity(0.12),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: "Ordered on:  ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: orderedProduct.orderDate,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      vertical: BorderSide(
                        color: kTextColor.withOpacity(0.15),
                      ),
                    ),
                  ),
                  child: ProductShortDetailCard(
                    product: product as ProductModel,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(
                            product: product,
                          ),
                        ),
                      ).then((_) async {
                        await refreshPage();
                      });
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      String currentUserUid =
                          await SharedPreferenceUtil.getToken();
                      ReviewModel prevReview = ReviewModel();
                      try {
                        prevReview =
                            await getReviewWithID(orderedProduct.productUid);
                      } finally {
                        if (prevReview.id == '') {
                          prevReview =
                              ReviewModel.custom(currentUserUid, 0, '');
                        }
                      }

                      final result = await showDialog(
                        context: context,
                        builder: (context) {
                          return ProductReviewDialog(
                            review: prevReview,
                          );
                        },
                      );
                      if (result is ReviewModel) {
                        await updateReview(
                            result,
                            orderedProduct
                                .productUid); // Gọi API cập nhật review
                      }
                      await refreshPage();
                    },
                    child: Text(
                      "Give Product Review",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          final error = snapshot.error.toString();
          Logger().e(error);
        }
        return Icon(
          Icons.error,
          size: 60,
          color: kTextColor,
        );
      },
    );
  }

  Future<List<OrderedProductModel>> getListOrderProduct() async {
    final completer = Completer<List<OrderedProductModel>>();

    ApiUtil.getInstance()!.get(
      url: ApiEndpoint.orders, // Endpoint để lấy danh sách đơn hàng
      onSuccess: (response) {
        List<OrderedProductModel> orderProducts =
            (response.data['data'] as List)
                .map((json) => OrderedProductModel.fromJson(json))
                .toList();
        completer.complete(orderProducts);
      },
      onError: (error) {
        if (error is TimeoutException) {
          toastInfo(msg: "Time out");
        } else {
          toastInfo(msg: error.toString());
        }
        completer.completeError(error); // Xử lý lỗi
      },
    );

    return completer.future;
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

  Future<ReviewModel> getReviewWithID(String reviewId) async {
    final completer = Completer<ReviewModel>();

    ApiUtil.getInstance()!.get(
      url:
          "${ApiEndpoint.review}/$reviewId/detail", // Endpoint để lấy review theo ID
      onSuccess: (response) {
        ReviewModel review = ReviewModel.fromJson(response.data['review']);
        completer.complete(review);
      },
      onError: (error) {
        if (error is TimeoutException) {
          toastInfo(msg: "Time out");
        } else {
          // toastInfo(msg: error.toString());
        }
        completer.complete(ReviewModel()); // Xử lý lỗi
      },
    );

    return completer.future;
  }

  Future<bool> updateReview(ReviewModel reviewModel, String productId) async {
    final completer = Completer<bool>();

    ApiUtil.getInstance()!.post(
      url: "${ApiEndpoint.review}/${productId}", // Endpoint để cập nhật review
      body: {
        "rating": reviewModel.rating,
        "review": reviewModel.feedback,
      }, // Dữ liệu cập nhật
      onSuccess: (response) {
        toastInfo(msg: "Review updated successfully");
        completer.complete(true); // Thành công
      },
      onError: (error) {
        if (error is TimeoutException) {
          toastInfo(msg: "Request timed out");
        } else {
          toastInfo(msg: error.toString());
        }
        completer.complete(false); // Thất bại
      },
    );

    return completer.future;
  }
}
