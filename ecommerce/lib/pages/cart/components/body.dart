import 'dart:async';
import 'dart:convert';

import 'package:ecommerce/pages/cart/components/checkout_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
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
import '../../../size_config.dart';
import '../../../utils.dart';
import '../../payment/payment_screen.dart';
import '../../product_details/product_details_screen.dart';
import 'package:http/http.dart' as http;

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  PersistentBottomSheetController? bottomSheetHandler;
  late Future<List<CartItemModel>> _listCart;
  List<ProductModel> _listproducts = [];
  Map<String, dynamic>? paymentIntent;
  @override
  void initState() {
    super.initState();
    _listCart = getListCart();
    getListProduct().then((value) {
      _listproducts = value;
      setState(() {});
    });
  }

  void loadProducts() async {
    _listproducts = await getListProduct();
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
                    CartItemModel cartItem = cartItems[index];
                    if (index >= cartItems.length) {
                      return SizedBox(height: getProportionateScreenHeight(80));
                    }
                    return Dismissible(
                      key: Key(cartItem.id),
                      direction: DismissDirection.startToEnd,
                      dismissThresholds: {
                        DismissDirection.startToEnd: 0.65,
                      },
                      background: buildDismissibleBackground(),
                      child: buildCartItem(cartItem, cartItem.id),
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
                                  snackbarMessage =
                                      "Product removed from cart successfully";
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

    await Future.delayed(Duration(milliseconds: 500)); // Delay song song

    ApiUtil.getInstance()!.get(
      url: ApiEndpoint.userCart,
      onSuccess: (response) {
        List<CartItemModel> list = (response.data as List)
            .map((json) => CartItemModel.fromJson(json))
            .toList();
        completer.complete(list);
        setState(() {});
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

  Future<bool> deleteProduct(String id) {
    final completer = Completer<bool>();

    ApiUtil.getInstance()!.delete(
      // delete
      url: "${ApiEndpoint.userCart}/$id/remove",
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

  Widget buildCartItem(CartItemModel cartItem, String index) {
    final product = _listproducts.firstWhere((p) => p.id == cartItem.id);
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
      child: Row(
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

  Future<void> checkoutButtonCallback(num cartTotal) async {
    print(cartTotal);
    shutBottomSheet();
    await makePayment(cartTotal);
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => PaymentScreen(),
    //   ),
    // );
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

  Future<void> makePayment(num cartTotal) async {
    int amountInCents = (cartTotal * 100).toInt(); // Chuyển sang cent
    try {
      paymentIntent = await createPaymentIntent(
        amount: amountInCents.toString(), // tức là $3.00 nếu dùng đơn vị cent
        currency: "usd",
      );

      if (paymentIntent == null) {
        return;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          merchantDisplayName: 'Demo Store',
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("✅ Thanh toán thành công"),
          content: Icon(Icons.check_circle, color: Colors.green, size: 60),
        ),
      );
      updateOrderedProduct();

      clearCart();

      refreshPage();
      // call api
    } on StripeException catch (e) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("❌ Đã hủy"),
          content: Icon(Icons.cancel, color: Colors.red, size: 60),
        ),
      );
    } catch (e) {
      print('Lỗi không xác định: $e');
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent({
    required String amount, // số tiền (theo cent nếu là USD)
    required String currency, // ví dụ: 'vnd'
  }) async {
    try {
      final url = Uri.parse('https://api.stripe.com/v1/payment_intents');

      final response = await http.post(
        url,
        headers: {
          'Authorization':
              'Bearer $stripeSecretKey', // Thay bằng secret key thật
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount,
          'currency': currency,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Failed to create PaymentIntent: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception in createPaymentIntent: $e");
      return null;
    }
  }

  Future<bool> clearCart() async {
    final completer = Completer<bool>();

    ApiUtil.getInstance()!.delete(
      url: ApiEndpoint.userCart + "/clear", // Endpoint để xóa toàn bộ giỏ hàng
      onSuccess: (response) {
        toastInfo(msg: "Cart cleared successfully");
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

  Future<bool> updateOrderedProduct() async {
    try {
      // Lấy danh sách giỏ hàng từ `_listCart`
      final listCart = await _listCart;

      bool isSuccess = true;

      for (final cartItem in listCart) {
        ApiUtil.getInstance()!.post(
          url: "${ApiEndpoint.orderAdd}", // Endpoint để thêm sản phẩm đã đặt
          body: {
            "order_date":
                DateTime.now().toIso8601String().split('T')[0], // Ngày đặt hàng
            "product_id": cartItem.id, // Lấy product_id từ giỏ hàng
          },
          onSuccess: (response) {
            toastInfo(msg: "Ordered product added successfull");
          },
          onError: (error) {
            isSuccess = false; // Đánh dấu thất bại nếu có lỗi
            if (error is TimeoutException) {
              toastInfo(
                  msg: "Request timed out for product ID: ${cartItem.id}");
            } else {
              toastInfo(
                  msg:
                      "Error for product ID ${cartItem.id}: ${error.toString()}");
            }
          },
        );
      }

      return isSuccess;
    } catch (e) {
      toastInfo(msg: "Unexpected error: ${e.toString()}");
      return false;
    }
  }
}

Future<List<ProductModel>> getListProduct() async {
  final completer = Completer<List<ProductModel>>();

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
  return completer.future;
}
