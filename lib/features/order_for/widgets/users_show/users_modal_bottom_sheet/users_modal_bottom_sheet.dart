import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../friend_groups/models/friend_group.dart';
import '../../../../stores/models/shoppable_store.dart';
import '../../../../../core/shared_models/user.dart';
import 'package:flutter/material.dart';
import '../users_content.dart';

class UsersModalBottomSheet extends StatefulWidget {
  
  final String orderFor;
  final List<User> friends;
  final ShoppableStore store;
  final List<FriendGroup> friendGroups;

  const UsersModalBottomSheet({
    super.key,
    required this.store,
    required this.friends,
    required this.orderFor,
    required this.friendGroups,
  });

  @override
  State<UsersModalBottomSheet> createState() => _UsersModalBottomSheetState();
}

class _UsersModalBottomSheetState extends State<UsersModalBottomSheet> {

  String get orderFor => widget.orderFor;
  List<User> get friends => widget.friends;
  ShoppableStore get store => widget.store;
  List<FriendGroup> get friendGroups => widget.friendGroups;

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      /// Trigger to open the bottom modal sheet
      trigger: const CustomBodyText('view', isLink: true,),
      /// Content of the bottom modal sheet
      content: UsersContent(
        store: store,
        friends: friends,
        orderFor: orderFor,
        friendGroups: friendGroups,
      ),
    );
  }
}