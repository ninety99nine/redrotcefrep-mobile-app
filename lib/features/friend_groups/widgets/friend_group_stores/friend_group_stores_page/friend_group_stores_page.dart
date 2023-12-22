import 'package:bonako_demo/features/friend_groups/widgets/friend_group_stores/friend_group_stores_content.dart';
import 'package:bonako_demo/features/friend_groups/models/friend_group.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendGroupStoresPage extends StatefulWidget {

  static const routeName = 'FriendGroupStoresPage';

  const FriendGroupStoresPage({super.key});

  @override
  State<FriendGroupStoresPage> createState() => _FriendGroupStoresPageState();
}

class _FriendGroupStoresPageState extends State<FriendGroupStoresPage> {
  
  late FriendGroup friendGroup;

  @override
  void initState() {
    
    super.initState();

    /// Get the route arguments
    final arguments = Get.arguments;

    /// Set the "friendGroup" (if provided)
    friendGroup = arguments['friendGroup'] as FriendGroup;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FriendGroupStoresContent(
        friendGroup: friendGroup
      ),
    );
  }
}