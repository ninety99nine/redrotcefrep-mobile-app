import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import '../../../../core/shared_widgets/message_alert/custom_message_alert.dart';
import '../../../../core/shared_models/user_order_view_association.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../stores/services/store_services.dart';
import '../../../../../core/shared_models/user.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../models/order.dart';

class OrderViewers extends StatefulWidget {

  final Order order;
  final ShoppableStore store;

  const OrderViewers({
    super.key,
    required this.order,
    required this.store,
  });

  @override
  State<OrderViewers> createState() => _OrderViewersState();
}

class _OrderViewersState extends State<OrderViewers> {

  Order get order => widget.order;
  ShoppableStore get store => widget.store;
  int get totalViewsByTeam => order.totalViewsByTeam;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  String get seenNumberOfTimesMessage => 'Seen $totalViewsByTeam ${totalViewsByTeam == 1 ? 'time' : 'times'} by ${store.name} team';

  Widget onRenderItem(user, int index, List users, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => Viewer(
    user: (user as User),
    store: store,
  );
  User onParseItem(user) => User.fromJson(user);
  Future<http.Response> requestShowViewers(int page, String searchWord) {
    return orderProvider.setOrder(order).orderRepository.showViewers(
      searchWord: searchWord,
      page: page
    );
  }

  Widget contentBeforeSearchBar(bool isLoading, int totalViewers) {

    /// Order #00001 viewers
    return Align(
      alignment: Alignment.topLeft,
      child: CustomBodyText(
        'Order #${order.attributes.number} viewers',
        margin: const EdgeInsets.only(top: 0, bottom: 24),
      ),
    );

  }

  Widget get contentAfterSearchBar {

    /// Seen # of times by store team
    return CustomMessageAlert(
      size: 20,
      seenNumberOfTimesMessage,
      icon: FontAwesomeIcons.circleDot,
      margin: const EdgeInsets.only(bottom: 24),
    );
    
  }

  @override
  Widget build(BuildContext context) {
    return CustomVerticalListViewInfiniteScroll(
      showSeparater: true,
      debounceSearch: true,
      onParseItem: onParseItem,
      onRenderItem: onRenderItem,
      catchErrorMessage: 'Can\'t show viewers',
      contentAfterSearchBar: contentAfterSearchBar,
      contentBeforeSearchBar: contentBeforeSearchBar,
      onRequest: (page, searchWord) => requestShowViewers(page, searchWord), 
      headerPadding: const EdgeInsets.only(top: 24, bottom: 0, left: 16, right: 16),
    );
  }
}

class Viewer extends StatelessWidget {
  
  final User user;
  final ShoppableStore store;

  const Viewer({
    super.key,
    required this.user,
    required this.store,
  });

  int get views => userOrderViewAssociation.views;
  DateTime get createdAt => userOrderViewAssociation.createdAt;
  DateTime get lastSeenAt => userOrderViewAssociation.lastSeenAt;
  bool get canManageOrders => store.attributes.userStoreAssociation!.canManageOrders;
  UserOrderViewAssociation get userOrderViewAssociation => user.attributes.userOrderViewAssociation!;
  bool get createdAtAndLastSeenAtIsNotTheSame => timeago.format(createdAt) != timeago.format(lastSeenAt);

  @override
  Widget build(BuildContext context) {

    return ListTile(
        dense: false,
        key: ValueKey<int>(user.id),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            /// User name
            CustomBodyText(user.attributes.name),
            
            /// Spacer
            const SizedBox(height: 8,),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                /// Seen icon
                Icon(FontAwesomeIcons.circleDot, color: Colors.blue.shade700, size: 12),
                
                /// Spacer
                const SizedBox(width: 4,),

                /// Views
                CustomBodyText('$views ${views == 1 ? 'view' : 'views'}'),
                
                /// Spacer
                if(canManageOrders) const SizedBox(width: 8,),
            
                /// Mobile Number
                if(canManageOrders) CustomBodyText(user.mobileNumber!.withoutExtension, lightShade: true,),
              
              ],
            )

          ],
        ),
        /// Last Interaction
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [

            /// Last Seen Text
            const CustomBodyText('last seen', lightShade: true,),

            /// Last Seen DateTime
            CustomBodyText(timeago.format(lastSeenAt)),
          
          ],
        )
      );
  }
}