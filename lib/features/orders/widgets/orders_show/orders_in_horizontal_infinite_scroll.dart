import 'package:bonako_demo/features/user/providers/user_provider.dart';

import '../../../../core/shared_widgets/infinite_scroll/custom_horizontal_page_view_infinite_scroll.dart';
import '../../../user/widgets/customer_profile/customer_profile_avatar.dart';
import '../../../../core/shared_widgets/checkbox/custom_checkbox.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../services/order_services.dart';
import '../../models/order.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../enums/order_enums.dart';
import '../order_show/order_content.dart';

class OrdersInHorizontalInfiniteScroll extends StatefulWidget {
  
  final Order order;
  final bool triggerCancel;
  final String? orderFilter;
  final bool isViewingOrder;
  final ShoppableStore? store;
  final Function(Order) onUpdatedOnMultipleOrders;
  final Function(Order) onUpdatedPreviewSingleOrder;
  final void Function(Order) onRequestedOrderRelationships;

  const OrdersInHorizontalInfiniteScroll({
    Key? key,
    this.store,
    required this.order,
    required this.orderFilter,
    this.triggerCancel = false,
    required this.isViewingOrder,
    required this.onUpdatedOnMultipleOrders,
    required this.onUpdatedPreviewSingleOrder,
    required this.onRequestedOrderRelationships,
  }) : super(key: key);

  @override
  State<OrdersInHorizontalInfiniteScroll> createState() => OrdersInHorizontalInfiniteScrollState();
}

class OrdersInHorizontalInfiniteScrollState extends State<OrdersInHorizontalInfiniteScroll> {

  /// This allows us to access the state of CustomHorizontalPageViewInfiniteScrollState widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomHorizontalPageViewInfiniteScrollState> _customHorizontalPageViewInfiniteScrollState = GlobalKey<CustomHorizontalPageViewInfiniteScrollState>();

  int? orderId;
  int? customerUserId;
  PreviewOrderMode? previewOrderMode;
  bool canShowTogglePreviewMode = true;

  Order get order => widget.order;
  ShoppableStore? get store => widget.store;
  String? get orderFilter => widget.orderFilter;
  bool get triggerCancel => widget.triggerCancel;
  bool get isViewingOrder => widget.isViewingOrder;
  Function(Order) get onUpdatedOnMultipleOrders => widget.onUpdatedOnMultipleOrders;
  UserProvider get userProvider => Provider.of<UserProvider>(context, listen: false);
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  Function(Order) get onUpdatedPreviewSingleOrder => widget.onUpdatedPreviewSingleOrder;
  void Function(Order) get onRequestedOrderRelationships => widget.onRequestedOrderRelationships;

  @override
  void initState() {

    super.initState();
    setPreviewOrderMode();

    /// Show the toggle preview mode checkbox as long as we are 
    /// triggering an automatic cancellation of this order
    canShowTogglePreviewMode = (triggerCancel == false);

    /// If we are viewing a specific order
    if(isViewingOrder) {

      /// Set the order id (This will exclude this order from the list of orders returned)
      orderId = order.id;

      /// Set the order customer user id as the customer user id
      customerUserId = order.customerUserId;
    
    }

  }

  /// Set on the "previewOrderMode" property, the last selected preview order mode 
  /// that was saved on the device. This helps us to know whether we want to show 
  /// the initial order alone (PreviewOrderMode.singleOrder) or the initial order
  /// along side a list of follow up orders (PreviewOrderMode.multipleOrders)
  /// 
  /// If we are triggering an automatic cancellation of this order (the initial order that 
  /// was passed as an argument of the OrdersInHorizontalInfiniteScroll widget), then we 
  /// should always set the "previewOrderMode" to "PreviewOrderMode.singleOrder" so that
  /// we can enable cancellation on the initial order alone without requesting other 
  /// orders
  void setPreviewOrderMode() async {
    if(triggerCancel == true) {

      setState(() => previewOrderMode = PreviewOrderMode.singleOrder);

    }else{

      OrderServices.getSelectedPreviewOrderModeOnDevice().then((previewOrderMode) {
        setState(() => this.previewOrderMode = previewOrderMode);
      });

    }
  }

  /// Called to change determine whether we can show the toggle preview mode checkbox
  /// each time the user swipes from one page to another
  void onPageChanged(int page) {
    setState(() => canShowTogglePreviewMode = page == 0);
  }

  /// Render each request item as an OrderItem
  Widget onRenderItem(order, int index, List orders) => OrderItem(
    customHorizontalPageViewInfiniteScrollState: _customHorizontalPageViewInfiniteScrollState,
    onRequestedOrderRelationships: onRequestedOrderRelationships,
    onUpdatedPreviewSingleOrder: onUpdatedPreviewSingleOrder,
    onUpdatedOnMultipleOrders: onUpdatedOnMultipleOrders,
    previewOrderMode: previewOrderMode,
    triggerCancel: triggerCancel,
    order: (order as Order),
    store: store,
    index: index,
  );

  /// Render each request item as an Order
  Order onParseItem(order) => Order.fromJson(order);
  Future<http.Response> requestStoreOrders(int page, String searchWord) {
    
    Future<http.Response> request;

    /// If the store is not provided
    if( store == null ) {

      /// Request the user orders
      request = userProvider.setUser(authProvider.user!).userRepository.showOrders(
        filter: isViewingOrder ? null : orderFilter,
        withStore: store == null ? true : false,
        startAtOrderId: orderId,
        searchWord: searchWord,
        page: page
      );

    /// If the store is provided
    }else{

      /// Request the store orders
      request = storeProvider.setStore(store!).storeRepository.showOrders(
        /**
         *  If we are viewing a specific order of a customer, then do not
         *  filter by the order filter so that we can fetch all their 
         *  orders. If we are showing different customer orders, then
         *  we can filter by the order filter (orderFilter).
         * 
         *  We can also indicate that the request must return orders
         *  including the selected order that we are currently 
         *  viewing, that is show all other orders including 
         *  this one (exceptOrderId = null).
         */
        filter: isViewingOrder ? null : orderFilter,
        customerUserId: customerUserId,
        startAtOrderId: orderId,
        searchWord: searchWord,
        page: page
      );
      
    }
    
    return request;

  }

  /// Show the preview order mode checkbox
  Widget get previewOrderModeCheckbox {

    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
        child: canShowTogglePreviewMode ? Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0)
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CustomCheckbox(
            disabled: previewOrderMode == null,
            text: 'Show multiple orders and swipe left/right',
            value: previewOrderMode == PreviewOrderMode.multipleOrders,
            onChanged: (value) {
              setState(() {
                if(value == true) {
                  previewOrderMode = PreviewOrderMode.multipleOrders;
                }else{
                  previewOrderMode = PreviewOrderMode.singleOrder;
                }
                OrderServices.saveSelectedPreviewOrderModeOnDevice(previewOrderMode!);
              }); 
            }
          ),
        ) : null,
      ),
    );
    
  }

  /// Show a single order item (the initial order item)
  Widget get singleOrderWidget {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OrderItem(
        onRequestedOrderRelationships: onRequestedOrderRelationships,
        onUpdatedPreviewSingleOrder: onUpdatedPreviewSingleOrder,
        previewOrderMode: previewOrderMode,
        triggerCancel: triggerCancel,
        order: order,
        store: store
      ),
    );
  }

  /// Show multiple order items (the initial order item along side other orders)
  Widget get multipleOrdersWidget {
    return CustomHorizontalPageViewInfiniteScroll(
      showSearchBar: false,
      debounceSearch: false,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      showFirstRequestLoader: true,
      onPageChanged: onPageChanged,
      catchErrorMessage: 'Can\'t show orders',
      headerPadding: const EdgeInsets.only(top: 0),
      key: _customHorizontalPageViewInfiniteScrollState,
      onRequest: (page, searchWord) => requestStoreOrders(page, searchWord),
    );
  }

  /// Content to show based on the specified preview order mode
  Widget get content {
    /**
     *  The Scaffold is wrapped around the content so that we can show the
     *  Snackbar on top of this content whenever its presented on a Dialog
     */
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          
          /// Checkbox to toggle previewing of orders as single order or multiple orders
          previewOrderModeCheckbox,
    
          /// Spacer
          const SizedBox(height: 16),
    
          /// Single Order / Multiple list of scrollable Orders
          Expanded(
            child: previewOrderMode == PreviewOrderMode.singleOrder
              ? singleOrderWidget 
              : multipleOrdersWidget,
          ),

          /// Cancel Icon
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              /// This padding is to increase the surface area for the gesture detector
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                /// This container is to provide a white background around the cancel icon
                /// so that as we scoll and the content passes underneath the icon we do
                /// not see the content showing up on the transparent parts of the icon
                child: Container(
                  decoration: BoxDecoration(
                  color: Colors.white,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Icon(Icons.cancel, size: 40, color: Theme.of(context).primaryColor,)
                ),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
    
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return content;
  }
}

class OrderItem extends StatefulWidget {
  
  final int? index;
  final Order order;
  final bool triggerCancel;
  final ShoppableStore? store;
  final PreviewOrderMode? previewOrderMode;
  final Function(Order)? onUpdatedOnMultipleOrders;
  final Function(Order) onUpdatedPreviewSingleOrder;
  final void Function(Order) onRequestedOrderRelationships;
  final GlobalKey<CustomHorizontalPageViewInfiniteScrollState>? customHorizontalPageViewInfiniteScrollState;

  const OrderItem({
    super.key,
    this.index,
    this.store,
    required this.order,
    required this.triggerCancel,
    required this.previewOrderMode,
    this.onUpdatedOnMultipleOrders,
    this.customHorizontalPageViewInfiniteScrollState,
    required this.onUpdatedPreviewSingleOrder,
    required this.onRequestedOrderRelationships,
  });

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {

  int? get index => widget.index;
  Order get order => widget.order;
  bool get triggerCancel => widget.triggerCancel;
  bool get hasStoreFromOrder => storeFromOrder != null;
  ShoppableStore get store => widget.store ?? storeFromOrder!;
  ShoppableStore? get storeFromOrder => order.relationships.store;
  PreviewOrderMode? get previewOrderMode => widget.previewOrderMode;
  Function(Order)? get onUpdatedOnMultipleOrders => widget.onUpdatedOnMultipleOrders;
  Function(Order) get onUpdatedPreviewSingleOrder => widget.onUpdatedPreviewSingleOrder;
  void Function(Order) get onRequestedOrderRelationships => widget.onRequestedOrderRelationships;
  GlobalKey<CustomHorizontalPageViewInfiniteScrollState>? get customHorizontalPageViewInfiniteScrollState => widget.customHorizontalPageViewInfiniteScrollState;

  /// Update the order on the list of multiple orders
  void updateOrderOnItemList(Order order) {
    if(previewOrderMode == PreviewOrderMode.multipleOrders) {
      customHorizontalPageViewInfiniteScrollState!.currentState!.updateItemAt(index!, order);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: SingleChildScrollView(
        child: Card(
          elevation: 10,
          key: ValueKey<int>(order.id),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0)
          ),
          margin: EdgeInsets.zero,
          child: Column(
            children: [

              /// Customer Profile
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16.0, right: 16.0),
                child: CustomerProfileAvatar(
                  order: order,
                  store: store,
                ),
              ),

              /// Divider
              const Divider(height: 0,),

              /// Order Summary
              OrderContent(
                store: store,
                order: order,
                showLogo: hasStoreFromOrder,
                color: Colors.transparent,
                triggerCancel: triggerCancel,
                key: ValueKey<String>(order.status.name),
                onRequestedOrderRelationships: (Order order) {

                  /// Set the store on the order since this order might not have a store eager loaded as a relationship
                  order.relationships.store = store;

                  updateOrderOnItemList(order);
        
                  /// Notify parent widget of this order with the requested order relationships e.g cart
                  onRequestedOrderRelationships(order);
                  
                },
                onUpdatedOrder: (Order order) {

                  /// Set the store on the order since this order might not have a store eager loaded as a relationship
                  order.relationships.store = store;

                  ///  If we are updating a single order (the initial order that was
                  ///  passed as an argument of the OrdersInHorizontalInfiniteScroll
                  ///  widget)
                  if(previewOrderMode! == PreviewOrderMode.singleOrder) {
        
                    /// Notify parent widget of this single updated order
                    onUpdatedPreviewSingleOrder(order);

                  ///  If we are updating a multiple orders
                  }else{
        
                    updateOrderOnItemList(order);
        
                    /// Notify parent widget of this single updated order on a list of multiple orders
                    onUpdatedOnMultipleOrders!(order);

                  }
                  
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}