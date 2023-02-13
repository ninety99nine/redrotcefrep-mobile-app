import 'package:bonako_demo/core/shared_widgets/buttons/custom_text_button.dart';

import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../core/shared_widgets/buttons/custom_elevated_button.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../friend_groups/models/friend_group.dart';
import '../../../../../core/shared_models/user.dart';
import '../../../enums/friend_enums.dart';
import 'package:flutter/material.dart';
import '../friends_content.dart';

class FriendsModalBottomSheet extends StatefulWidget {

  final Purpose purpose;
  final Function(List<User>)? onSelectedFriends;
  final Function(List<User>)? onDoneSelectingFriends;
  final Function(List<FriendGroup>)? onSelectedFriendGroups;

  const FriendsModalBottomSheet({
    super.key,
    required this.purpose,
    this.onSelectedFriends,
    this.onSelectedFriendGroups,
    this.onDoneSelectingFriends,
  });

  @override
  State<FriendsModalBottomSheet> createState() => _FriendsModalBottomSheetState();
}

class _FriendsModalBottomSheetState extends State<FriendsModalBottomSheet> {

  Purpose get purpose => widget.purpose;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  /// Called when the friends are selected on each interaction
  void onSelectedFriends(List<User> friends) {

    if(widget.onSelectedFriends != null) {

      /// Notify parent on selected friends
      widget.onSelectedFriends!(friends);

    }

  }

  /// Called when the user is done selecting friends
  void onDoneSelectingFriends(List<User> friends) {

    if(widget.onDoneSelectingFriends != null) {

      /// Notify parent on selected friends
      widget.onDoneSelectingFriends!(friends);

    }

  }

  /// Called when the friend groups are selected 
  void onSelectedFriendGroups(List<FriendGroup> friendGroups) {

    if(widget.onSelectedFriendGroups != null) {
        
      /// Notify parent on selected friends
      widget.onSelectedFriendGroups!(friendGroups);

    }

  }

  Widget get trigger {

    /// If the purpose is to select friends for an order
    if(purpose == Purpose.addFriendsToOrder) {
      
      return const CustomBodyText('Friends');

    /// If the purpose is to select friends for a group
    }else{

      return CustomTextButton(
        'Add Friends',
        color: Colors.green,
        prefixIcon: Icons.add,
        alignment: Alignment.center,
        onPressed: openBottomModalSheet,
      );

    }
  }

  /// Open the bottom modal sheet to show the new order placed
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
      trigger: trigger,
      /// Content of the bottom modal sheet
      content: FriendsContent(
        purpose: purpose,
        onSelectedFriends: onSelectedFriends,
        onDoneSelectingFriends: onDoneSelectingFriends,
        onSelectedFriendGroups: onSelectedFriendGroups,
      ),
    );
  }
}