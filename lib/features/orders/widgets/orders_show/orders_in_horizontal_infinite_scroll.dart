import 'package:bonako_demo/features/orders/widgets/order_show/components/order_payment/order_request_payment/order_request_payment_dialog_content.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/order_collection_content/order_collection_content.dart';
import '../../../../core/shared_widgets/infinite_scroll/custom_horizontal_page_view_infinite_scroll.dart';
import 'package:bonako_demo/core/shared_widgets/icon_button/close_modal_icon_button.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/features/stores/widgets/store_dialog_header.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/user/providers/user_provider.dart';
import '../order_show/full_order_content/full_order_content.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import '../../models/order.dart';
import 'dart:convert';

enum OrderContentType {
  orderFullContent,
  orderPaymentContent,
  orderCollectionContent,
}

class OrdersInHorizontalInfiniteScroll extends StatefulWidget {
  
  final Order? order;
  final String? orderFilter;
  final ShoppableStore? store;
  final Function()? onPlaceOrder;
  final OrderContentType orderContentType;
  final void Function(Order)? onUpdatedOrder;

  const OrdersInHorizontalInfiniteScroll({
    Key? key,
    this.store,
    this.onPlaceOrder,
    required this.order,
    required this.orderFilter,
    required this.onUpdatedOrder,
    required this.orderContentType,
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
  bool canShowSwipeLeftOrRightInstruction = true;

  Order? get order => widget.order;
  ShoppableStore? get store => widget.store;
  String? get orderFilter => widget.orderFilter;
  Function()? get onPlaceOrder => widget.onPlaceOrder;
  OrderContentType get orderContentType => widget.orderContentType;
  void Function(Order)? get onUpdatedOrder => widget.onUpdatedOrder;
  UserProvider get userProvider => Provider.of<UserProvider>(context, listen: false);
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  @override
  void initState() {

    super.initState();

    /// Set the order id (This will exclude this order from the list of orders returned)
    orderId = order?.id;

  }

  /// Called to determine whether we can show the swipe left or right instructions
  /// each time the user swipes from one page to another
  void onPageChanged(int page) {
    setState(() => canShowSwipeLeftOrRightInstruction = page == 0);
  }

  /// Render each request item as an OrderItem
  Widget onRenderItem(order, int index, List orders) {
    
    /// If this order does not have a store set on its relationship,
    /// then set this store to be part of the order relationships
    order.relationships.store ??= widget.store;

    return OrderItem(
      customHorizontalPageViewInfiniteScrollState: _customHorizontalPageViewInfiniteScrollState,
      orderContentType: orderContentType,
      onUpdatedOrder: onUpdatedOrder,
      order: (order as Order),
      index: index,
    );
  }

  /// Render each request item as an Order
  Order onParseItem(order) => Order.fromJson(order);
  Future<dio.Response> requestStoreOrders(int page, String searchWord) {
    
    Future<dio.Response> request;

    /// If the store is not provided
    if( store == null ) {

      /// Request the user orders
      request = userProvider.setUser(authProvider.user!).userRepository.showOrders(
        /// Since we don't have the store, we can eager load the store on each order.
        /// Since these orders are acquired through a user and order relationship,
        /// the user and order collection association is included by default.
        startAtOrderId: orderId,
        searchWord: searchWord,
        filter: orderFilter,
        withStore: true,
        page: page
      );

    /// If the store is provided
    }else{

      /// Request the store orders
      request = storeProvider.setStore(store!).storeRepository.showOrders(
        /// Since these orders are not acquired through a user and order relationship,
        /// we need to indicate that we cant to also eager load the user and order
        /// collection association
        withUserOrderCollectionAssociation: true,
        startAtOrderId: orderId,
        searchWord: searchWord,
        filter: orderFilter,
        page: page
      ).then((response) {

        if(response.statusCode == 200) {

          /// If the response order count does not match the store order count
          if(orderId == null && searchWord.isEmpty && orderFilter == 'All' && store!.ordersCount != response.data['total']) {

            store!.ordersCount = response.data['total'];
            store!.runNotifyListeners();

          }

        }

        return response;

      });
      
    }
    
    return request;

  }

  /// Show the swipe left or right instruction
  Widget get swipeLeftOrRightInstruction {

    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
        child: canShowSwipeLeftOrRightInstruction ? Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0)
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const CustomBodyText('Swipe left or right to see other orders'),
        ) : null,
      ),
    );
    
  }

  Widget get noMoreContentWidget {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0)
        ),
        margin: EdgeInsets.zero,
        child: Column(
          children: [

            SizedBox(
              width: 400,
              child: Image.asset('assets/images/welcome/6.png'),
            ),

            const CustomBodyText('No more orders', margin: EdgeInsets.only(bottom: 32),),

            if(onPlaceOrder != null) CustomElevatedButton(
              'Place Order',
              onPressed: onPlaceOrder,
              alignment: Alignment.center,
            )

          ]
        )
      )
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
          
          /// Swipe left or right instructions
          swipeLeftOrRightInstruction,
    
          /// Spacer
          const SizedBox(height: 16),
    
          /// Scrollable Orders
          Expanded(
            child: CustomHorizontalPageViewInfiniteScroll(
              showSearchBar: false,
              debounceSearch: false,
              onParseItem: onParseItem, 
              onRenderItem: onRenderItem,
              showFirstRequestLoader: true,
              onPageChanged: onPageChanged,
              catchErrorMessage: 'Can\'t show orders',
              noMoreContentWidget: noMoreContentWidget,
              headerPadding: const EdgeInsets.only(top: 0),
              key: _customHorizontalPageViewInfiniteScrollState,
              onRequest: (page, searchWord) => requestStoreOrders(page, searchWord),
            )
          ),

          /// Close Modal Icon Button
          const CloseModalIconButton(),
    
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
  
  final int index;
  final Order order;
  final OrderContentType orderContentType;
  final void Function(Order)? onUpdatedOrder;
  final GlobalKey<CustomHorizontalPageViewInfiniteScrollState>? customHorizontalPageViewInfiniteScrollState;

  const OrderItem({
    super.key,
    required this.index,
    required this.order,
    required this.onUpdatedOrder,
    required this.orderContentType,
    this.customHorizontalPageViewInfiniteScrollState,
  });

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {

  late Order order;
  late bool hasStoreFromOrder;
  late ShoppableStore? storeFromOrder;

  int get index => widget.index;
  ShoppableStore get store => order.relationships.store!;
  OrderContentType get orderContentType => widget.orderContentType;
  void Function(Order)? get onUpdatedOrder => widget.onUpdatedOrder;
  GlobalKey<CustomHorizontalPageViewInfiniteScrollState>? get customHorizontalPageViewInfiniteScrollState => widget.customHorizontalPageViewInfiniteScrollState;

  @override
  void initState() {
    super.initState();
    order = widget.order;
    storeFromOrder = order.relationships.store;
    hasStoreFromOrder = storeFromOrder != null;
    
  }

  /// Update the order on the list of multiple orders
  void updateOrderOnItemList(Order order) {
    customHorizontalPageViewInfiniteScrollState!.currentState!.updateItemAt(index, order);
  }

  Widget get orderContent {

    if(orderContentType == OrderContentType.orderFullContent) {

      /// Order Summary
      return FullOrderContent(
        order: order,
        key: ValueKey<String>(order.status.name),
        onUpdatedOrder: (Order order) {

          /// Update the order on the list of orders
          updateOrderOnItemList(order);

          /// Notify parent widget of this updated order status
          if(onUpdatedOrder != null) onUpdatedOrder!(order);
          
        },
      );

    }else if(orderContentType == OrderContentType.orderPaymentContent) {

      /// Order Request Payment Dialog Content
      return OrderRequestPaymentDialogContent(
        order: order,
        key: ValueKey<String>(order.status.name),
        onRequestPayment: (Transaction transaction) {
          
          
        },
      );
    
    }else if(orderContentType == OrderContentType.orderCollectionContent) {
      
      /// Order Collection Content
      return OrderCollectionContent(
        order: order,
        key: ValueKey<String>(order.status.name),
        onUpdatedOrder: (Order order) {

          /// Update the order on the list of orders
          updateOrderOnItemList(order);

          /// Notify parent widget of this updated order status
          if(onUpdatedOrder != null) onUpdatedOrder!(order);
          
        },
      );
    
    }else{

      return const SizedBox();

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
      child: Card(
        elevation: 10,
        key: ValueKey<int>(order.id),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0)
        ),
        margin: EdgeInsets.zero,
        child: Column(
          children: [
    
            /// Store Dialog Header
            StoreDialogHeader(store: store, padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0)),
    
            Expanded(
              child: SingleChildScrollView(
                child: orderContent
              )
            ),
            
          ],
        )
      ),
    );
  }
}