import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../constants.dart';
import '../models/product_model.dart';
import '../services/database/product_database_helper.dart';
import '../size_config.dart';

class ProductShortDetailCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onPressed;
  const ProductShortDetailCard({
    Key? key,
    required this.product,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onPressed,
        child: Row(
          children: [
            SizedBox(
              width: getProportionateScreenWidth(88),
              child: AspectRatio(
                aspectRatio: 0.88,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Image.network(
                    product.images[0],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(20)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                        text: "\ ${product.discountPrice}    ",
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: "\đ ${product.originalPrice}",
                            style: TextStyle(
                              color: kTextColor,
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.normal,
                              fontSize: 11,
                            ),
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
