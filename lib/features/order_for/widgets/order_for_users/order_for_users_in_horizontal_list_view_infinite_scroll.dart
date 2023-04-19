import 'package:bonako_demo/core/shared_widgets/infinite_scroll/custom_horizontal_list_view_infinite_scroll.dart';
import 'package:bonako_demo/core/shared_widgets/chips/custom_choice_chip.dart';
import '../../../friend_groups/models/friend_group.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../../../core/shared_models/user.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class OrderForUsersInHorizontalListViewInfiniteScroll extends StatefulWidget {
  
  final ShoppableStore store;
  final Function(User) onSelectedUser;

  const OrderForUsersInHorizontalListViewInfiniteScroll({
    super.key,
    required this.store,
    required this.onSelectedUser,
  });

  @override
  State<OrderForUsersInHorizontalListViewInfiniteScroll> createState() => _OrderForUsersInHorizontalListViewInfiniteScrollState();
}

class _OrderForUsersInHorizontalListViewInfiniteScrollState extends State<OrderForUsersInHorizontalListViewInfiniteScroll> {

  int? selectedUserId;
  String get orderFor => store.orderFor;
  List<User> get friends => store.friends;
  ShoppableStore get store => widget.store;
  List<FriendGroup> get friendGroups => store.friendGroups;
  Function(User) get onSelectedUser => widget.onSelectedUser;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  void _onSelectedUser(User user) {

    /**
     *  The Future.delayed is used to prevent the following error:
     * 
     *  This OrderForUsersInHorizontalListViewInfiniteScroll widget cannot be marked as needing to 
     *  build because the framework is already in the process of building widgets. A widget can be 
     *  marked as needing to be built during the build phase only if one of its ancestors is 
     *  currently building. This exception is allowed because the framework builds parent 
     *  widgets before children, which means a dirty descendant will always be built. 
     *  Otherwise, the framework might not visit this widget during this build phase.
     */
    Future.delayed(Duration.zero, () {

      /// Notify parent on selected user
      onSelectedUser(user);

      setState(() {
        
        /// Set selected first user
        selectedUserId = user.id;

      });

    });

  }

  /// Render each request item as an UserItem
  Widget onRenderItem(user, int index, List users) {

    /// If selected user is null, select first user
    if(selectedUserId == null && index == 0) {

      /// Set the first user as selected
      _onSelectedUser(user);

    }

    /// Check if user is selected
    final bool isSelected = selectedUserId == user.id;

    /// Render user item
    return UserItem(user: (user as User), index: index, isSelected: isSelected, onSelectedUser: _onSelectedUser);

  }
  
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
    return CustomHorizontalListViewInfiniteScroll(
      height: 32,
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
  final bool isSelected;
  final Function(User) onSelectedUser;

  const UserItem({
    super.key, 
    required this.user, 
    required this.index,
    required this.isSelected,
    required this.onSelectedUser
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      child: CustomChoiceChip(
        selected: isSelected,
        key: ValueKey<int>(user.id),
        label: user.attributes.name,
        selectedColor: Colors.green.shade700,
        onSelected: (bool selected) {
          if(selected) {
            onSelectedUser(user);
          }
        },
      ),
    );
  }
}