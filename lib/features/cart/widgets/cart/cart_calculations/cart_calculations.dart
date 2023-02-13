import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../../core/shared_models/cart.dart';
import 'package:flutter/material.dart';

class CartCalculator extends StatefulWidget {

  final Cart? cart;
  final bool boldTotal;

  const CartCalculator({
    super.key, 
    required this.cart,
    this.boldTotal = false
  });

  @override
  State<CartCalculator> createState() => _CartCalculatorState();
}

class _CartCalculatorState extends State<CartCalculator> {

  Cart? get cart => widget.cart;
  bool get boldTotal => widget.boldTotal;
  bool get allowFreeDelivery => cart == null ? false : cart!.allowFreeDelivery.status;
  bool get hasTotalUncancelledProductQuantities => cart!.totalUncancelledProductQuantities > 0;
  bool get showSubTotal => cart == null ? false : cart!.subTotal.amount != cart!.grandTotal.amount;
  bool get showDeliveryFeeTotal => cart == null ? false : cart!.deliveryFee.amount > 0 || allowFreeDelivery;
  bool get showCouponAndSaleDiscountTotal => cart == null ? false : cart!.couponAndSaleDiscountTotal.amount > 0;


  Widget itemLine({ required String heading, required String content, Color? color, bool bold = false }) {
    
    final fontWeight = bold ? FontWeight.bold : FontWeight.normal;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomBodyText(heading, fontWeight: fontWeight),
        CustomBodyText(content, color: color, fontWeight: fontWeight),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        if(hasTotalUncancelledProductQuantities) ...[

          //  Quantities
          itemLine(
            heading: 'Quantities', 
            content: cart!.totalUncancelledProductQuantities.toString()
          ),
            
          //  Spacer
          const SizedBox(height: 8,),

        ],

        if(showDeliveryFeeTotal && allowFreeDelivery) ...[

          //  Free Delivery
          itemLine(
            color: Colors.green,
            heading: 'Delivery', 
            content: 'Free'
          ),
            
          //  Spacer
          const SizedBox(height: 8,),
          
        ],

        if(showSubTotal) ...[

          //  Sub Total
          itemLine(
            heading: 'Subtotal', 
            content: cart!.subTotal.amountWithCurrency
          ),
            
          //  Spacer
          const SizedBox(height: 8,),

        ],

        if(showDeliveryFeeTotal && !allowFreeDelivery) ...[

          //  Delivery Fee Total
          itemLine(
            heading: 'Delivery', 
            content: '+ ${cart!.deliveryFee.amountWithCurrency}'
          ),
            
          //  Spacer
          const SizedBox(height: 8,),
          
        ],

        if(showCouponAndSaleDiscountTotal) ...[
          
          //  Discount Total
          itemLine(
            heading: 'Discount', 
            content: '- ${cart!.couponAndSaleDiscountTotal.amountWithCurrency}'
          ),

          //  Divider
          const Divider()

        ],
          
        //  Grand Total
        itemLine(
          heading: 'Total', 
          bold: boldTotal,
          content: cart!.grandTotal.amountWithCurrency
        ),

        //  Divider
        const Divider()

      ],
    );
  }
}

