import 'package:bonako_demo/core/shared_models/cart.dart';

import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../friend_groups/models/friend_group.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../../../core/shared_models/user.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class OrderForUsersInVerticalListViewInfiniteScroll extends StatefulWidget {
  
  final ShoppableStore store;

  const OrderForUsersInVerticalListViewInfiniteScroll({
    super.key,
    required this.store,
  });

  @override
  State<OrderForUsersInVerticalListViewInfiniteScroll> createState() => _OrderForUsersInVerticalListViewInfiniteScrollState();
}

class _OrderForUsersInVerticalListViewInfiniteScrollState extends State<OrderForUsersInVerticalListViewInfiniteScroll> {

  String get orderFor => store.orderFor;
  List<User> get friends => store.friends;
  ShoppableStore get store => widget.store;
  List<FriendGroup> get friendGroups => store.friendGroups;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  /// Render each request item as an UserItem
  Widget onRenderItem(user, int index, List users, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => UserItem(user: (user as User), index: index);
  
  /// Render each request item as an User
  User onParseItem(user) => User.fromJson(user);
  Future<http.Response> requestShowShoppingCartOrderForUsers(int page, String searchWord) {
    return storeProvider.setStore(store).storeRepository.showShoppingCartOrderForUsers(
      page: page,
      friends: friends,
      orderFor: orderFor,
      searchWord: searchWord,
      friendGroups: friendGroups,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomVerticalListViewInfiniteScroll(
      debounceSearch: true,
      showNoMoreContent: false,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      catchErrorMessage: 'Can\'t show users',
      onRequest: (page, searchWord) => requestShowShoppingCartOrderForUsers(page, searchWord),
      headerPadding: const EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
    );
  }
}

class UserItem extends StatelessWidget {
  
  final User user;
  final int index;

  const UserItem({super.key, required this.user, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      key: ValueKey<int>(user.id),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),

      /// Name / Mobile Number
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          /// Spacer
          const SizedBox(width: 8,),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Name
              CustomTitleSmallText(user.attributes.name),

              /// Spacer
              const SizedBox(height: 4,),

              /// Mobile Number
              CustomBodyText(user.mobileNumber!.withoutExtension, lightShade: true),
              
              
            ],
          )
        ],
      )
      
    );
  }
}