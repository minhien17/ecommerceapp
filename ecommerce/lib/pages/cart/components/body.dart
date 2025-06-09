import 'dart:async';

import 'package:ecommerce/pages/cart/components/checkout_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';

import '../../../api/api_end_point.dart';
import '../../../api/api_util.dart';
import '../../../common/widgets/flutter_toast.dart';
import '../../../components/default_button.dart';
import '../../../components/nothingtoshow.dart';
import '../../../components/product_short_detail_card.dart';
import '../../../constants.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/order_product_model.dart';
import '../../../models/product_model.dart';
import '../../../services/database/user_database_helper.dart';
import '../../../size_config.dart';
import '../../../utils.dart';
import '../../product_details/product_details_screen.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  PersistentBottomSheetController? bottomSheetHandler;
  late Future<List<CartItemModel>> _listCart;
  @override
  void initState() {
    super.initState();
    _listCart = getListCart();
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
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(screenPadding)),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(height: getProportionateScreenHeight(10)),
                  Text(
                    "Your Cart",
                    style: headingStyle,
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.75,
                    child: Center(
                      child: buildCartItemsList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshPage() async {
    _listCart = getListCart();
    setState(() {});
  }

  Widget buildCartItemsList() {
    return FutureBuilder<List<CartItemModel>>(
      future: _listCart,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<CartItemModel> cartItems = snapshot.data as List<CartItemModel>;
          if (cartItems.isEmpty) {
            return const Center(
              child: NothingToShowContainer(
                iconPath: "assets/icons/empty_cart.svg",
                secondaryMessage: "Your cart is empty",
              ),
            );
          }

          return Column(
            children: [
              DefaultButton(
                text: "Proceed to Payment",
                press: () {
                  bottomSheetHandler = Scaffold.of(context).showBottomSheet(
                    (context) {
                      return CheckoutCard(
                        onCheckoutPressed: checkoutButtonCallback,
                        cartItems: cartItems,
                      );
                    },
                  );
                },
              ),
              SizedBox(height: getProportionateScreenHeight(20)),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    if (index >= cartItems.length) {
                      return SizedBox(height: getProportionateScreenHeight(80));
                    }
                    return buildCartItemDismissible(
                        context, cartItems[index], index);
                  },
                ),
              ),
            ],
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          final error = snapshot.error;
          Logger().w(error.toString());
        }
        return const Center(
          child: NothingToShowContainer(
            iconPath: "assets/icons/network_error.svg",
            primaryMessage: "Something went wrong",
            secondaryMessage: "Unable to connect to Database",
          ),
        );
      },
    );
  }

  Future<List<CartItemModel>> getListCart() async {
    final completer = Completer<List<CartItemModel>>();

    ApiUtil.getInstance()!.get(
      url: ApiEndpoint.userCart,
      onSuccess: (response) {
        List<CartItemModel> listCarts = (response.data as List)
            .map((json) => CartItemModel.fromJson(json))
            .toList();
        completer.complete(listCarts);
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

  Future<bool> deleteProduct(String id) {
    final completer = Completer<bool>();

    ApiUtil.getInstance()!.delete(
      // delete
      url: "${ApiEndpoint.userCart}/$id",
      onSuccess: (response) {
        completer.complete(true);
      },
      onError: (error) {
        if (error is TimeoutException) {
          toastInfo(msg: "Time out");
        } else {
          toastInfo(msg: error.toString());
        }
        completer.complete(false); // note: cẩn thận với lỗi
      },
    );
    return completer.future;
  }

  Widget buildCartItemDismissible(
      BuildContext context, CartItemModel cartItem, int index) {
    return Dismissible(
      key: Key(cartItem.id),
      direction: DismissDirection.startToEnd,
      dismissThresholds: {
        DismissDirection.startToEnd: 0.65,
      },
      background: buildDismissibleBackground(),
      child: buildCartItem(cartItem, index),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final confirmation = await showConfirmationDialog(
            context,
            "Remove Product from Cart?",
          );
          if (confirmation) {
            if (direction == DismissDirection.startToEnd) {
              bool result = false;
              String snackbarMessage = '';
              try {
                result = await deleteProduct(cartItem.id);
                if (result == true) {
                  snackbarMessage = "Product removed from cart successfully";
                  await refreshPage();
                } else {
                  throw "Coulnd't remove product from cart due to unknown reason";
                }
              } finally {
                Logger().i(snackbarMessage);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(snackbarMessage),
                  ),
                );
              }

              return result;
            }
          }
        }
        return false;
      },
      onDismissed: (direction) {},
    );
  }

  Widget buildCartItem(CartItemModel cartItem, int index) {
    return Container(
      padding: const EdgeInsets.only(
        bottom: 4,
        top: 4,
        right: 4,
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: kTextColor.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: FutureBuilder<ProductModel>(
        future: getProductWithID(cartItem.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            ProductModel product = snapshot.data as ProductModel;
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 8,
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: kTextColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          child: const Icon(
                            Icons.arrow_drop_up,
                            color: kTextColor,
                          ),
                          onTap: () async {
                            await arrowUpCallback(cartItem.id);
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${cartItem.itemCount}",
                          style: const TextStyle(
                            color: kPrimaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          child: const Icon(
                            Icons.arrow_drop_down,
                            color: kTextColor,
                          ),
                          onTap: () async {
                            await arrowDownCallback(cartItem.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            final error = snapshot.error;
            Logger().w(error.toString());
            return Center(
              child: Text(
                error.toString(),
              ),
            );
          } else {
            return const Center(
              child: Icon(
                Icons.error,
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildDismissibleBackground() {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(
            Icons.delete,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          const Text(
            "Delete",
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

  Future<void> checkoutButtonCallback() async {
    shutBottomSheet();
    final confirmation = await showConfirmationDialog(
      context,
      "This is just a Project Testing App so, no actual Payment Interface is available.\nDo you want to proceed for Mock Ordering of Products?",
    );
    if (confirmation == false) {
      return;
    }
    final orderFuture = UserDatabaseHelper().emptyCart();
    orderFuture.then((orderedProductsUid) async {
      if (orderedProductsUid != null) {
        print(orderedProductsUid);
        final dateTime = DateTime.now();
        final formatedDateTime =
            "${dateTime.day}-${dateTime.month}-${dateTime.year}";
        List<OrderedProduct> orderedProducts = orderedProductsUid
            .map((e) =>
                OrderedProduct('', productUid: e, orderDate: formatedDateTime))
            .toList();
        bool addedProductsToMyProducts = false;
        String snackbarmMessage = '';
        try {
          addedProductsToMyProducts =
              await UserDatabaseHelper().addToMyOrders(orderedProducts);
          if (addedProductsToMyProducts) {
            snackbarmMessage = "Products ordered Successfully";
          } else {
            throw "Could not order products due to unknown issue";
          }
        } on FirebaseException catch (e) {
          Logger().e(e.toString());
          snackbarmMessage = e.toString();
        } catch (e) {
          Logger().e(e.toString());
          snackbarmMessage = e.toString();
        } finally {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(snackbarmMessage),
            ),
          );
        }
      } else {
        throw "Something went wrong while clearing cart";
      }
      await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            orderFuture,
            message: const Text("Placing the Order"),
          );
        },
      );
    }).catchError((e) {
      Logger().e(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    });
    await showDialog(
      context: context,
      builder: (context) {
        return FutureProgressDialog(
          orderFuture,
          message: const Text("Placing the Order"),
        );
      },
    );
  }

  void shutBottomSheet() {
    if (bottomSheetHandler != null) {
      bottomSheetHandler!.close();
    }
  }

  Future<void> arrowUpCallback(String id) async {
    shutBottomSheet();
    final future = ApiUtil.getInstance()!.post(
      url: "${ApiEndpoint.userCart}/$id/increase",
      onSuccess: (response) {
        // Do nothing, just return
        refreshPage();
      },
      onError: (error) {
        if (error is TimeoutException) {
          toastInfo(msg: "Time out");
        } else {
          toastInfo(msg: error.toString());
        }
      },
    );
    await showDialog(
      context: context,
      builder: (context) {
        return FutureProgressDialog(
          Future.value(),
          message: const Text("Please wait"),
        );
      },
    );
  }

  Future<void> arrowDownCallback(String id) async {
    shutBottomSheet();
    final future = ApiUtil.getInstance()!.post(
      url: "${ApiEndpoint.userCart}/$id/decrease",
      onSuccess: (response) {
        refreshPage();
      },
      onError: (error) {
        if (error is TimeoutException) {
          toastInfo(msg: "Time out");
        } else {
          toastInfo(msg: error.toString());
        }
      },
    );
    await showDialog(
      context: context,
      builder: (context) {
        return FutureProgressDialog(
          Future.value(),
          message: const Text("Please wait"),
        );
      },
    );
  }
}
