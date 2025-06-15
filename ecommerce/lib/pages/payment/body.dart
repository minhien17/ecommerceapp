import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../size_config.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Map<String, dynamic>? paymentIntent;
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
                    "Payment",
                    style: headingStyle,
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.75,
                    child: Center(
                        child: ElevatedButton(
                      onPressed: () async {
                        // Implement payment logic here
                        await makePayment();
                      },
                      child: Text("Make Payment"),
                    )),
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
    setState(() {});
  }

  Future<void> makePayment() async {
    try {
      paymentIntent = await createPaymentIntent(
        amount: "400", // tức là $3.00 nếu dùng đơn vị cent
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
          title: Text("✅ Thành công"),
          content: Icon(Icons.check_circle, color: Colors.green, size: 60),
        ),
      );

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
}
