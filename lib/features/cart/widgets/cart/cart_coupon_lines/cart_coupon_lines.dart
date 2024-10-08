import 'package:perfect_order/features/cart/widgets/cart/cart_coupon_lines/cart_coupon_line.dart';
import '../../../../../core/shared_models/coupon_line.dart';
import '../../../../../core/shared_models/cart.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class CartCouponLines extends StatelessWidget {

  final Cart cart;

  const CartCouponLines({
    super.key, 
    required this.cart,
  });

  List<CouponLine> get couponLines => cart.relationships.couponLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: couponLines.mapIndexed((index, product) {

        final couponLine = couponLines[index];

        return CartCouponLine(couponLine: couponLine);
        
      }).toList(),
    );
  }
}

