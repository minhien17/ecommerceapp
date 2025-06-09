import 'dart:async';

import 'package:ecommerce/api/api_end_point.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../api/api_util.dart';
import '../../../common/widgets/flutter_toast.dart';
import '../../../components/nothingtoshow.dart';
import '../../../components/product_short_detail_card.dart';
import '../../../constants.dart';
import '../../../models/product_model.dart';
import '../../../services/data_stream/users_products_stream.dart';
import '../../../services/database/product_database_helper.dart';
import '../../../services/firestore_file_access/firestore_file_access_service.dart';
import '../../../size_config.dart';
import '../../../utils.dart';
import '../../edit_product/edit_product_page.dart';
import '../../product_details/product_details_screen.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = getProduct();
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
                  Text("Your Products", style: headingStyle),
                  Text(
                    "Swipe LEFT to Edit, Swipe RIGHT to Delete",
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: getProportionateScreenHeight(30)),
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.7,
                    child: FutureBuilder<List<ProductModel>>(
                      future: _productsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final products = snapshot.data;
                          if (products!.length == 0) {
                            return Center(
                              child: NothingToShowContainer(
                                secondaryMessage:
                                    "Add your first Product to Sell",
                              ),
                            );
                          }
                          return ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              return buildProductsCard(products[index]);
                            },
                          );
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
                  SizedBox(height: getProportionateScreenHeight(60)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshPage() async {
    setState(() {
      _productsFuture = getProduct(); // chạy lại getProduct
    });
  }

  Widget buildProductsCard(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: buildProductDismissible(product),
      // FutureBuilder<ProductModel>(
      //   future: getProduct(),
      //   builder: (context, snapshot) {
      //     if (snapshot.hasData) {
      //       final product = snapshot.data as ProductModel;
      //       return buildProductDismissible(product);
      //     } else if (snapshot.connectionState == ConnectionState.waiting) {
      //       return Center(child: CircularProgressIndicator());
      //     } else if (snapshot.hasError) {
      //       final error = snapshot.error.toString();
      //       Logger().e(error);
      //     }
      //     return Center(
      //       child: Icon(
      //         Icons.error,
      //         color: kTextColor,
      //         size: 60,
      //       ),
      //     );
      //   },
      // ),
    );
  }

  Widget buildProductDismissible(ProductModel product) {
    return Dismissible(
      key: Key(product.id),
      direction: DismissDirection.horizontal,
      background: buildDismissibleSecondaryBackground(),
      secondaryBackground: buildDismissiblePrimaryBackground(),
      dismissThresholds: {
        DismissDirection.endToStart: 0.65,
        DismissDirection.startToEnd: 0.65,
      },
      child: ProductShortDetailCard(
        product: product,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                product: product,
              ),
            ),
          );
        },
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final confirmation = await showConfirmationDialog(
              context, "Are you sure to Delete Product?");
          if (confirmation) {
            final supabase = Supabase.instance.client;
            for (int i = 0; i < product.images.length; i++) {
              String path = product.images[i];
              final response =
                  await supabase.storage.from("ecommerce").remove([path]);
              // Hiển thị tiến trình xóa ảnh
              await showDialog(
                context: context,
                builder: (context) {
                  return FutureProgressDialog(
                    Future.value(),
                    message: Text(
                        "Deleting Product Images ${i + 1}/${product.images.length}"),
                  );
                },
              );
            }

            bool productInfoDeleted = false;
            String snackbarMessage = '';
            try {
              final deleteProductFuture = deleteProduct(product.id);
              productInfoDeleted = await showDialog(
                context: context,
                builder: (context) {
                  return FutureProgressDialog(
                    deleteProductFuture,
                    message: Text("Deleting Product"),
                  );
                },
              );
              if (productInfoDeleted == true) {
                snackbarMessage = "Product deleted successfully";
              } else {
                throw "Coulnd't delete product, please retry";
              }
            } on FirebaseException catch (e) {
              Logger().w("Firebase Exception: $e");
              snackbarMessage = "Something went wrong";
            } catch (e) {
              Logger().w("Unknown Exception: $e");
              snackbarMessage = e.toString();
            } finally {
              Logger().i(snackbarMessage);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(snackbarMessage),
                ),
              );
            }
          }
          await refreshPage();
          return confirmation;
        } else if (direction == DismissDirection.endToStart) {
          final confirmation = await showConfirmationDialog(
              context, "Are you sure to Edit Product?");
          if (confirmation) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProductScreen(
                  productToEdit: product,
                ),
              ),
            );
          }
          await refreshPage();
          return false;
        }
        return false;
      },
      onDismissed: (direction) async {
        await refreshPage();
      },
    );
  }

  Widget buildDismissiblePrimaryBackground() {
    return Container(
      padding: EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.edit,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            "Edit",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDismissibleSecondaryBackground() {
    return Container(
      padding: EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Delete",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          SizedBox(width: 4),
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Future<List<ProductModel>> getProduct() async {
    final completer = Completer<List<ProductModel>>();

    ApiUtil.getInstance()!.get(
      url: ApiEndpoint.myproduct, // Endpoint được truyền vào
      onSuccess: (response) {
        List<ProductModel> products = (response.data['data'] as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();
        completer.complete(products);
      },
      onError: (error) {
        if (error is TimeoutException) {
          toastInfo(msg: "Request timed out");
        } else {
          toastInfo(msg: error.toString());
        }
        completer.complete([]); // Trả về danh sách rỗng nếu có lỗi
      },
    );

    return completer.future;
  }

  Future<bool> updateProduct(ProductModel product) async {
    final completer = Completer<bool>();

    ApiUtil.getInstance()!.post(
      url: "${ApiEndpoint.product}/${product.id}", // Endpoint được truyền vào
      onSuccess: (response) {
        completer.complete(true);
      },
      onError: (error) {
        if (error is TimeoutException) {
          toastInfo(msg: "Request timed out");
        } else {
          toastInfo(msg: error.toString());
        }
        completer.complete(false); // Trả về danh sách rỗng nếu có lỗi
      },
    );

    return completer.future;
  }

  Future<bool> deleteProduct(String productId) async {
    final completer = Completer<bool>();

    ApiUtil.getInstance()!.delete(
      url: "${ApiEndpoint.product}/$productId",
      onSuccess: (response) {
        toastInfo(msg: "Product deleted successfully");
        completer.complete(true);
      },
      onError: (error) {
        if (error is TimeoutException) {
          toastInfo(msg: "Request timed out");
        } else {
          toastInfo(msg: error.toString());
        }
        completer.complete(false);
      },
    );

    return completer.future;
  }
}
