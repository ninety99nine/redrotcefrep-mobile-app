import '../../../../friend_groups/models/friend_group.dart';
import '../../../../stores/providers/store_provider.dart';
import '../../../../stores/models/shoppable_store.dart';
import '../../../../../core/shared_models/user.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../users_content.dart';

class UsersPage extends StatefulWidget {

  static const routeName = 'UsersPage';
  
  final String orderFor;
  final List<User> friends;
  final List<FriendGroup> friendGroups;

  const UsersPage({
    super.key,
    required this.friends,
    required this.orderFor,
    required this.friendGroups,
  });

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {

  String get orderFor => widget.orderFor;
  List<User> get friends => widget.friends;
  ShoppableStore get store => storeProvider.store!;
  List<FriendGroup> get friendGroups => widget.friendGroups;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UsersContent(
        store: store,
        friends: friends,
        orderFor: orderFor,
        showingFullPage: true,
        friendGroups: friendGroups,
      ),
    );
  }
}