import 'package:bonako_demo/core/shared_models/cart.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';

import '../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../cart/widgets/cart/cart_details.dart' as cart;
import '../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class CartDetails extends StatefulWidget {
  const CartDetails({super.key});

  @override
  State<CartDetails> createState() => _CartDetailsState();
}

class _CartDetailsState extends State<CartDetails> {
  
  ShoppableStore? store;
  bool get hasDetectedChanges => detectedChanges.isNotEmpty;
  bool get isLoading => store == null ? false : store!.isLoading;
  bool get hasShoppingCart => store == null ? false : store!.hasShoppingCart;
  bool get hasSelectedProducts => store == null ? false : store!.hasSelectedProducts;
  List<DetectedChange> get detectedChanges => store == null ? [] : store!.shoppingCart!.detectedChanges;

  Widget get detectedChangeList {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Detected changes title
          const CustomMessageAlert('Important changes'),

          /// Spacer
          const SizedBox(height: 16),

          /// List of detected changes
          ...detectedChanges.map((detectedChange) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: CustomBodyText(' ${detectedChange.message}'),
            );
          }).toList()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    /// Capture the store that was passed on ListenableProvider.value()
    /// of the StoreCard. This store is accessible if the StoreCard is
    /// an ancestor of this ShoppableProductCards. We can use this shoppable 
    /// store instance for shopping purposes e.g selecting this
    /// product so that we can place an order.
    store = Provider.of<ShoppableStore>(context, listen: true);
    
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
        child: Column(
          key: ValueKey('$hasShoppingCart $hasSelectedProducts'),
          children: hasSelectedProducts ? [

            /// Detected change list
            if(hasShoppingCart && hasDetectedChanges) detectedChangeList,

            Stack(
              children: [
                
                /// Cart Details
                if(hasShoppingCart) AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: isLoading ? 0.2 : 1,
                  child: cart.CartDetails(
                    showProductLines: false,
                    cart: store!.shoppingCart!,
                  )
                ),
                
                ///  Loader
                if(isLoading && hasSelectedProducts && !hasShoppingCart) const CustomCircularProgressIndicator(
                  size: 20,
                  margin: EdgeInsets.only(top: 16, bottom: 16),
                ),
    
                ///  Floating Loader
                if(isLoading && hasSelectedProducts && hasShoppingCart) const Positioned.fill(
                  child: CustomCircularProgressIndicator(size: 20)
                ),

              ]
            ),
          ] : [],
        )
      ),
    );
  }
}