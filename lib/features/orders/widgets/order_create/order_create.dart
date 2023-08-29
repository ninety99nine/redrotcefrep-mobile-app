import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/features/shopping_cart/widgets/shopping_cart_content.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/secondary_section_content/secondary_section_content.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class OrderCreate extends StatefulWidget {
  
  final ShoppableStore store;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final void Function(bool) onLoading;
  final void Function(Order)? onCreatedOrder;

  const OrderCreate({
    super.key,
    required this.store,
    required this.onLoading,
    required this.onCreatedOrder,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(top: 0.0),
  });

  @override
  State<OrderCreate> createState() => _OrderCreateState();
}

class _OrderCreateState extends State<OrderCreate> {

  GlobalKey<FormState> formKey = GlobalKey();

  ShoppableStore get store => widget.store;
  void Function(Order)? get onCreatedOrder => widget.onCreatedOrder;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: widget.margin,
        padding: widget.padding,
        child: ListenableProvider.value(
          value: store,
          child: Content(
            onCreatedOrder: onCreatedOrder
          )
        )
      )
    );
  }
}

class Content extends StatelessWidget {

  final void Function(Order)? onCreatedOrder;

  const Content({
    super.key,
    this.onCreatedOrder
  });

  @override
  Widget build(BuildContext context) {
    
    /**
     *  Capture the store that was passed on ListenableProvider.value()
     *  
     *  Set listen to "true'" to catch changes at this level of the
     *  widget tree. For now i have disabled listening as this
     *  level because i can listen to the store changes from
     *  directly on the ShoppableProductCards widget level, 
     *  which is a descendant widget of this widget.
     */
    ShoppableStore store = Provider.of<ShoppableStore>(context, listen: true);
    store.onCreatedOrder = onCreatedOrder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Spacer
        const SizedBox(height: 16),
        
        /// Store Secondary Section Content
        StoreSecondarySectionContent(
          store: store,
          shoppingCartCurrentView: ShoppingCartCurrentView.storeOrdersModalBottomSheet
        ),

        /// Spacer
        const SizedBox(height: 100)

      ],
    );
  }
}