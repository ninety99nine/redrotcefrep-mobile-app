import '../../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../stores/models/shoppable_store.dart';
import '../../../../orders/models/order.dart';
import 'package:flutter/material.dart';
import '../orders_content.dart';

class OrdersModalBottomSheet extends StatefulWidget {
  
  final Order? order;
  final Widget? trigger;
  final ShoppableStore? store;
  final bool canShowFloatingActionButton;

  const OrdersModalBottomSheet({
    super.key,
    this.order,
    this.store,
    this.trigger,
    this.canShowFloatingActionButton = true
  });

  @override
  State<OrdersModalBottomSheet> createState() => OrdersModalBottomSheetState();
}

class OrdersModalBottomSheetState extends State<OrdersModalBottomSheet> {

  int initialOrdersCount = 0;
  Order? get order => widget.order;
  ShoppableStore? get store => widget.store;
  String get totalOrders => (store?.ordersCount ?? 0).toString();
  bool get canShowFloatingActionButton => widget.canShowFloatingActionButton;
  String get totalOrdersText => store?.ordersCount == 1 ? 'Order' : 'Orders';

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  @override
  void initState() {
    super.initState();

    /**
     *  In the case that we have a specific trigger e.g the Order Card at the Profile Page 
     *  or at the Store Page, then we do not need to set the initial order count, since we 
     *  only need that value when we don't set the trigger.
     * 
     *  About the "ordersCount"
     *  ----------------------
     * 
     *  Note that whenever we set the trigger and provide the order, then the store being
     *  provided has been eager loaded on that order but passed separately as a widget
     *  property. However this store that is passed separately but was originally 
     *  eager loaded on this order does not contain relationship totals such as 
     *  the "total followers", "total team members", "total orders", e.t.c so 
     *  that we can have better performance. This means that we should expect 
     *  the store "ordersCount" to be null in the case that an order has been 
     *  provided. In the case that an order has not been provided then the
     *  "ordersCount" will be set.
     */
    if(widget.trigger == null && store != null) {

      /// Get the initial orders count before placing an order.
      /// This initial orders count will be incremented for every new order placed
      initialOrdersCount = store!.ordersCount!;

    }
  }

  @override
  void didUpdateWidget(covariant OrdersModalBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// Check if the number of orders increased.
    /// This happens if the user placed a new order.
    if(widget.trigger == null && store != null && store!.ordersCount! > initialOrdersCount) {

      /**
       *  Automatically open the Orders Modal Popup to show the new order placed
       *  
       *  Note: Future.delayed() is used to prevent the following error:
       * 
       *  This Overlay widget cannot be marked as needing to build because 
       *  the framework is already in the process of building widgets. 
       *  A widget can be marked as needing to be built during the 
       *  build phase only if one of its ancestors is currently 
       *  building. This exception is allowed because the 
       *  framework builds parent widgets before children, 
       *  which means a dirty descendant will always be 
       *  built. Otherwise, the framework might not 
       *  visit this widget during this build 
       *  phase.
       */
      Future.delayed(Duration.zero).then((value) {

        openBottomModalSheet();

        /// Increment the initial orders count
        initialOrdersCount = store!.ordersCount!;

      });

    }
  }

  Widget get trigger {
    /**
     *  When showing an Order Card e.g from the Profile Page or the Store Page,
     *  we want to pass the Order Card as a trigger so that when the Card is
     *  tapped, it automatically launches this bottom modal sheet. In such
     *  cases we would pass the specific order we want to view. This means
     *  we need (1) The store (2) The order (3) The trigger - Order Card
     * 
     *  When showing a Store Card, we don't need to pass any trigger since we
     *  can automatically create a text widget showing the total orders. This
     *  text widget can then be clicked to show the orders of that store. In
     *  such cases we do not need to pass any specific order. This means
     *  we only need (1) The store
     */
    return widget.trigger ?? CustomBodyText([totalOrders, totalOrdersText]);
  }

  /// Open the bottom modal sheet to show the new order placed
  void openBottomModalSheet() {
    if(_customBottomModalSheetState.currentState != null) {
      _customBottomModalSheetState.currentState!.showBottomSheet(context);
    } 
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      key: _customBottomModalSheetState,
      /// Trigger to open the bottom modal sheet
      trigger: trigger,
      /// Content of the bottom modal sheet
      content: OrdersContent(
        canShowFloatingActionButton: canShowFloatingActionButton,
        store: store,
        order: order
      ),
    );
  }
}