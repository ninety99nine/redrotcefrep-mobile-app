import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';

import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../core/shared_widgets/button/custom_text_button.dart';
import '../../../../friend_groups/enums/friend_group_enums.dart';
import '../../../../friend_groups/models/friend_group.dart';
import 'package:flutter/material.dart';
import '../friend_groups_content.dart';

class FriendGroupsModalBottomSheet extends StatefulWidget {

  final Purpose purpose;
  final bool enableBulkSelection;
  final Widget Function(Function())? trigger;
  final Function(List<FriendGroup>)? onSelectedFriendGroups;
  final Function(List<FriendGroup>)? onDoneSelectingFriendGroups;

  const FriendGroupsModalBottomSheet({
    super.key,
    this.trigger,
    required this.purpose,
    this.onSelectedFriendGroups,
    this.onDoneSelectingFriendGroups,
    required this.enableBulkSelection,
  });

  @override
  State<FriendGroupsModalBottomSheet> createState() => FriendGroupsModalBottomSheetState();
}

class FriendGroupsModalBottomSheetState extends State<FriendGroupsModalBottomSheet> {

  Purpose get purpose => widget.purpose;
  Widget Function(Function())? get trigger => widget.trigger;
  bool get enableBulkSelection => widget.enableBulkSelection;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    final Widget defaultTrigger = CustomElevatedButton(
      'Groups', 
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
      content: FriendGroupsContent(
        purpose: purpose,
        enableBulkSelection: enableBulkSelection,
        onSelectedFriendGroups: widget.onSelectedFriendGroups,
        onDoneSelectingFriendGroups: widget.onDoneSelectingFriendGroups
      ),
    );
  }
}