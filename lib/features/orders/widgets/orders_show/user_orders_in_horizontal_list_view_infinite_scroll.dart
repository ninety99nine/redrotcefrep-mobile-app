import 'package:bonako_demo/features/orders/widgets/order_show/components/order_payment/order_request_payment/order_request_payment_button.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/profile/profile_right_side/store_dialer.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/profile/profile_left_side/store_name.dart';
import 'package:bonako_demo/features/orders/widgets/orders_show/orders_modal_bottom_sheet/orders_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/store_logo.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_other_associated_friends.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_customer_display_name.dart';
import '../../../../core/shared_widgets/infinite_scroll/custom_horizontal_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_payment_status.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_created_at.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_occasion.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_number.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_text_button.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../../core/shared_widgets/cards/custom_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../order_show/components/order_status.dart';
import '../../../user/providers/user_provider.dart';
import '../../../../core/shared_models/user.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import '../../models/order.dart';
import 'dart:convert';

class UserOrdersInHorizontalListViewInfiniteScroll extends StatefulWidget {
  
  final User user;
  final ShoppableStore? store;

  const UserOrdersInHorizontalListViewInfiniteScroll({
    Key? key,
    this.store,
    required this.user,
  }) : super(key: key);

  @override
  State<UserOrdersInHorizontalListViewInfiniteScroll> createState() => UserOrdersInHorizontalListViewInfiniteScrollState();
}

class UserOrdersInHorizontalListViewInfiniteScrollState extends State<UserOrdersInHorizontalListViewInfiniteScroll> {

  int totalOrders = 0;
  User get user => widget.user;
  ShoppableStore? get store => widget.store;
  UserProvider get userProvider => Provider.of<UserProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  /// Render each request item as an OrderItem
  Widget onRenderItem(order, int index, List orders) => OrderItem(
    order: (order as Order),
    store: store,
    index: index,
    user: user,
  );

  /// Render each request item as an Order
  Order onParseItem(order) => Order.fromJson(order);
  Future<dio.Response> requestUserOrders(int page, String searchWord) {

    Future<dio.Response> request;

    /// Get the orders of the users from any store or a specific store
    request = userProvider.setUser(user).userRepository.showOrders(
      withStore: store == null ? true : false,
      searchWord: searchWord,
      withOccasion: true,
      storeId: store?.id,
      page: page
    );

    return request.then((response) {

      if( response.statusCode == 200 ) {

        setState(() {

          /// Get the total orders
          totalOrders = response.data['total'];

        });
        
      }

      return response;

    });
  }

  Widget get contentBeforeSearchBar {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [

            /// Title
            CustomTitleSmallText('My Orders'),

            /// Spacer
            SizedBox(height: 4,),

            /// Subtitle
            CustomBodyText('See orders placed by you and friends', lightShade: true,),

          ],
        ),

        /// View All Button (Show if we have 2 or more orders)
        AnimatedSwitcher(
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
          child: totalOrders > 2 ? OrdersModalBottomSheet(
            trigger: (openBottomModalSheet) => const CustomTextButton('View All', padding: EdgeInsets.all(0),),
          ) : null,
        )

      ],
    );
  }

  Widget get noContentWidget {
    return Container(
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
      noContentWidget: noContentWidget,
      catchErrorMessage: 'Can\'t show orders',
      contentBeforeSearchBar: contentBeforeSearchBar,
      margin: const EdgeInsets.symmetric(vertical: 16),
      loaderMargin: const EdgeInsets.symmetric(vertical: 16),
      listPadding: const EdgeInsets.symmetric(horizontal: 16),
      onRequest: (page, searchWord) => requestUserOrders(page, searchWord),
      headerPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
    );
  }
}

class OrderItem extends StatefulWidget {
  
  final User user;
  final int index;
  final Order order;
  final ShoppableStore? store;

  const OrderItem({
    super.key,
    this.store,
    required this.user,
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
  bool get orderForManyPeople => order.orderForTotalUsers > 1;
  ShoppableStore get store => widget.store ?? order.relationships.store!;

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