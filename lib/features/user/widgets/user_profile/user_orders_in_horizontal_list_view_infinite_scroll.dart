import 'package:bonako_demo/core/shared_models/user_and_order_association.dart';
import 'package:bonako_demo/core/shared_widgets/buttons/custom_text_button.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/orders/widgets/orders_show/orders_modal_bottom_sheet/orders_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/stores/enums/store_enums.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/stores/models/store.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/store_logo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/shared_widgets/infinite_scroll/custom_horizontal_list_view_infinite_scroll.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../../core/shared_widgets/cards/custom_card.dart';
import '../../../orders/widgets/order_show/order_status.dart';
import '../../../user/providers/user_provider.dart';
import '../../../../core/shared_models/user.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../orders/models/order.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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

  bool hasOrders = false;
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
  Future<http.Response> requestUserOrders(int page, String searchWord) {

    Future<http.Response> request;
    
    if(store == null) {

      /// Get the orders of the users from any store
      request = userProvider.setUser(user).userRepository.showOrders(
        withStore: store == null ? true : false,
        searchWord: searchWord,
        page: page
      );

    }else{

      /// Get the orders of the users from this specified store
      request = storeProvider.setStore(store!).storeRepository.showOrders(
        searchWord: searchWord,
        userId: user.id,
        page: page
      );

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

        /// View All Button
        const OrdersModalBottomSheet(
          trigger: CustomTextButton('View All', padding: EdgeInsets.all(0),),
        ),

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
      height: 175,
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
  int get totalViewsByTeam => order.totalViewsByTeam;
  bool get orderForManyPeople => order.orderForTotalUsers > 1;
  ShoppableStore get store => widget.store ?? order.relationships.store!;
  bool get isAssociatedAsFriend => userAndOrderAssociation.role == 'Friend';
  bool get isAssociatedAsCustomer => userAndOrderAssociation.role == 'Customer';
  UserAndOrderAssociation get userAndOrderAssociation => order.attributes.userAndOrderAssociation!;

  @override
  Widget build(BuildContext context) {

    return OrdersModalBottomSheet(
      store: store,
      order: order,
      canShowFloatingActionButton: false,
      trigger: Container(
        margin: const EdgeInsets.only(right: 8),
        width: MediaQuery.of(context).size.width * 0.8,
        child: CustomCard(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
    
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                      
                  /// Order Number
                  CustomTitleMediumText('#${order.attributes.number}'),

                  /// Order For
                  if(orderForManyPeople) Row(
                    children: [
                        
                      /// Group Icon (Indication Of A Shared Order)
                      Icon(Icons.group_outlined, color: Colors.grey.shade400, size: 20,),

                      /// Spacer
                      if(isAssociatedAsFriend) const SizedBox(width: 4,),
                      
                      /// Customer Name (The Person That Shared This Order)
                      if(isAssociatedAsFriend) CustomBodyText(order.customerFirstName, lightShade: true,),
                    
                    ],
                  ),
    
                ],
              ),
    
              /// Spacer
              const SizedBox(height:  4,),
    
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
    
                  /// Status
                  OrderStatus(
                    lightShade: true,
                    status: order.status.name,
                  ),
    
                  /// Created At
                  CustomBodyText(timeago.format(order.createdAt, locale: 'en_short'), lightShade: true,),

                ],
              ),
    
              /// Spacer
              const SizedBox(height: 8,),
    
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  /// Summary
                  Flexible(
                    child: CustomBodyText(order.summary, maxLines: 2, overflow: TextOverflow.ellipsis)
                  ),
    
                  /// Seen Icon
                  if(hasBeenSeen) Icon(FontAwesomeIcons.circleDot, color: Colors.blue.shade700, size: 12,)

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
              
                    /// Store Name
                    CustomBodyText(store.name),
              
                  ],
                ),
              )
    
            ],
          ),
        ),
      ),
    );

  }
}