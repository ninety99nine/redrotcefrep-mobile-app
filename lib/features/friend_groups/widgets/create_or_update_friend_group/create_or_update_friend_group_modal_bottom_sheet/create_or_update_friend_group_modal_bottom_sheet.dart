import 'package:perfect_order/features/friend_groups/widgets/create_or_update_friend_group/create_or_update_friend_group_content.dart';
import '../../../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import 'package:perfect_order/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:perfect_order/features/friend_groups/models/friend_group.dart';
import 'package:flutter/material.dart';

class CreateOrUpdateFriendGroupModalBottomSheet extends StatefulWidget {
  
  final String? title;
  final String? subtitle;
  final FriendGroup? friendGroup;
  final Widget Function(Function())? trigger;
  final void Function(FriendGroup)? onCreatedFriendGroup;
  final void Function(FriendGroup)? onUpdatedFriendGroup;
  final void Function(FriendGroup)? onDeletedFriendGroup;

  const CreateOrUpdateFriendGroupModalBottomSheet({
    super.key,
    this.title,
    this.trigger,
    this.subtitle,
    this.friendGroup,
    this.onCreatedFriendGroup,
    this.onUpdatedFriendGroup,
    this.onDeletedFriendGroup,
  });

  @override
  State<CreateOrUpdateFriendGroupModalBottomSheet> createState() => CreateOrUpdateFriendGroupModalBottomSheetState();
}

class CreateOrUpdateFriendGroupModalBottomSheetState extends State<CreateOrUpdateFriendGroupModalBottomSheet> {

  String? get title => widget.title;
  String? get subtitle => widget.subtitle;
  FriendGroup? get friendGroup => widget.friendGroup;
  Widget Function(Function())? get trigger => widget.trigger;
  Function(FriendGroup)? get onCreatedFriendGroup => widget.onCreatedFriendGroup;
  Function(FriendGroup)? get onUpdatedFriendGroup => widget.onUpdatedFriendGroup;
  Function(FriendGroup)? get onDeletedFriendGroup => widget.onDeletedFriendGroup;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    Widget defaultTrigger = CustomElevatedButton('Create Group', onPressed: openBottomModalSheet);

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
      content: CreateOrUpdateFriendGroupContent(
        title: title,
        subtitle: subtitle,
        friendGroup: friendGroup,
        onCreatedFriendGroup: onCreatedFriendGroup,
        onUpdatedFriendGroup: onUpdatedFriendGroup,
        onDeletedFriendGroup: onDeletedFriendGroup
      ),
    );
  }
}