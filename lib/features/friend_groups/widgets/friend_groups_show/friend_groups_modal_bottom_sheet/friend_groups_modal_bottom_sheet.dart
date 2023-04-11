import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../core/shared_widgets/button/custom_text_button.dart';
import '../../../../friend_groups/enums/friend_group_enums.dart';
import '../../../../friend_groups/models/friend_group.dart';
import 'package:flutter/material.dart';
import '../friend_groups_content.dart';

class FriendGroupsModalBottomSheet extends StatefulWidget {

  final Purpose purpose;
  final Widget? trigger;
  final bool enableBulkSelection;
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

  late Widget trigger;

  Purpose get purpose => widget.purpose;
  bool get enableBulkSelection => widget.enableBulkSelection;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  @override
  void initState() {
    super.initState();
    
    /// If we have a custom trigger widget
    if(widget.trigger != null) {

      /// Set the custom trigger widget
      trigger = widget.trigger!;

    /// If we don't have a custom trigger widget
    } else {
      
      /// Set the default trigger widget
      trigger = CustomTextButton(
        'Change',
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
      content: FriendGroupsContent(
        purpose: purpose,
        enableBulkSelection: enableBulkSelection,
        onSelectedFriendGroups: widget.onSelectedFriendGroups,
        onDoneSelectingFriendGroups: widget.onDoneSelectingFriendGroups
      ),
    );
  }
}