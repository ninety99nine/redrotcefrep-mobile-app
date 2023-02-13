import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../core/shared_widgets/buttons/custom_text_button.dart';
import '../../../../friend_groups/models/friend_group.dart';
import 'package:flutter/material.dart';
import '../friend_groups_content.dart';

class FriendGroupsModalBottomSheet extends StatefulWidget {

  final bool enableBulkSelection;
  final Function(List<FriendGroup>)? onSelectedFriendGroups;

  const FriendGroupsModalBottomSheet({
    super.key,
    this.onSelectedFriendGroups,
    required this.enableBulkSelection,
  });

  @override
  State<FriendGroupsModalBottomSheet> createState() => _FriendGroupsModalBottomSheetState();
}

class _FriendGroupsModalBottomSheetState extends State<FriendGroupsModalBottomSheet> {

  bool get enableBulkSelection => widget.enableBulkSelection;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  /// Called when the friend groups are selected 
  void onSelectedFriendGroups(List<FriendGroup> friendGroups) {

    if(widget.onSelectedFriendGroups != null) {
        
      /// Notify parent on selected friends
      widget.onSelectedFriendGroups!(friendGroups);

    }

  }

  Widget get trigger {
    return CustomTextButton(
      'Change',
      onPressed: openBottomModalSheet,
    );
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
      content: FriendGroupsContent(
        enableBulkSelection: enableBulkSelection,
        onSelectedFriendGroups: onSelectedFriendGroups,
      ),
    );
  }
}