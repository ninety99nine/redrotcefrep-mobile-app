import 'package:bonako_demo/features/orders/services/order_services.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/store_logo.dart';
import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import 'package:bonako_demo/core/shared_models/user_order_collection_association.dart';
import '../../../../../core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/user/providers/user_provider.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/constants.dart' as constants;
import '../../../authentication/providers/auth_provider.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/services/store_services.dart';
import '../../../stores/models/shoppable_store.dart';
import 'orders_in_horizontal_infinite_scroll.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../../core/utils/dialog.dart';
import '../order_show/order_content.dart';
import '../order_show/order_status.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../enums/order_enums.dart';
import '../../models/order.dart';
import 'dart:convert';

class OrdersInVerticalListViewInfiniteScroll extends StatefulWidget {
  
  final Order? order;
  final String orderFilter;
  final ShoppableStore? store;
  final Function(Order) onViewOrder;
  final Function(Order) onUpdatedOrder;
  final OrderContentView orderContentView;
  final Function() requestStoreOrderFilters;

  const OrdersInVerticalListViewInfiniteScroll({
    Key? key,
    this.order,
    this.store,
    required this.onViewOrder,
    required this.orderFilter,
    required this.onUpdatedOrder,
    required this.orderContentView,
    required this.requestStoreOrderFilters
  }) : super(key: key);

  @override
  State<OrdersInVerticalListViewInfiniteScroll> createState() => OrdersInVerticalListViewInfiniteScrollState();
}

class OrdersInVerticalListViewInfiniteScrollState extends State<OrdersInVerticalListViewInfiniteScroll> {

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalInfiniteScrollState>();

  int? orderId;
  int? friendUserId;
  int? customerUserId;
  bool hasOrders = false;
  Order? get order => widget.order;
  bool? authenticatedUserIsOrderCustomer;
  ShoppableStore? get store => widget.store;
  String get orderFilter => widget.orderFilter;
  Function(Order) get onViewOrder => widget.onViewOrder;
  Function(Order) get onUpdatedOrder => widget.onUpdatedOrder;
  OrderContentView get orderContentView => widget.orderContentView;
  Function() get requestStoreOrderFilters => widget.requestStoreOrderFilters;
  bool get isViewingOrder => orderContentView == OrderContentView.viewingOrder;
  bool get isViewingOrders => orderContentView == OrderContentView.viewingOrders;
  UserProvider get userProvider => Provider.of<UserProvider>(context, listen: false);
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  @override
  void initState() {
    
    super.initState();

    /// If we are viewing a specific order
    if(isViewingOrder) {

      /// Set the order id (This will exclude this order from the list of orders returned)
      orderId = order!.id;

      /// Set the order customer user id as the customer user id
      customerUserId = order!.customerUserId;

      /// Check if this order belongs to the authenticated user
      authenticatedUserIsOrderCustomer = order!.customerUserId == authProvider.user!.id;

      /**
       *  If the customer user id does not match the authenticated user id, then set the friend 
       *  user id as the current authenticated user id so that we can query orders where this
       *  customer has shared orders with the authenticated user. This means that we can 
       *  query orders where the authenticated user is added as a friend to this 
       *  customer's order.
       */
      if(authenticatedUserIsOrderCustomer! == false) {
        
        /// Set the friend user id as the current authenticated user id
        friendUserId = authProvider.user!.id;

      }
    
    }

  }

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

    /// If the order changed such as selecting another order while viewing a specific order
    if(order != null && oldWidget.order != null && order!.id != oldWidget.order!.id) {

      /// Set the order id (This will exclude this order from the list of orders returned)
      orderId = order!.id;

      /// Start a new request (so that we can filter orders by the specified customer) and 
      /// also exclude the selected order from the list of orders returned by the request
      _customVerticalListViewInfiniteScrollState.currentState!.startRequest();

    }

  }

  /// Render each request item as an OrderItem
  Widget onRenderItem(order, int index, List orders, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) {
    
    return OrderItem(
      customVerticalListViewInfiniteScrollState: _customVerticalListViewInfiniteScrollState,
      requestStoreOrderFilters: requestStoreOrderFilters,
      orderContentView: orderContentView,
      orders: (List<Order>.from(orders)),
      onViewOrder: onViewOrder,
      orderFilter: orderFilter,
      order: (order as Order),
      store: store,
      index: index,
    );
  }

  /// Render each request item as an Order
  Order onParseItem(order) => Order.fromJson(order);
  Future<http.Response> requestStoreOrders(int page, String searchWord) {
    
    Future<http.Response> request;

    /**
     *  If the store is not provided, then we must load the current authenticated user's orders.
     *  These must be orders where the current authenticated user is a customer.
     *
     *  This scenerio where the store does not exist occurs when clicking on the "View All"
     *  button of the profile orders. This launches the modal bottom sheet which at some 
     *  point calls this OrdersInVerticalListViewInfiniteScroll(). In this situation the
     *  OrdersInVerticalListViewInfiniteScroll() will not have any store as a point of 
     *  reference to pull orders, therefore we will default to the current 
     *  authenticated user as a point of reference to pull the orders.
     */
    if( store == null ) {

      /**
       *  Request the user orders.
       * 
       *  When veiwing multiple orders, then filter by the order filter. When viewing a
       *  specific order, then filter by the "me" filter so that we can only fetch
       *  orders where the current authenticated user is a customer. 
       */
      request = userProvider.setUser(authProvider.user!).userRepository.showOrders(
        filter: isViewingOrder ? null : orderFilter,
        withStore: store == null ? true : false,
        customerUserId: customerUserId,
        friendUserId: friendUserId,
        exceptOrderId: orderId,
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
         *  except the selected order that we are currently viewing, 
         *  that is, show all other orders except this one, where
         *  (exceptOrderId = orderId).
         */
        filter: isViewingOrder ? null : orderFilter,
        customerUserId: customerUserId,
        friendUserId: friendUserId,
        exceptOrderId: orderId,
        searchWord: searchWord,
        page: page
      ).then((response) {

        if(response.statusCode == 200) {

          final responseBody = jsonDecode(response.body);

          /// If the response order count does not match the store order count
          if(isViewingOrder == false && orderFilter == 'All' && store!.ordersCount != responseBody['total']) {

            store!.ordersCount = responseBody['total'];
            store!.runNotifyListeners();

          }

        }

        return response;

      });
      
    }

    return request.then((response) {

      if( response.statusCode == 200 ) {

        setState(() {
          
          /// Get the response body
          final responseBody = jsonDecode(response.body);

          /// Determine if we have any orders
          hasOrders = responseBody['total'] > 0;

        });
        
      }

      return response;

    });
  }

  /// The selected order content to show before the search bar
  Widget contentBeforeSearchBar(bool isLoading, int totalOrders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        /// Show the selected order summary
        if(isViewingOrder) selectedOrderContent,

      ],
    );
  }

  /// The selected order content to show
  Widget get selectedOrderContent {

    /**
     *  If the store is not provided, then get the store directly from the order that is provided.
     *  The store extracted from the order is eager loaded on the selected order. This scenerio
     *  occurs when we click on the "View All" to launch the modal bottom sheet to show the
     *  orders. In this case the store cannot be specified since we are requesting orders
     *  of the user regardless of the store. Knowing this, we eager load the associated
     *  store on each order so that we can then capture that nested store.
     */
    final ShoppableStore store = this.store ?? order!.relationships.store!;

    /// Instruction (On viewing a specific orderer)
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    
        /// Selected Order Content
        /// ----------------------
        /// The "key" allows the OrderContent widget to re-render after
        /// selecting another order via the ListTile onTap() method
        OrderContent(
          store: store,
          order: order!,
          key: ValueKey(order?.id),
          onUpdatedOrder: onUpdatedOrder
        ),
    
        /// Customer Related Order Content
        if(hasOrders) ...[
    
          /// Divider
          const Divider(height: 0,),
    
          /// Spacer
          const SizedBox(height: 16,),
    
          /// Title
          const CustomTitleSmallText(
            'Other orders',
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          ),
    
          /// Divider
          const Divider(height: 16,),
    
        ],

        /// Spacer
        if(!hasOrders) const SizedBox(height: 16,),
    
      ],
    );
  
  }
  
  @override
  Widget build(BuildContext context) {

    return CustomVerticalListViewInfiniteScroll(
      debounceSearch: true,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      showNoContent: isViewingOrders,
      catchErrorMessage: 'Can\'t show orders',
      showFirstRequestLoader: isViewingOrders,
      contentBeforeSearchBar: contentBeforeSearchBar,
      key: _customVerticalListViewInfiniteScrollState,
      loaderMargin: const EdgeInsets.symmetric(vertical: 32),
      onRequest: (page, searchWord) => requestStoreOrders(page, searchWord),
      headerPadding: order == null ? const EdgeInsets.only(top: 40, bottom: 0, left: 16, right: 16) : const EdgeInsets.all(0)
    );
  }
}

class OrderItem extends StatefulWidget {
  
  final int index;
  final Order order;
  final List<Order> orders;
  final String? orderFilter;
  final ShoppableStore? store;
  final Function(Order) onViewOrder;
  final OrderContentView orderContentView;
  final Function() requestStoreOrderFilters;
  final GlobalKey<CustomVerticalInfiniteScrollState> customVerticalListViewInfiniteScrollState;

  const OrderItem({
    super.key,
    this.store,
    required this.order,
    required this.index,
    required this.orders,
    required this.orderFilter,
    required this.onViewOrder,
    required this.orderContentView,
    required this.requestStoreOrderFilters,
    required this.customVerticalListViewInfiniteScrollState,
  });

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {

  /// Indication of whether to make an Api Request to retrieve a fresh list 
  /// of the orders as soon as the Dialog Widget triggered by the 
  /// Dismissible Widget is closed
  bool refreshOrdersOnDismiss = false;

  int get index => widget.index;
  Order get order => widget.order;
  List<Order> get orders => widget.orders;
  ShoppableStore? get store => widget.store;
  bool get hasBeenSeen => totalViewsByTeam > 0;
  String? get orderFilter => widget.orderFilter;
  int get totalViewsByTeam => order.totalViewsByTeam;
  Function(Order) get onViewOrder => widget.onViewOrder;
  ShoppableStore? get storeFromOrder => order.relationships.store;
  OrderContentView get orderContentView => widget.orderContentView;
  String get customerName => OrderServices.getCustomerDiplayName(order);
  bool get isViewingOrder => widget.orderContentView == OrderContentView.viewingOrder;
  bool get isViewingOrders => widget.orderContentView == OrderContentView.viewingOrders;
  bool get canManageOrders => (store ?? storeFromOrder!).attributes.userStoreAssociation!.canManageOrders;
  UserOrderCollectionAssociation? get userOrderCollectionAssociation => order.attributes.userOrderCollectionAssociation;
  bool get isAssociatedAsFriend => userOrderCollectionAssociation != null && userOrderCollectionAssociation!.role == 'Friend';
  bool get isAssociatedAsCustomer => userOrderCollectionAssociation != null && userOrderCollectionAssociation!.role == 'Customer';

  String get orderFor => order.orderFor;
  bool get isOrderingForMe => orderFor == 'Me';
  int get orderForTotalFriends => order.orderForTotalFriends;
  bool get isOrderingForFriendsOnly => orderFor == 'Friends Only';
  bool get isOrderingForMeAndFriends => orderFor == 'Me And Friends';

  /// Set an indication that an Api Request to retrieve a fresh list
  /// of the orders must be initiated as soon as the Dialog Widget 
  /// triggered by the Dismissible Widget is closed
  void mustRefreshOrdersOnDismiss() {
    refreshOrdersOnDismiss = true;
  }

  /// Get the index of the item that matches this updated order.
  int getMatchingOrderIndex(Order order) {
    
    /// Notice that we deliberately are searching for an order by id and getting its index instead of using
    /// the index passed on the OrderItem Widget because whenever we use OrdersInHorizontalInfiniteScroll(), 
    /// the order that is being updated might not match the index of the item that was swiped to preview
    /// the multiple list of orders. The user could have swipped to a different order while on the
    /// OrdersInHorizontalInfiniteScroll() Widget of the Dialog Widget and updated another order 
    /// instead of the original order that was swiped to initiate the preview in the first place
    /// 
    /// This is possible as long as the "previewOrderMode" property is set to "PreviewOrderMode.multipleOrders"
    /// value while the OrdersInHorizontalInfiniteScroll() Widget is showing and the user swipes to another
    /// order and updates that order instead of the initial order.
    return orders.indexWhere((currOrder) => currOrder.id == order.id);

  }

  /// When the order relationships have been retrieved such as the "cart", then update 
  /// the order item on the list of orders retrieved from the Api Request
  void onRequestedOrderRelationships (Order order) {

    /// Get the index of the item matching the specified order
    int orderIndex = getMatchingOrderIndex(order);

    /// If we have the order index (must be greater than or equal to zero, since -1 means not found)
    if(orderIndex >= 0) {
        
      /// Update this item on the list
      widget.customVerticalListViewInfiniteScrollState.currentState!.updateItemAt(orderIndex, order);

    }

  }

  /// When the order has been updated, determine whether 
  /// 1) To close the Dialog and dismiss the order item
  /// 2) To close the Dialog but do not dismiss the order item 
  /// 
  /// Do not dismiss the order item when order filter matches the specified filter
  /// or when we are viewing a specific order, in which case we do not want to
  /// dismiss the orders that appear at the bottom as "Other orders by..."
  /// 
  void onUpdatedPreviewSingleOrder (order) {

    int orderIndex = getMatchingOrderIndex(order);

    /// Update this item on the list
    widget.customVerticalListViewInfiniteScrollState.currentState!.updateItemAt(orderIndex, order);

    /// If we have the  order index
    if(orderIndex >= 0) {

      /// If we are viewing all orders
      if(orderFilter == 'All') {

        /// Return false not to dismiss this order while closing the dialog
        Navigator.of(context).pop(false);

      /// If we are viewing filtered orders (filtered as waiting, on its way, e.t.c)
      }else{

        /// Check if the current order statuc matches the selected order filter
        final orderStatusMatchesFilter = orderFilter != null && orderFilter!.toLowerCase() == order.status.name.toLowerCase();

        /// If the updated order status is the same as the filter of orders we want to view
        /// or if we are viewing a specific order and updated an order on a list of orders
        /// that follow up after the specific order we are viewing
        if( orderStatusMatchesFilter || isViewingOrder ) {

          /// Return false not to dismiss this order while closing the dialog
          Navigator.of(context).pop(false);

        /// If the updated order status is not the same as the filter of orders we want to view 
        }else{

          /// Return true to dismiss this order while closing the dialog
          Navigator.of(context).pop(true);

        }

      }

    }

  }

  @override
  Widget build(BuildContext context) {

    return Dismissible(
      key: ValueKey<int>(widget.order.id),
      direction: DismissDirection.horizontal,
      onDismissed: (DismissDirection direction) {
        
        /// Get the total items left as we dismiss items
        final totalItemsLeft = widget.customVerticalListViewInfiniteScrollState.currentState!.removeItemAt(index);

        /// If we don't have any items left
        if(totalItemsLeft == 0) {

          /// Refresh the items by making an Api Request
          widget.customVerticalListViewInfiniteScrollState.currentState!.startRequest();

        }

      },
      confirmDismiss: (DismissDirection direction) async {
        
        /// Property to determine if we can dismiss this dismissible item
        bool? canDismiss;

        /// If we are swipping left to right
        if(direction == DismissDirection.startToEnd) {
        
          /// Show a Dialog of this Order
          canDismiss = await DialogUtility.showBlankDialog(
            context: context,
            content: OrdersInHorizontalInfiniteScroll(
              store: store,
              order: order,
              orderFilter: orderFilter,
              isViewingOrder: isViewingOrder,
              onUpdatedPreviewSingleOrder: onUpdatedPreviewSingleOrder,
              onRequestedOrderRelationships: onRequestedOrderRelationships,
              onUpdatedOnMultipleOrders: (_) => mustRefreshOrdersOnDismiss(),
            )
          );

        /// If we are swipping right to left
        }else {
        
          /// Show a Dialog of this Order with an automatic trigger to cancel this order (triggerCancel: true)
          canDismiss = await DialogUtility.showBlankDialog(
            context: context,
            content: OrdersInHorizontalInfiniteScroll(
              store: store,
              order: order,
              triggerCancel: true,
              orderFilter: orderFilter,
              isViewingOrder: isViewingOrder,
              onUpdatedPreviewSingleOrder: onUpdatedPreviewSingleOrder,
              onRequestedOrderRelationships: onRequestedOrderRelationships,
              onUpdatedOnMultipleOrders: (_) => mustRefreshOrdersOnDismiss(),
            )
          );

        }

        /// Determine if we can refresh the order items on dismiss.
        /// Refresh the order items whenever we updated the order while previewing multiple orders.
        /// This is possible as long as the "previewOrderMode" property is set to "PreviewOrderMode.multipleOrders"
        /// value while the OrdersInHorizontalInfiniteScroll() Widget is showing and the user swipes to another
        /// order and updates that order instead of the initial order.
        if(refreshOrdersOnDismiss) {

          widget.customVerticalListViewInfiniteScrollState.currentState!.startRequest();

          /// Reset the "refreshOrdersOnDismiss" property so that we can swipe another order to open a new Dialog
          /// and know that when it closes, we won't re-run the startRequest() method unnecessarily sicne it was
          /// set to "true" before.
          refreshOrdersOnDismiss = false;

        }else{

          /// Determine whether to Dismiss this item.
          /// This is possible as long as the "previewOrderMode" property is set to "PreviewOrderMode.singleOrder"
          /// value while the OrdersInHorizontalInfiniteScroll() Widget is showing and the user updates the 
          /// initial order only without tempering with any other order. If they temper any other order
          /// of the OrdersInHorizontalInfiniteScroll() widget, then "refreshOrdersOnDismiss = true"
          /// will prevent this logic from executing.
          if(canDismiss == true) {

            /// Request the store order filters
            widget.requestStoreOrderFilters();

            /// Return true to dismiss
            return true;

          }
          
        }

        /// Return false not to dismiss
        return false;

      },

      /// List Tile Background
      background: Container(
        color: Colors.grey.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment:  MainAxisAlignment.spaceBetween,
          children: const [

            /// Check Mark
            Icon(Icons.check_circle_rounded, color: Colors.green),
            
            /// Cancel Mark
            Icon(Icons.remove_circle_rounded, color: Colors.red)
          
          ],
        ),
      ),
      
      /// ListTile
      child: ListTile(
          dense: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          onTap: () {

            /// If we are viewing a specific order
            if(isViewingOrder) {

              /// Scroll to top since we tapped on an order listed below the current
              /// selected order were orders appear listed as "Other orders by..."
              widget.customVerticalListViewInfiniteScrollState.currentState!.scrollController.animateTo( 
                0,
                curve:Curves.fastOutSlowIn,
                duration: const Duration(milliseconds: 500),
              );

            }

            /// View order
            onViewOrder(widget.order);

          },
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              /// Store Logo (If the order has a nested store relationship)
              if(storeFromOrder != null) ...[
                
                StoreLogo(store: storeFromOrder!),

                const SizedBox(width: 8,),

              ],

              /// Order
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              
                    /// If we are viewing mulitple orders (show customer name)
                    if(isViewingOrders) RichText(text: TextSpan(
              
                      /// Customer Name (John Doe)
                      text: customerName,
                      style: Theme.of(context).textTheme.titleMedium,
                      children: [
              
                        /// Me And Friends (+ 3 friends)
                        if(isOrderingForMeAndFriends) TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.grey,
                          ),
                          text: '  +$orderForTotalFriends ${orderForTotalFriends == 1 ? 'friend' : 'friends'}'
                        ),
              
                        /// Friends Only (for 3 people)
                        if(isOrderingForFriendsOnly) TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.grey
                          ),
                          text: '  for $orderForTotalFriends ${orderForTotalFriends == 1 ? 'friend' : 'friends'}'
                        )
              
                      ]
                    )),
              
                    /// Spacer
                    const SizedBox(height:  4,),
              
                    /// Status
                    OrderStatus(
                      lightShade: true,
                      status: widget.order.status.name,
                    ),
              
                    /// Summary
                    CustomBodyText(widget.order.summary, margin: const EdgeInsets.only(top: 4),),
              
                  ],
                ),
              ),
            ],
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              
              /// Created At
              CustomBodyText(timeago.format(widget.order.createdAt, locale: 'en_short')),
                  
              /// Order Number
              if(isAssociatedAsCustomer || isAssociatedAsFriend || canManageOrders) CustomBodyText('#${widget.order.attributes.number}', lightShade: true, margin: const EdgeInsets.only(top: 4),),

              /// If this order has been seen by the store team members (show the following widgets)
              if(hasBeenSeen) ...[

                /// Spacer
                const SizedBox(height: 4,),

                /// Seen Icon
                Icon(FontAwesomeIcons.circleDot, color: Colors.blue.shade700, size: 12,)
              
              ]
            
            ],
          ),
        ),
    );
  }
}