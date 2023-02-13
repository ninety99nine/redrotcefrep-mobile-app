import '../../../profile/widgets/customer_profile/customer_profile_avatar.dart';
import '../../../../../core/shared_widgets/buttons/custom_elevated_button.dart';
import '../../../../../core/shared_widgets/text/custom_title_large_text.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import 'orders_in_vertical_infinite_scroll.dart';
import '../order_create/order_create.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'orders_page/orders_page.dart';
import '../../enums/order_enums.dart';
import '../../models/order.dart';
import 'order_filters.dart';

class OrdersContent extends StatefulWidget {
  
  final ShoppableStore store;
  final bool showingFullPage;

  const OrdersContent({
    super.key,
    required this.store,
    this.showingFullPage = false
  });

  @override
  State<OrdersContent> createState() => _OrdersContentState();
}

class _OrdersContentState extends State<OrdersContent> {

  Order? order;
  String orderFilter = 'All';
  bool disableFloatingActionButton = false;
  OrderContentView orderContentView = OrderContentView.viewingOrders;

  /// This allows us to access the state of OrderFilters widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  GlobalKey<OrderFiltersState>? _orderFiltersState;

  ShoppableStore get store => widget.store;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  bool get isViewingOrder => orderContentView == OrderContentView.viewingOrder;
  bool get isViewingOrders => orderContentView == OrderContentView.viewingOrders;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  String get subtitle => isViewingOrders ?  'See what others are ordering' : 'Place a new order';

  @override
  void initState() {

    super.initState();
    
    /// Set the "_orderFiltersState" so that we can access the OrderFilters widget state
    _orderFiltersState = GlobalKey<OrderFiltersState>();

  }

  /// Content to show based on the specified view
  Widget get content {

    /// If we want to view the orders content
    if(isViewingOrders || isViewingOrder) {

      /// Show orders view
      return OrdersInVerticalInfiniteScroll(
        store: store,
        order: order,
        onViewOrder: onViewOrder,
        orderFilter: orderFilter,
        onUpdatedOrder: onUpdatedOrder,
        orderContentView: orderContentView,
        requestStoreOrderFilters: requestStoreOrderFilters
      );

    }else{

      /// Show the add order view
      return OrderCreate(
        store: store,
        onLoading: onLoading,
        onCreatedOrder: onCreatedOrder
      );

    }
    
  }

  /// Floating action button widget
  Widget get floatingActionButton {

    return CustomElevatedButton(
      isViewingOrders ? 'Add Order' : 'Back',
      onPressed: floatingActionButtonOnPressed,
      color: isViewingOrders ? Colors.green : Colors.grey,
      prefixIcon: isViewingOrders ? Icons.add : Icons.keyboard_double_arrow_left,
    );

  }

  /// Action to be called when the floacting action button is pressed 
  void floatingActionButtonOnPressed() {

    /// If we should disable the floating action button, then do nothing
    if(disableFloatingActionButton) return; 

    /// If we are viewing the orders content
    if(isViewingOrders) {

      /// Change to the add order view
      changeOrderContentView(OrderContentView.addingOrder);

    }else{
      
      /// Unset the order
      order = null;

      /// Change to the show orders view
      changeOrderContentView(OrderContentView.viewingOrders);

    }

  }

  /// While creating an order disable the floating action 
  /// button so that it can no longer perform any
  /// actions when clicked
  void onLoading(bool status) => disableFloatingActionButton = status;

  /// Change the view once we are done placing an order
  void onCreatedOrder() => changeOrderContentView(OrderContentView.viewingOrders);

  /// Called when the order filter has been changed,
  /// such as changing from "All" to "Waiting"
  void onSelectedOrderFilter(String orderFilter) {
    setState(() => this.orderFilter = orderFilter);
  }

  /// Called when the order has been updated, such as
  /// changing status from "Waiting" to "On Its Way"
  void onUpdatedOrder(Order order) {
    this.order = null;
    requestStoreOrderFilters();
    changeOrderContentView(OrderContentView.viewingOrders);
  }

  /// Make an Api Request to update the order filters so that
  /// we can acquire the total count of orders assigned to
  /// each filter e.g "Waiting (30)" or "On Its Way (20)"
  void requestStoreOrderFilters() {
    if(_orderFiltersState!.currentState != null) _orderFiltersState!.currentState!.requestStoreOrderFilters();
  }

  /// Called to change the view from viewing multiple orders
  /// to viewing one specific order
  void onViewOrder(Order order) {
    this.order = order;
    changeOrderContentView(OrderContentView.viewingOrder);
  }

  /// Called to change the view to the specified view
  void changeOrderContentView(OrderContentView orderContentView) {
    setState(() => this.orderContentView = orderContentView);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
        children: [
          AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
            child: Column(
              key: ValueKey(orderContentView.name),
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                
                /// Wrap Padding around the following:
                /// Title, Subtitle, Customer Profile Avatar, Filters
                Padding(
                  padding: EdgeInsets.only(top: 20 + topPadding, left: (order == null ? 32 : 16), bottom: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      if(order == null) ...[
                
                        /// Title
                        const CustomTitleLargeText('Orders', padding: EdgeInsets.only(bottom: 12),),
                        
                        /// Subtitle
                        AnimatedSwitcher(
                          switchInCurve: Curves.easeIn,
                          switchOutCurve: Curves.easeOut,
                          duration: const Duration(milliseconds: 500),
                          child: Align(
                            key: ValueKey(subtitle),
                            alignment: Alignment.centerLeft,
                            child: CustomBodyText(subtitle),
                          )
                        ),

                      ],

                      /// Customer Profile Avatar
                      if(order != null) CustomerProfileAvatar(
                        order: order!,
                        store: store,
                      ),

                      //  Filters
                      if(isViewingOrders) OrderFilters(
                        store: store,
                        key: _orderFiltersState,
                        orderFilter: orderFilter,
                        onSelectedOrderFilter: onSelectedOrderFilter,
                      ),
                      
                    ],
                  ),
                ),

                /// Content
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    alignment: Alignment.topCenter,
                    width: double.infinity,
                    color: Colors.white,
                    child: content,
                  ),
                )
            
              ],
            ),
          ),
  
          /// Expand Icon
          if(!showingFullPage) Positioned(
            top: 8,
            right: 50,
            child: IconButton(
              icon: const Icon(Icons.open_in_full_rounded, size: 24, color: Colors.grey),
              onPressed: () {
                
                /// Close the Modal Bottom Sheet
                Navigator.of(context).pop();

                /// Set the store
                storeProvider.setStore(store);
                
                /// Navigate to the page
                Navigator.of(context).pushNamed(OrdersPage.routeName);
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
  
          /// Floating Button
          AnimatedPositioned(
            right: 10,
            duration: const Duration(milliseconds: 500),
            top: (isViewingOrders ? 120 : (isViewingOrder ? 52 : 64)) + topPadding,
            child: floatingActionButton,
          )
        ],
      ),
    );
  }
}