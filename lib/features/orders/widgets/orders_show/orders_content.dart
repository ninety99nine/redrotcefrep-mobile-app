import '../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import 'package:perfect_order/features/orders/providers/order_provider.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'orders_in_vertical_list_view_infinite_scroll.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../order_create/order_create.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'orders_page/orders_page.dart';
import '../../enums/order_enums.dart';
import 'package:get/get.dart';
import 'order_filters.dart';

class OrdersContent extends StatefulWidget {

  final String? orderFilter;

  /// Specify true/false to show a full page view
  final bool showingFullPage;

  /// Specify the store to show orders of that store
  final ShoppableStore? store;

  /// Specify true/false to show the floating action button e.g Place Order / Back
  final bool canShowFloatingActionButton;

  /// Call onUpdatedOrder() notify parent widget on an updated order
  final void Function(Order)? onUpdatedOrder;

  final UserOrderAssociation userOrderAssociation;

  const OrdersContent({
    super.key,
    this.orderFilter,
    required this.store,
    this.onUpdatedOrder,
    this.showingFullPage = false,
    required this.userOrderAssociation,
    this.canShowFloatingActionButton = true
  });

  @override
  State<OrdersContent> createState() => _OrdersContentState();
}

class _OrdersContentState extends State<OrdersContent> {

  String orderFilter = 'All';
  bool disableFloatingActionButton = false;
  OrderContentView orderContentView = OrderContentView.viewingOrders;

  ShoppableStore? get store => widget.store;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;

  void Function(Order)? get onUpdatedOrder => widget.onUpdatedOrder;
  /// canShowFloatingActionButton: Sometimes when we are showing a very specific order, we might not
  /// want the user to have the ability to go back and view the list of other orders, which shows a 
  /// list of orders by this user as well as by other users. In this case we might want to hide the 
  /// floating action button completely so that the "Back" option does not appear.
  bool get canShowFloatingActionButton => widget.canShowFloatingActionButton;
  UserOrderAssociation get userOrderAssociation => widget.userOrderAssociation;
  bool get isViewingOrders => orderContentView == OrderContentView.viewingOrders;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  
  String get title {
    if(isViewingOrders) {
      if(userOrderAssociation == UserOrderAssociation.customer) {
        return 'My Orders';
      }else if(userOrderAssociation == UserOrderAssociation.friend) {
        return 'My Orders';
      }else if(userOrderAssociation == UserOrderAssociation.customerOrFriend) {
        return 'My Orders';
      }else if(userOrderAssociation == UserOrderAssociation.teamMember) {
        return 'Customer Orders';
      }else{
        return '';
      }
    }else{
      return 'Place Order';
    }
  }

  String get subtitle {
    if(isViewingOrders) {
      if(userOrderAssociation == UserOrderAssociation.customer) {
        return 'See what you\'ve ordered';
      }else if(userOrderAssociation == UserOrderAssociation.friend) {
        return 'See what friends have ordered';
      }else if(userOrderAssociation == UserOrderAssociation.customerOrFriend) {
        return 'See what you and friends have ordered';
      }else if(userOrderAssociation == UserOrderAssociation.teamMember) {
        return 'See what customers have ordered';
      }else{
        return '';
      }
    }else{
      return 'Place a new order';
    }
  }

  /// This allows us to access the state of OrderFilters widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  GlobalKey<OrderFiltersState>? _orderFiltersState;

  @override
  void initState() {

    super.initState();

    /// If the order filter is provided
    if(widget.orderFilter != null) {
      
      /// Set the provided order filter
      orderFilter = widget.orderFilter!;

    }
    
    /// Set the "_orderFiltersState" so that we can access the OrderFilters widget state
    _orderFiltersState = GlobalKey<OrderFiltersState>();

  }

  /// Content to show based on the specified view
  Widget get content {

    /// If we want to view the orders content
    if(isViewingOrders) {

      /// Show orders view
      return OrdersInVerticalListViewInfiniteScroll(
        store: store,
        orderFilter: orderFilter,
        onPlaceOrder: onPlaceOrder,
        onUpdatedOrder: onUpdatedOrder,
        requestOrderFilters: requestOrderFilters,
        userOrderAssociation: userOrderAssociation,
      );

    }else{

      /// Show the add order view
      return OrderCreate(
        store: store!,
        onLoading: onLoading,
        onCreatedOrder: onCreatedOrder
      );

    }
    
  }

  /// Floating action button widget
  Widget get floatingActionButton {

    return CustomElevatedButton(
      isViewingOrders ? 'Place Order' : 'Back',
      onPressed: floatingActionButtonOnPressed,
      prefixIcon: isViewingOrders ? null : Icons.keyboard_double_arrow_left,
    );

  }

  /// Action to be called when the floating action button is pressed 
  void floatingActionButtonOnPressed() {

    /// If we have disabled the floating action button, then do nothing
    if(disableFloatingActionButton) return; 

    /// If we are viewing the orders content
    if(isViewingOrders) {

      /// Change to the add order view
      changeOrderContentView(OrderContentView.addingOrder);

    }else{

      /// Change to the show orders view
      changeOrderContentView(OrderContentView.viewingOrders);

    }

  }

  /// While creating an order disable the floating action 
  /// button so that it can no longer perform any
  /// actions when clicked
  void onLoading(bool status) => disableFloatingActionButton = status;

  /// Called when the order filter has been changed,
  /// such as changing from "All" to "Waiting"
  void onSelectedOrderFilter(String orderFilter) {
    setState(() => this.orderFilter = orderFilter);
  }

  /// Change the view to place an order
  void onPlaceOrder() {
    changeOrderContentView(OrderContentView.addingOrder);
  }

  /// Change the view once we are done placing an order
  void onCreatedOrder(Order order) {
    requestOrderFilters();
    changeOrderContentView(OrderContentView.viewingOrders);
  }

  /// Make an Api Request to update the order filters so that
  /// we can acquire the total count of orders assigned to
  /// each filter e.g "Waiting (30)" or "On Its Way (20)"
  void requestOrderFilters() {
    if(_orderFiltersState!.currentState != null) _orderFiltersState!.currentState!.requestOrderFilters();
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
                  padding: EdgeInsets.only(top: 20 + topPadding, left: 32, bottom: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      /// Title
                      CustomTitleMediumText(title, padding: const EdgeInsets.only(bottom: 8),),
                      
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

                      //  Filters
                      if(isViewingOrders) OrderFilters(
                        store: store,
                        key: _orderFiltersState,
                        orderFilter: orderFilter,
                        userOrderAssociation: userOrderAssociation,
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
                Get.back();

                /// Set the store
                if(store != null) storeProvider.setStore(store!);
                
                /// Navigate to the page
                Get.toNamed(
                  OrdersPage.routeName,
                  arguments: {
                    'store': store,
                    'canShowFloatingActionButton': canShowFloatingActionButton
                  }
                );
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Get.back()
            ),
          ),
  
          /// Floating Button
          if(canShowFloatingActionButton)
          AnimatedPositioned(
            right: 10,
            duration: const Duration(milliseconds: 500),
            top: (isViewingOrders ? 112 : 56) + topPadding,
            child: floatingActionButton,
          )
        ],
      ),
    );
  }
}