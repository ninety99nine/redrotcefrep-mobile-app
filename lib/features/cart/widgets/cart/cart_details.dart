import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import 'cart_calculations/cart_calculations.dart';
import 'cart_coupon_lines/cart_coupon_lines.dart';
import '../../../../core/shared_models/cart.dart';
import 'cart_product_lines/product_lines.dart';
import 'package:flutter/material.dart';

class CartDetails extends StatelessWidget {

  final Cart cart;
  final bool boldTotal;
  final bool showProductLines;

  const CartDetails({
    super.key,
    required this.cart,
    this.boldTotal = false,
    this.showProductLines = true
  });

  bool get hasCouponLines => cart.totalCoupons > 0;
  bool get hasProductLines => cart.totalUncancelledProducts > 0;
  int get totalUncancelledCoupons => cart.totalUncancelledCoupons;
  bool get hasUncancelledCouponLines => totalUncancelledCoupons > 0;
  
  String get specialOffersText {
    return hasUncancelledCouponLines
      ? '$totalUncancelledCoupons special ${totalUncancelledCoupons == 1 ? 'offer' : 'offers'} added'
      : 'No special offers';
  }

  Widget get productLineHeading {
    return const CustomTitleSmallText('Items');
  }

  Widget get couponLineHeading {
    return Row(
      children: [

        //  Icon
        Icon(Icons.star, color: hasUncancelledCouponLines ? Colors.orange : Colors.grey,),
        
        //  Spacer
        const SizedBox(width: 4,),
        
        //  Heading Text
        CustomTitleSmallText(specialOffersText),
        
      ],
    );
  }

  Widget get content {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Divider
        const Divider(),

        /// Product Line Title
        if(hasCouponLines && showProductLines && hasProductLines) ...[
          productLineHeading,
          const SizedBox(height: 8)
        ],

        /// Product Lines
        if(showProductLines) CartProductLines(cart: cart),

        /// Coupon Line Title
        if(hasCouponLines) ...[

          /// Divider (Separates product lines and coupon lines)
          if(showProductLines && hasProductLines) const Divider(),

          /// Coupon Line Title
          couponLineHeading,
          
          /// Spacer
          const SizedBox(height: 8),

          /// Coupon Lines
          CartCouponLines(cart: cart),

          /// Divider
          const Divider(),

        ],

        /// Cart Calculator
        CartCalculator(cart: cart, boldTotal: boldTotal),
        
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return content;
  }
}

