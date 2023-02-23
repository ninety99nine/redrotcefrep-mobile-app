import 'package:bonako_demo/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/logo.dart';
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

  const UserOrdersInHorizontalListViewInfiniteScroll({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<UserOrdersInHorizontalListViewInfiniteScroll> createState() => UserOrdersInHorizontalListViewInfiniteScrollState();
}

class UserOrdersInHorizontalListViewInfiniteScrollState extends State<UserOrdersInHorizontalListViewInfiniteScroll> {

  bool hasOrders = false;
  User get user => widget.user;
  UserProvider get userProvider => Provider.of<UserProvider>(context, listen: false);

  /// Render each request item as an OrderItem
  Widget onRenderItem(order, int index, List orders) => OrderItem(
    order: (order as Order),
    index: index,
    user: user,
  );

  /// Render each request item as an Order
  Order onParseItem(order) => Order.fromJson(order);
  Future<http.Response> requestUserOrders(int page, String searchWord) {

    return userProvider.setUser(user).userRepository.showOrders(
      searchWord: searchWord,
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

  Widget get contentBeforeSearchBar {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: const [
        CustomTitleSmallText('My Orders'),
        SizedBox(height: 4,),
        CustomBodyText('See orders placed by you and friends', lightShade: true,),
      ],
    );
  }

  Widget get noContentWidget {
    return Row(
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
      height: 170,
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

  const OrderItem({
    super.key,
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
  ShoppableStore get store => order.relationships.store!;
  int get totalViewsByTeam => widget.order.totalViewsByTeam;

  @override
  Widget build(BuildContext context) {

    return Container(
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
                CustomTitleMediumText('#${widget.order.attributes.number}'),

                /// Created At
                CustomBodyText(timeago.format(widget.order.createdAt, locale: 'en_short')),

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
                  status: widget.order.status.name,
                ),

                /// Seen Icon
                if(hasBeenSeen) Icon(FontAwesomeIcons.circleDot, color: Colors.blue.shade700, size: 12,)

              ],
            ),

            /// Spacer
            const SizedBox(height: 8,),

            /// Summary
            CustomBodyText(widget.order.summary, maxLines: 2, overflow: TextOverflow.ellipsis),

            /// Spacer
            const Spacer(),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
          
                //  Store Logo
                StoreLogo(store: store, radius: 16,),

                /// Spacer
                const SizedBox(width: 8,),

                /// Store Name
                CustomBodyText(store.name),

              ],
            )

          ],
        ),
      ),
    );

  }
}