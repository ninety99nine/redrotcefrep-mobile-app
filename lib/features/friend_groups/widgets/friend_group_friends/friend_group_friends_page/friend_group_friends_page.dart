import 'package:bonako_demo/features/friend_groups/models/friend_group.dart';
import '../friend_group_friends_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendGroupFriendsPage extends StatefulWidget {

  static const routeName = 'FriendGroupFriendsPage';

  const FriendGroupFriendsPage({super.key});

  @override
  State<FriendGroupFriendsPage> createState() => _FriendGroupFriendsPageState();
}

class _FriendGroupFriendsPageState extends State<FriendGroupFriendsPage> {
  
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
      body: FriendGroupFriendsContent(
        friendGroup: friendGroup
      ),
    );
  }
}