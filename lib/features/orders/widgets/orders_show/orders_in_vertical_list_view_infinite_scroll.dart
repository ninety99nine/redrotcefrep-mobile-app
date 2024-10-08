import 'package:perfect_order/features/stores/widgets/store_cards/store_card/primary_section_content/store_logo.dart';
import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import 'package:perfect_order/features/orders/widgets/order_show/components/order_call_customer.dart';
import 'package:perfect_order/features/orders/widgets/order_show/components/order_occasion.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/occasions/models/occasion.dart';
import 'package:perfect_order/features/orders/enums/order_enums.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../order_show/components/order_payment_status.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../order_show/components/order_status.dart';
import 'orders_in_horizontal_infinite_scroll.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../../core/utils/dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import '../../models/order.dart';
import 'package:get/get.dart';

class OrdersInVerticalListViewInfiniteScroll extends StatefulWidget {

  /// Specify the order filter to filter the orders
  final String? orderFilter;

  /// Specify the store to show orders of that store
  final ShoppableStore? store;

  /// Call requestOrderFilters() notify parent widget to change view to place order
  final Function()? onPlaceOrder;

  /// Call requestOrderFilters() notify parent widget to refresh the order filter totals
  final Function() requestOrderFilters;

  /// Call onUpdatedOrder() notify parent widget on an updated order
  final void Function(Order)? onUpdatedOrder;

  /// Specify the user order association to determine the kind of orders to return
  final UserOrderAssociation userOrderAssociation;

  const OrdersInVerticalListViewInfiniteScroll({
    Key? key,
    this.store,
    this.orderFilter,
    this.onPlaceOrder,
    this.onUpdatedOrder,
    required this.requestOrderFilters,
    required this.userOrderAssociation,
  }) : super(key: key);

  @override
  State<OrdersInVerticalListViewInfiniteScroll> createState() => OrdersInVerticalListViewInfiniteScrollState();
}

class OrdersInVerticalListViewInfiniteScrollState extends State<OrdersInVerticalListViewInfiniteScroll> {

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalListViewInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalListViewInfiniteScrollState>();

  ShoppableStore? get store => widget.store;
  String? get orderFilter => widget.orderFilter;
  Function()? get onPlaceOrder => widget.onPlaceOrder;
  Function() get requestOrderFilters => widget.requestOrderFilters;
  void Function(Order)? get onUpdatedOrder => widget.onUpdatedOrder;
  UserOrderAssociation get userOrderAssociation => widget.userOrderAssociation;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  @override
  void didUpdateWidget(covariant OrdersInVerticalListViewInfiniteScroll oldWidget) {

    super.didUpdateWidget(oldWidget);

    /// If the order filter changed
    if(orderFilter != oldWidget.orderFilter) {

      /// Start a new request (so that we can filter orders by the specified order filter)
      _customVerticalListViewInfiniteScrollState.currentState!.startRequest();

      /// Scroll to top
      _customVerticalListViewInfiniteScrollState.currentState!.scrollController.animateTo( 
        0,
        curve:Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 1000),
      );

    }

  }

  /// Render each request item as an OrderItem
  Widget onRenderItem(order, int index, List orders, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) {
    
    /// If this order does not have a store set on its relationship,
    /// then set this store to be part of the order relationships
    order.relationships.store ??= store;
    
    return OrderItem(
      customVerticalListViewInfiniteScrollState: _customVerticalListViewInfiniteScrollState,
      userOrderAssociation: userOrderAssociation,
      fromSameStoreAsOtherOrders: store != null,
      requestOrderFilters: requestOrderFilters,
      onUpdatedOrder: onUpdatedOrder,
      onPlaceOrder: onPlaceOrder,
      orderFilter: orderFilter,
      order: (order as Order),
      store: store,
      index: index,
    );
  }

  /// Render each request item as an Order
  Order onParseItem(order) => Order.fromJson(order);
  Future<dio.Response> requestOrders(int page, String searchWord) {
    
    Future<dio.Response> request;

    /**
     *  If the store is not provided, then we must load the current authenticated user's orders.
     *  These must be orders where the current authenticated user is a customer.
     *
     *  This scenerio where the store does not exist occurs when clicking on the "View All" button of the 
     *  profile orders or the floating action button of the orders icon. This launches the modal bottom
     *  sheet which at some point calls this OrdersInVerticalListViewInfiniteScroll(). In this 
     *  situation the OrdersInVerticalListViewInfiniteScroll() will not have any store as a
     *  point of reference to pull orders, therefore we will default to the current
     *  authenticated user as a point of reference to pull the orders.
     */
    if( store == null ) {

      /// Request the user orders
      request = authProvider.userRepository.showOrders(
        /// Since we don't have the store, we can eager load the store on each order.
        /// Since these orders are acquired through a user and order relationship,
        /// the user and order collection association is included by default.
        userOrderAssociation: userOrderAssociation,
        searchWord: searchWord,
        filter: orderFilter,
        withCustomer: true,
        withOccasion: true,
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
        userOrderAssociation: userOrderAssociation,
        withUserOrderCollectionAssociation: true,
        searchWord: searchWord,
        filter: orderFilter,
        withCustomer: true,
        withOccasion: true,
        page: page
      );
      
    }

    return request.then((response) {

      if( response.statusCode == 200 ) {

        setState(() {

          /// If the response order count does not match the store order count
          if(searchWord.isEmpty && orderFilter == 'All' && store != null && store!.ordersCount != response.data['total']) {

            store!.ordersCount = response.data['total'];
            store!.runNotifyListeners();

          }

        });
        
      }

      return response;

    });
  }
  
  @override
  Widget build(BuildContext context) {

    return CustomVerticalListViewInfiniteScroll(
      debounceSearch: true,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      catchErrorMessage: 'Can\'t show orders',
      key: _customVerticalListViewInfiniteScrollState,
      loaderMargin: const EdgeInsets.symmetric(vertical: 32),
      onRequest: (page, searchWord) => requestOrders(page, searchWord),
      headerPadding: const EdgeInsets.only(top: 40, bottom: 0, left: 16, right: 16)
    );
  }
}

class OrderItem extends StatefulWidget {
  
  final int index;
  final Order order;
  final String? orderFilter;
  final ShoppableStore? store;
  final Function()? onPlaceOrder;
  final Function() requestOrderFilters;
  final bool fromSameStoreAsOtherOrders;
  final Function(Order)? onUpdatedOrder;
  final UserOrderAssociation userOrderAssociation;
  final GlobalKey<CustomVerticalListViewInfiniteScrollState> customVerticalListViewInfiniteScrollState;

  const OrderItem({
    super.key,
    this.store,
    this.orderFilter,
    this.onPlaceOrder,
    this.onUpdatedOrder,
    required this.order,
    required this.index,
    required this.requestOrderFilters,
    required this.userOrderAssociation,
    required this.fromSameStoreAsOtherOrders,
    required this.customVerticalListViewInfiniteScrollState,
  });

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {

  int get index => widget.index;
  Order get order => widget.order;
  bool get hasOccasion => occasion != null;
  bool get isPaid => order.attributes.isPaid;
  String? get orderFilter => widget.orderFilter;
  bool get orderFilterExists => orderFilter != null;
  bool get hasBeenSeen => order.totalViewsByTeam > 0;
  Function()? get onPlaceOrder => widget.onPlaceOrder;
  ShoppableStore get store => order.relationships.store!;
  Occasion? get occasion => order.relationships.occasion;
  bool get hasOrderNumber => order.attributes.number != null;
  bool get isPartiallyPaid => order.attributes.isPartiallyPaid;
  bool get isPendingPayment => order.attributes.isPendingPayment;
  Function get requestOrderFilters => widget.requestOrderFilters;
  bool get canRequestPayment => order.attributes.canRequestPayment;
  void Function(Order)? get onUpdatedOrder => widget.onUpdatedOrder;
  bool get hasOtherAssociatedFriends => otherAssociatedFriends != null;
  String? get customerDisplayName => order.attributes.customerDisplayName;
  bool get fromSameStoreAsOtherOrders => widget.fromSameStoreAsOtherOrders;
  UserOrderAssociation get userOrderAssociation => widget.userOrderAssociation;
  String? get otherAssociatedFriends => order.attributes.otherAssociatedFriends;
  bool get canManageOrders => store.attributes.userStoreAssociation!.canManageOrders;
  bool get canCollect => order.attributes.userOrderCollectionAssociation?.canCollect ?? false;
  GlobalKey<CustomVerticalListViewInfiniteScrollState> get customVerticalListViewInfiniteScrollState => widget.customVerticalListViewInfiniteScrollState;

  Widget get orderHeader {
    return RichText(text: TextSpan(

      /// Customer Display Name (John Doe)
      text: customerDisplayName,
      style: Theme.of(context).textTheme.titleMedium,
      children: [

        /// e.g + 3 friends or for 3 people
        if(hasOtherAssociatedFriends) TextSpan(
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
          text: ' $otherAssociatedFriends'
        ),

      ]

    ));
  }

  void refreshOrdersInVerticalList()
  {
    /// Request the order filters
    requestOrderFilters();

    /// Refresh the orders
    customVerticalListViewInfiniteScrollState.currentState?.startRequest();
  }

  /// Get the index of the item that matches this updated order.
  int getMatchingOrderIndex(Order order) {
    
    /// Notice that we are deliberately searching for an order by id and getting its index instead of using
    /// the index passed on the OrderItem Widget because whenever we use OrdersInHorizontalInfiniteScroll(), 
    /// the order that is being updated might not match the index of the item that was swiped to preview
    /// the same item on the horizontal list of orders. The user could have swipped to a different order
    /// while on the OrdersInHorizontalInfiniteScroll() Widget of the Dialog Widget and updated another 
    /// order instead of the original order that was swiped to initiate the preview in the first place
    return (customVerticalListViewInfiniteScrollState.currentState?.data ?? [] as List<Order>).indexWhere((currOrder) => currOrder.id == order.id);

  }

  /// Update the order matching the specified order on the list of orders
  int updateOrderOnVerticalOrderList(Order order) {

    /// Notify parent widget
    if(onUpdatedOrder != null) {
      
      onUpdatedOrder!(order);

    }

    /// Get the index of the item matching the specified order
    int orderIndex = getMatchingOrderIndex(order);

    /// If we have the order index (must be greater than or equal to zero, since -1 means not found)
    if(orderIndex >= 0) {
        
      /// Update this item on the list
      customVerticalListViewInfiniteScrollState.currentState?.updateItemAt(orderIndex, order);

    }

    return orderIndex;

  }

  /// When the order has been updated, determine whether 
  /// 1) To close the Dialog and dismiss the order item
  /// 2) To close the Dialog but do not dismiss the order item 
  /// 
  /// Do not dismiss the order item when order filter matches the specified filter
  void dismissOrderConditionally (order) {

    /// Update the order matching the specified order on the list of orders
    int orderIndex = updateOrderOnVerticalOrderList(order);

    /// If we have the order index (This means the order matching the speficied order was found and updated successfully)
    if(orderIndex >= 0) {

      /// If we are viewing all orders
      if(orderFilter == 'All') {

        /// Return false not to dismiss this order while closing the dialog
        Get.back(result: false);

      /// If we are viewing filtered orders (filtered as waiting, on its way, e.t.c)
      }else{

        /// Check if the current order status does not match the selected order filter
        final orderStatusDoesNotMatchFilter = orderFilterExists && orderFilter!.toLowerCase() != order.status.name.toLowerCase();

        /// If the status of the updated order does not match the order filter
        if( orderStatusDoesNotMatchFilter ) {

          /// Return true to dismiss this order while closing the dialog.
          /// This is because this order is within the wrong order filter category e.g Updated from "Waiting" to "On Its Way"
          Get.back(result: true);

        /// If the updated order status is the same as the filter of orders we want to view 
        }else{

          /// Return false not to dismiss this order while closing the dialog
          /// This scenerio occurs when we update the order without changing the order status
          /// e.g Updated the order relationships such as the order cart
          Get.back(result: false);

        }

      }

    }else{

      /// Since this order does not exist on the vertical list of orders, then it means that we have updated an order
      /// on the horizontal list of orders that is out of range on the vertical list of orders. We don't need to
      /// dismiss the current order since we updated a different order that we cannot access at this time.
      Get.back(result: false);

    }

  }

  Widget get orderFullContent {
    return OrdersInHorizontalInfiniteScroll(
      order: order,
      store: store,
      orderFilter: orderFilter,
      onPlaceOrder: onPlaceOrder,
      userOrderAssociation: userOrderAssociation,
      onUpdatedOrder: updateOrderOnVerticalOrderList,
      orderContentType: OrderContentType.orderFullContent,
    );
  }

  Widget get orderPaymentContent {
    return OrdersInHorizontalInfiniteScroll(
      order: order,
      store: store,
      orderFilter: orderFilter,
      onPlaceOrder: onPlaceOrder,
      userOrderAssociation: userOrderAssociation,
      onUpdatedOrder: updateOrderOnVerticalOrderList,
      orderContentType: OrderContentType.orderPaymentContent,
    );
  }

  Widget get orderCollectionContent {
    return OrdersInHorizontalInfiniteScroll(
      order: order,
      store: store,
      orderFilter: orderFilter,
      onPlaceOrder: onPlaceOrder,
      userOrderAssociation: userOrderAssociation,
      onUpdatedOrder: updateOrderOnVerticalOrderList,
      orderContentType: OrderContentType.orderCollectionContent,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Dismissible(
      key: ValueKey<int>(order.id),
      direction: DismissDirection.horizontal,
      onDismissed: (DismissDirection direction) {
        
        /// Get the total items left as we dismiss items
        final totalItemsLeft = customVerticalListViewInfiniteScrollState.currentState?.removeItemAt(index);

        /// If we don't have any items left
        if(totalItemsLeft == 0) {

          /// Refresh the items by making an Api Request
          /// Remember that we may have dismissed all the orders but that does not necessarily mean we don't have
          /// any other orders to show since we are paginating results. We can request the list of orders again
          /// to be sure whether or not we still have orders to show.
          refreshOrdersInVerticalList();

        }

      },
      confirmDismiss: (DismissDirection direction) async {
        
        /// Property to determine if we can dismiss this dismissible item
        bool? canDismiss;

        /// If we are swipping left to right
        if(direction == DismissDirection.startToEnd) {

          /// Show a Order Payment Dialog
          DialogUtility.showBlankDialog(
            context: context,
            content: canRequestPayment ? orderPaymentContent : orderFullContent
          );

        /// If we are swipping right to left
        }else {

          /// Show a Order Collection Dialog
          DialogUtility.showBlankDialog(
            context: context,
            content: (canCollect || canManageOrders) ? orderCollectionContent : orderFullContent
          );

        }

        return canDismiss;

      },

      /// List Tile Background
      background: Container(
        color: Colors.grey.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// Swipe to Pay Indication
            Row(
              children: [
                if(canRequestPayment) ...[
                  const Icon(Icons.credit_card, color: Colors.grey,),
                  const SizedBox(width: 8.0,),
                ],
                CustomBodyText(canRequestPayment ? (canManageOrders ? 'Request Payment' : 'Pay') : 'Show order', color: Colors.grey,)
              ]  
            ),

            /// Swipe to Collect Indication
            Row(
              children: [
                if(canCollect || canManageOrders) ...[
                  const Icon(Icons.handshake_outlined, color: Colors.grey,),
                  const SizedBox(width: 8.0,),
                ],
                CustomBodyText(canCollect || canManageOrders ? (canManageOrders ? 'Verify Collection' : 'Collect') : 'Show order', color: Colors.grey,),
              ]  
            ),
          
          ],
        ),
      ),
      
      /// ListTile
      child: ListTile(
          dense: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          onTap: () async {

            /// Show a Dialog of this Order
            DialogUtility.showBlankDialog(
              context: context,
              content: orderFullContent
            );

          },
          title: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        /// Store Logo (Show the logo since we are showing orders from different stores)
                        if(fromSameStoreAsOtherOrders == false) ...[
                  
                          /// Store Logo
                          StoreLogo(store: store, radius: 24),
                  
                          /// Spacer
                          const SizedBox(width: 8,),
                  
                        ],
                  
                        /// Order
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                        
                              if(customerDisplayName != null) ...[
                  
                                /// Order Header
                                orderHeader,
                        
                                /// Spacer
                                const SizedBox(height:  4,),
                  
                              ],
                        
                              if(hasOccasion) ...[
                        
                                /// Spacer
                                const SizedBox(height:  4,),
                      
                                /// Order Occasion
                                if(hasOccasion) OrderOccasion(order: order),
                  
                              ],
                        
                              /// Summary
                              CustomBodyText(order.summary, margin: const EdgeInsets.symmetric(vertical: 4),),
                        
                              /// Spacer
                              const SizedBox(height:  4,),

                              /// Statuses
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                          
                                  /// Status
                                  OrderStatus(
                                    order: order,
                                    lightShade: true,
                                  ),
                              
                                  /// If Paid, Partially Paid or Pending Payment
                                  if(isPaid || isPartiallyPaid || isPendingPayment) ...[
                                          
                                    /// Spacer
                                    const SizedBox(width: 8),
                              
                                    /// Payment Status
                                    OrderPaymentStatus(
                                      lightShade: true,
                                      order: order,
                                    ),
                              
                                  ],
                              
                                ],
                              ),
                        
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      
                      /// Created At
                      CustomBodyText(timeago.format(order.createdAt, locale: 'en_short'), lightShade: true),
                          
                      /// Order Number
                      if(hasOrderNumber) CustomBodyText('#${order.attributes.number}', lightShade: true, margin: const EdgeInsets.only(top: 4),),

                      /// If this order has been seen by the store team members (show the following widgets)
                      if(hasBeenSeen) ...[

                        /// Spacer
                        const SizedBox(height: 4,),

                        /// Seen Icon
                        Icon(FontAwesomeIcons.circleDot, color: Colors.blue.shade700, size: 12,),
                      
                      ]
                    
                    ],
                  ),
          
                  /// Order Call Customer
                  if(canManageOrders) OrderCallCustomer(order: order)

                ],
              ),
            ],
          )
      )
    );
  }
}