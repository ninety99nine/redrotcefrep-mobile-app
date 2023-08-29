import 'package:bonako_demo/features/orders/widgets/order_show/components/order_payment/order_request_payment/order_request_payment_button.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/profile/profile_right_side/store_dialer.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/profile/profile_left_side/store_name.dart';
import 'package:bonako_demo/features/orders/widgets/orders_show/orders_modal_bottom_sheet/orders_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_other_associated_friends.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_customer_display_name.dart';
import '../../../../core/shared_widgets/infinite_scroll/custom_horizontal_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_payment_status.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_created_at.dart';
import '../../../stores/widgets/store_cards/store_card/primary_section_content/store_logo.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_occasion.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_number.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import '../../../friend_groups/providers/friend_group_provider.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../core/shared_widgets/cards/custom_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../friend_groups/models/friend_group.dart';
import '../../../stores/models/shoppable_store.dart';
import '../order_show/components/order_status.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../models/order.dart';
import 'dart:convert';

class FriendGroupOrdersInHorizontalListViewInfiniteScroll extends StatefulWidget {
  
  final FriendGroup friendGroup;
  final Widget? noContentWidget;

  const FriendGroupOrdersInHorizontalListViewInfiniteScroll({
    Key? key,
    this.noContentWidget,
    required this.friendGroup,
  }) : super(key: key);

  @override
  State<FriendGroupOrdersInHorizontalListViewInfiniteScroll> createState() => FriendGroupOrdersInHorizontalListViewInfiniteScrollState();
}

class FriendGroupOrdersInHorizontalListViewInfiniteScrollState extends State<FriendGroupOrdersInHorizontalListViewInfiniteScroll> {

  bool hasOrders = false;
  FriendGroup get friendGroup => widget.friendGroup;
  Widget? get noContentWidget => widget.noContentWidget;
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);
  final GlobalKey<CustomHorizontalInfiniteScrollState> customHorizontalInfiniteScrollState = GlobalKey<CustomHorizontalInfiniteScrollState>();


  @override
  void didUpdateWidget(covariant FriendGroupOrdersInHorizontalListViewInfiniteScroll oldWidget) {

    super.didUpdateWidget(oldWidget);

    /// If the friend group id has changed.
    /// This happends if we are switching the friend group
    if(friendGroup.id != oldWidget.friendGroup.id) {

      /// Start a new request (so that we can filter orders by the specified friend group id)
      startRequest();

    }

  }

  void startRequest() {
    if(customHorizontalInfiniteScrollState.currentState != null) {
      customHorizontalInfiniteScrollState.currentState!.startRequest();
    }
  }

  /// Render each request item as an OrderItem
  Widget onRenderItem(order, int index, List orders) => OrderItem(
    order: (order as Order),
    index: index,
    friendGroup: friendGroup,
  );

  /// Render each request item as an Order
  Order onParseItem(order) => Order.fromJson(order);
  Future<http.Response> requestFriendGroupOrders(int page, String searchWord) {

    return friendGroupProvider.setFriendGroup(friendGroup).friendGroupRepository.showFriendGroupOrders(
      searchWord: searchWord,
      withOccasion: true,
      withStore: true,
      page: page
    ).then((response) {

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

  Widget get _noContentWidget {
    return noContentWidget ?? Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.access_time_outlined, size: 24, color: Colors.grey.shade300,),
        const SizedBox(width: 8,),
        const CustomBodyText(
          'No orders placed',
          lightShade: true
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {

    return CustomHorizontalListViewInfiniteScroll(
      height: 200,
      showSearchBar: false,
      debounceSearch: true,
      showNoMoreContent: false,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      showFirstRequestLoader: false,
      noContentWidget: _noContentWidget,
      headerPadding: const EdgeInsets.all(0),
      catchErrorMessage: 'Can\'t show orders',
      key: customHorizontalInfiniteScrollState,
      margin: const EdgeInsets.symmetric(vertical: 16),
      loaderMargin: const EdgeInsets.symmetric(vertical: 16),
      listPadding: const EdgeInsets.symmetric(horizontal: 16),
      onRequest: (page, searchWord) => requestFriendGroupOrders(page, searchWord),
    );
  }
}

class OrderItem extends StatefulWidget {
  
  final FriendGroup friendGroup;
  final int index;
  final Order order;

  const OrderItem({
    super.key,
    required this.friendGroup,
    required this.index,
    required this.order,
  });

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {

  int get index => widget.index;
  Order get order => widget.order;
  bool get hasBeenSeen => totalViewsByTeam > 0;
  bool get hasOccasion => order.occasionId != null;
  int get totalViewsByTeam => order.totalViewsByTeam;
  ShoppableStore get store => order.relationships.store!;
  bool get orderForManyPeople => order.orderForTotalUsers > 1;

  int get summaryMaxLines {
    if(hasOccasion && orderForManyPeople) {
      return 1;
    }else if(hasOccasion || orderForManyPeople) {
      return 2;
    }else {
      return 3;
    }
  }

  @override
  Widget build(BuildContext context) {

    return OrdersModalBottomSheet(
      store: store,
      canShowFloatingActionButton: false,
      trigger: (openBottomModalSheet) => Container(
        margin: const EdgeInsets.only(right: 8),
        width: MediaQuery.of(context).size.width * 0.8,
        child: CustomCard(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
    
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                      
                  /// Order Number
                  OrderNumber(order: order, showPrefix: false, orderNumberSize: OrderNumberSize.small),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                      /// Order Customer Display Name
                      OrderCustomerDisplayName(order: order),
                        
                      /// Group Icon (Indication Of A Shared Order)
                      if(orderForManyPeople) ...[
                        
                        /// Spacer
                        const SizedBox(height: 4,),
                            
                        /// Order Other Associated Friends
                        OrderOtherAssociatedFriends(order: order),

                      ],
                        
                      /// Group Icon (Indication Of A Shared Order)
                      if(orderForManyPeople) ...[
                        
                        /// Spacer
                        const SizedBox(height: 4,),
        
                        /// Payment Status
                        OrderOccasion(order: order),

                      ],

                    ],
                  )
    
                ],
              ),
    
              /// Spacer
              const SizedBox(height: 8,),
    
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  /// Summary
                  Expanded(child: CustomBodyText(order.summary, maxLines: summaryMaxLines, overflow: TextOverflow.ellipsis)),
    
                  /// Spacer
                  const SizedBox(width: 4,),
    
                  /// Seen Icon
                  if(hasBeenSeen) Icon(FontAwesomeIcons.circleDot, color: Colors.blue.shade700, size: 12,)

                ],
              ),
    
              /// Spacer
              const SizedBox(height: 4,),
    
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
    
                  Row(
                    children: [
        
                      /// Status
                      OrderStatus(order: order, lightShade: true,),
      
                      /// Spacer
                      const SizedBox(width:  8,),
        
                      /// Payment Status
                      OrderPaymentStatus(order: order, lightShade: true,),
      
                      /// Spacer
                      const SizedBox(width:  8,),

                    ],
                  ),
    
                  /// Created At
                  OrderCreatedAt(order: order, short: true),

                ],
              ),

              /// Spacer
              const Spacer(),
    
              GestureDetector(
                onTap: () {
                  
                  /// Navigate to the store page 
                  StoreServices.navigateToStorePage(store);
    
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                        
                    //  Store Logo
                    StoreLogo(store: store, radius: 16,),
              
                    /// Spacer
                    const SizedBox(width: 8,),

                    Expanded(
                      child: Row(
                        children: [
                    
                          /// Store Name
                          Expanded(child: StoreName(store: store)),

                          Row(
                            children: [

                              /// Request Payment Button / Pay Now Button
                              OrderRequestPaymentButton(
                                order: order,
                                orderRequestPaymentButtonType: OrderRequestPaymentButtonType.icon
                              ),

                              /// Store Dialer
                              StoreDialer(store: store),
                        
                            ],
                          )
                    
                        ],
                      ),
                    )
              
                  ],
                )
              )
    
            ],
          ),
        ),
      ),
    );

  }
}