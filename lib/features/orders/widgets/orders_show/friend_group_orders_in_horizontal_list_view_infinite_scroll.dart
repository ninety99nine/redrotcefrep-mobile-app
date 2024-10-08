import 'package:perfect_order/core/shared_widgets/button/custom_text_button.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:perfect_order/core/utils/dialog.dart';
import 'package:perfect_order/features/orders/enums/order_enums.dart';
import 'package:perfect_order/features/orders/widgets/order_show/components/order_payment/order_request_payment/order_request_payment_button.dart';
import 'package:perfect_order/features/orders/widgets/order_show/order_content_by_type/order_content_by_type_dialog.dart';
import 'package:perfect_order/features/stores/widgets/store_cards/store_card/primary_section_content/profile/profile_right_side/store_dialer.dart';
import 'package:perfect_order/features/stores/widgets/store_cards/store_card/primary_section_content/profile/profile_left_side/store_name.dart';
import 'package:perfect_order/features/orders/widgets/orders_show/orders_modal_bottom_sheet/orders_modal_bottom_sheet.dart';
import 'package:perfect_order/features/orders/widgets/order_show/components/order_other_associated_friends.dart';
import 'package:perfect_order/features/orders/widgets/order_show/components/order_customer_display_name.dart';
import '../../../../core/shared_widgets/infinite_scroll/custom_horizontal_list_view_infinite_scroll.dart';
import 'package:perfect_order/features/orders/widgets/order_show/components/order_payment_status.dart';
import 'package:perfect_order/features/orders/widgets/order_show/components/order_created_at.dart';
import '../../../stores/widgets/store_cards/store_card/primary_section_content/store_logo.dart';
import 'package:perfect_order/features/orders/widgets/order_show/components/order_occasion.dart';
import 'package:perfect_order/features/orders/widgets/order_show/components/order_number.dart';
import 'package:perfect_order/features/stores/services/store_services.dart';
import '../../../friend_groups/providers/friend_group_provider.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../core/shared_widgets/cards/custom_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../friend_groups/models/friend_group.dart';
import '../../../stores/models/shoppable_store.dart';
import '../order_show/components/order_status.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import '../../models/order.dart';

class FriendGroupOrdersInHorizontalListViewInfiniteScroll extends StatefulWidget {
  
  final FriendGroup friendGroup;
  final Widget? noContentWidget;
  final OrderContentType orderContentType;
  final void Function(Order)? onUpdatedOrder;
  final UserOrderAssociation userOrderAssociation;

  const FriendGroupOrdersInHorizontalListViewInfiniteScroll({
    Key? key,
    this.onUpdatedOrder,
    this.noContentWidget,
    required this.friendGroup,
    required this.orderContentType,
    required this.userOrderAssociation,
  }) : super(key: key);

  @override
  State<FriendGroupOrdersInHorizontalListViewInfiniteScroll> createState() => FriendGroupOrdersInHorizontalListViewInfiniteScrollState();
}

class FriendGroupOrdersInHorizontalListViewInfiniteScrollState extends State<FriendGroupOrdersInHorizontalListViewInfiniteScroll> {

  int totalOrders = 0;
  FriendGroup get friendGroup => widget.friendGroup;
  Widget? get noContentWidget => widget.noContentWidget;
  OrderContentType get orderContentType => widget.orderContentType;
  void Function(Order)? get onUpdatedOrder => widget.onUpdatedOrder;
  UserOrderAssociation get userOrderAssociation => widget.userOrderAssociation;
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);
  final GlobalKey<CustomHorizontalInfiniteScrollState> _customHorizontalInfiniteScrollState = GlobalKey<CustomHorizontalInfiniteScrollState>();

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
    if(_customHorizontalInfiniteScrollState.currentState != null) {
      _customHorizontalInfiniteScrollState.currentState!.startRequest();
    }
  }

  void _onUpdatedOrder(Order updatedOrder, int index) {

    /// Notify parent widget on updated order
    if(onUpdatedOrder != null) onUpdatedOrder!(updatedOrder); 

    /// Update the order on the list of multiple orders
    _customHorizontalInfiniteScrollState.currentState!.updateItemAt(index, updatedOrder);

  }

  /// Render each request item as an OrderItem
  Widget onRenderItem(order, int index, List orders) => OrderItem(
    index: index,
    order: (order as Order),
    friendGroup: friendGroup,
    orderContentType: orderContentType,
    onUpdatedOrder: (Order updatedOrder) {
      _onUpdatedOrder(updatedOrder, index);
    },
    userOrderAssociation: userOrderAssociation,
  );

  /// Render each request item as an Order
  Order onParseItem(order) => Order.fromJson(order);
  Future<dio.Response> requestFriendGroupOrders(int page, String searchWord) {

    return friendGroupProvider.setFriendGroup(friendGroup).friendGroupRepository.showFriendGroupOrders(
      userOrderAssociation: userOrderAssociation,
      searchWord: searchWord,
      withOccasion: true,
      withStore: true,
      page: page
    ).then((response) {

      if( response.statusCode == 200 ) {

        setState(() {

          /// Get the total orders
          totalOrders = response.data['total'];

        });
        
      }

      return response;

    });
  }

  Widget _contentBeforeSearchBar(isLoading, totalItems) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [

            /// Title
            CustomTitleSmallText('Group Orders'),

            /// Spacer
            SizedBox(height: 4,),

            /// Subtitle
            CustomBodyText('See orders placed for this group', lightShade: true,),

          ],
        ),

        /// View All Button (Show if we have 2 or more orders)
        AnimatedSwitcher(
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
          child: totalOrders > 2 ? OrdersModalBottomSheet(
            userOrderAssociation: userOrderAssociation,
            trigger: (openBottomModalSheet) => const CustomTextButton('View All', padding: EdgeInsets.all(0),),
          ) : null,
        )

      ],
    );
  }

  Widget get _noContentWidget {
    return noContentWidget ?? Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.access_time_outlined, size: 24, color: Colors.grey.shade300,),
          const SizedBox(width: 8,),
          const CustomBodyText(
            'No orders placed', 
            lightShade: true
          ),
        ],
      ),
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
      catchErrorMessage: 'Can\'t show orders',
      key: _customHorizontalInfiniteScrollState,
      contentBeforeSearchBar: _contentBeforeSearchBar,
      margin: const EdgeInsets.symmetric(vertical: 16),
      loaderMargin: const EdgeInsets.symmetric(vertical: 16),
      listPadding: const EdgeInsets.symmetric(horizontal: 16),
      headerPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      onRequest: (page, searchWord) => requestFriendGroupOrders(page, searchWord),
    );
  }
}

class OrderItem extends StatefulWidget {
  
  final int index;
  final Order order;
  final FriendGroup friendGroup;
  final OrderContentType orderContentType;
  final void Function(Order)? onUpdatedOrder;
  final UserOrderAssociation userOrderAssociation;

  const OrderItem({
    super.key,
    required this.index,
    required this.order,
    required this.friendGroup,
    required this.onUpdatedOrder,
    required this.orderContentType,
    required this.userOrderAssociation,
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
  OrderContentType get orderContentType => widget.orderContentType;
  void Function(Order)? get onUpdatedOrder => widget.onUpdatedOrder;
  UserOrderAssociation get userOrderAssociation => widget.userOrderAssociation;

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

    return GestureDetector(
      onTap: () {

        DialogUtility.showInfiniteScrollContentDialog(
          context: context,
          heightRatio: 0.9,
          showCloseIcon: false,
          backgroundColor: Colors.transparent,
          content: OrderContentByTypeDialog(
            order: order,
            onUpdatedOrder: onUpdatedOrder,
            orderContentType: orderContentType
          )
        );

      },
      child: Container(
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