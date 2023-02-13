import '../../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:flutter/material.dart';
import '../orders_content.dart';

class OrdersModalBottomSheet extends StatefulWidget {
  
  final ShoppableStore store;

  const OrdersModalBottomSheet({
    super.key,
    required this.store
  });

  @override
  State<OrdersModalBottomSheet> createState() => OrdersModalBottomSheetState();
}

class OrdersModalBottomSheetState extends State<OrdersModalBottomSheet> {

  int initialOrdersCount = 0;
  ShoppableStore get store => widget.store;
  String get totalOrders => store.ordersCount!.toString();
  String get totalOrdersText => store.ordersCount == 1 ? 'Order' : 'Orders';

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  @override
  void initState() {
    super.initState();

    /// Get the initial orders count before placing an order.
    /// This initial orders count will be incremented for every new order placed
    initialOrdersCount = store.ordersCount!;
  }

  @override
  void didUpdateWidget(covariant OrdersModalBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// Check if the number of orders increased.
    /// This happens if the user placed a new order.
    if(store.ordersCount! > initialOrdersCount) {

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

        /// Increment the nitial orders count
        initialOrdersCount = store.ordersCount!;

      });

    }
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
      trigger: CustomBodyText([totalOrders, totalOrdersText]),
      /// Content of the bottom modal sheet
      content: OrdersContent(
        store: store,
      ),
    );
  }
}