import '../../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../../core/shared_widgets/chips/custom_chip.dart';
import '../../../../../core/shared_models/coupon_line.dart';
import 'package:flutter/material.dart';

class CartCouponLine extends StatefulWidget {

  final CouponLine couponLine;

  const CartCouponLine({
    Key? key,
    required this.couponLine
  }) : super(key: key);

  @override
  State<CartCouponLine> createState() => _CartCouponLineState();
}

class _CartCouponLineState extends State<CartCouponLine> {

  bool open = false;

  CouponLine get couponLine =>  widget.couponLine;
  String get discountType => couponLine.discountType;
  bool get hasDescription => couponLine.description != null;
  bool get offerDiscount => couponLine.offerDiscount.status; 
  bool get offerFreeDelivery => couponLine.offerFreeDelivery.status;
  String get freeDeliveryOfferText => offerFreeDelivery ? 'Free Delivery' : '';
  bool get hasCancellationReasons => couponLine.cancellationReasons.isNotEmpty;
  String get firstCancellationReason => hasCancellationReasons ? couponLine.cancellationReasons[0] : '';

  String get discountOfferText {

    String text = 'Discount';

    if( offerDiscount && discountType.toLowerCase() == 'fixed') {
      return '$text | ${couponLine.discountFixedRate.amountWithCurrency}';
    }else if( offerDiscount && discountType.toLowerCase() == 'percentage') {
      return '$text | ${couponLine.discountPercentageRate.valueSymbol}';
    }else{
      return text;
    }

  }

  Widget get couponInformation {
    /**
     *  AnimatedSize helps to animate the sizing from a bigger height
     *  to a smaller height. When hiding or showing the content, the 
     *  transition will be jumpy since the height is not the same.
     *  This helps animate those height differences
     */
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: SizedBox(
        key: ValueKey(open),
        height: open ? null : 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //  Coupon Description
              if(hasDescription) CustomBodyText(couponLine.description!),
              
              //  Coupon Cancellation Reason
              if(hasCancellationReasons) ...couponCancellationReason,
              
              //  Coupon Offers
              counponOffers

            ],
          )
        ),
      )
    );
  }

  Widget get counponOffers {
    return Row(
      children: [

        //  Discount Offer Chip
        if(offerDiscount) CustomChip(label: discountOfferText, type: CustomChipType.success,),
        
        //  Spacer
        if(offerDiscount && offerFreeDelivery) const SizedBox(width: 8,),
        
        //  Free Delivery Offer Chip
        if(offerFreeDelivery) CustomChip(label: freeDeliveryOfferText, type: CustomChipType.success,)
      
      ],
    );
  }

  List<Widget> get couponCancellationReason {
    return [

      //  Divider
      const Divider(),

      //  Cancellation Reason Heading
      const CustomTitleSmallText('Cancellation Reason'),

      //  Divider
      const Divider(),

      //  Cancellation Reason Content
      CustomBodyText(firstCancellationReason),

      //  Spacer
      const SizedBox(height: 8,),

    ];
  }

  @override
  Widget build(BuildContext context) {
    return 
      Container(
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          dense: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //  Spacer
              if(open) const SizedBox(height: 8,),

              //  Coupon Name
              CustomTitleSmallText(couponLine.name, style: TextStyle(decoration: couponLine.isCancelled.status ? TextDecoration.lineThrough : null)),
              
              //  Coupon Information
              couponInformation

            ],
          ),

          //  Arrow Icon
          trailing: Icon(open ? Icons.arrow_drop_up : Icons.arrow_drop_down),
          onTap: () => setState(() => open = !open),
        ),
      );
  }
}