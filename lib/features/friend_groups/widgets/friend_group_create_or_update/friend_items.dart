import 'package:perfect_order/core/shared_models/user.dart';
import 'package:flutter/material.dart';
import 'friend_item.dart';

class FriendItems extends StatefulWidget {
  
  final List<User> users;
  final Function(User) onRemoveFriends;

  const FriendItems({
    super.key, 
    required this.users,
    required this.onRemoveFriends
  });

  @override
  State<FriendItems> createState() => _FriendItemsState();
}

class _FriendItemsState extends State<FriendItems> {

  int get totalItems => users.length;
  List<User> get users => widget.users;

  void onRemoveFriends(User user) {
    widget.onRemoveFriends(user);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: ListView.separated(
          shrinkWrap: true,
          itemCount: totalItems,
          key: ValueKey(totalItems),
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          itemBuilder: ((context, index) {

            final User user = users[index];

            return FriendItem(
              user: user,
              onRemoveFriends: onRemoveFriends
            );

          }
        )
      ),
    );
  }
}