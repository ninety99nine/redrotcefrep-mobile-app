import '../../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/enums/order_enums.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:flutter/material.dart';
import '../orders_content.dart';

class OrdersModalBottomSheet extends StatefulWidget {
  
  final String? orderFilter;
  final ShoppableStore? store;
  final bool canShowFloatingActionButton;
  final Widget Function(Function())? trigger;
  final void Function(Order)? onUpdatedOrder;
  final UserOrderAssociation userOrderAssociation;

  const OrdersModalBottomSheet({
    super.key,
    this.store,
    this.trigger,
    this.orderFilter,
    this.onUpdatedOrder,
    required this.userOrderAssociation,
    this.canShowFloatingActionButton = true,
  });

  @override
  State<OrdersModalBottomSheet> createState() => OrdersModalBottomSheetState();
}

class OrdersModalBottomSheetState extends State<OrdersModalBottomSheet> {

  ShoppableStore? get store => widget.store;
  String? get orderFilter => widget.orderFilter;
  Widget Function(Function())? get trigger => widget.trigger;
  String get totalOrders => (store?.ordersCount ?? 0).toString();
  void Function(Order)? get onUpdatedOrder => widget.onUpdatedOrder;
  bool get canShowFloatingActionButton => widget.canShowFloatingActionButton;
  String get totalOrdersText => store?.ordersCount == 1 ? 'Order' : 'Orders';
  UserOrderAssociation get userOrderAssociation => widget.userOrderAssociation;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {
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
    return trigger == null ? CustomBodyText([totalOrders, totalOrdersText]) : trigger!(openBottomModalSheet);
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
      trigger: _trigger,
      /// Content of the bottom modal sheet
      content: OrdersContent(
        canShowFloatingActionButton: canShowFloatingActionButton,
        userOrderAssociation: userOrderAssociation,
        onUpdatedOrder: onUpdatedOrder,
        orderFilter: orderFilter,
        store: store
      ),
    );
  }
}