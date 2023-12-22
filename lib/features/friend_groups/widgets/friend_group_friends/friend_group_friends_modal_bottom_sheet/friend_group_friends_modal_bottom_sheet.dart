import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../core/shared_widgets/button/custom_text_button.dart';
import '../friend_group_friends_content.dart';
import '../../../models/friend_group.dart';
import 'package:flutter/material.dart';

class FriendGroupFriendsModalBottomSheet extends StatefulWidget {

  final FriendGroup friendGroup;
  final Function()? onInvitedMembers;
  final Function()? onRemovedMembers;
  final String? friendGroupMemberFilter;
  final Widget Function(Function())? trigger;

  const FriendGroupFriendsModalBottomSheet({
    super.key,
    this.trigger,
    this.onInvitedMembers,
    this.onRemovedMembers,
    required this.friendGroup,
    this.friendGroupMemberFilter,
  });

  @override
  State<FriendGroupFriendsModalBottomSheet> createState() => FriendGroupFriendsModalBottomSheetState();
}

class FriendGroupFriendsModalBottomSheetState extends State<FriendGroupFriendsModalBottomSheet> {

  FriendGroup get friendGroup => widget.friendGroup;
  Widget Function(Function())? get trigger => widget.trigger;
  Function()? get onInvitedMembers => widget.onInvitedMembers;
  Function()? get onRemovedMembers => widget.onRemovedMembers;
  String? get friendGroupMemberFilter => widget.friendGroupMemberFilter;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    Widget defaultTrigger = CustomTextButton(
      'Friends',
      alignment: Alignment.center,
      onPressed: openBottomModalSheet,
    );

    return trigger == null ? defaultTrigger : trigger!(openBottomModalSheet);
  
  }

  /// Open the bottom modal sheet
  void openBottomModalSheet() {
    if(_customBottomModalSheetState.currentState != null) {
      _customBottomModalSheetState.currentState!.showBottomSheet(context);
    } 
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      key: _customBottomModalSheetState,
      /// Trigger to open the bottom modal sheet
      trigger: _trigger,
      /// Content of the bottom modal sheet
      content: FriendGroupFriendsContent(
        friendGroup: friendGroup,
        onInvitedMembers: onInvitedMembers,
        onRemovedMembers: onRemovedMembers,
        friendGroupMemberFilter: friendGroupMemberFilter
      ),
    );
  }
}