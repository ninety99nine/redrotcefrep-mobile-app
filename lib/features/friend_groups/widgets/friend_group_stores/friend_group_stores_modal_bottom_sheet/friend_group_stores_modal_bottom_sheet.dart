import 'package:bonako_demo/features/friend_groups/widgets/friend_group_stores/friend_group_stores_content.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../core/shared_widgets/button/custom_text_button.dart';
import '../../../models/friend_group.dart';
import 'package:flutter/material.dart';

class FriendGroupStoresModalBottomSheet extends StatefulWidget {

  final FriendGroup friendGroup;
  final String? friendGroupStoreFilter;
  final Widget Function(Function())? trigger;
  final Function(ShoppableStore)? onAddedStore;
  final Function(List<ShoppableStore>)? onRemovedStores;

  const FriendGroupStoresModalBottomSheet({
    super.key,
    this.trigger,
    this.onAddedStore,
    this.onRemovedStores,
    required this.friendGroup,
    this.friendGroupStoreFilter,
  });

  @override
  State<FriendGroupStoresModalBottomSheet> createState() => FriendGroupStoresModalBottomSheetState();
}

class FriendGroupStoresModalBottomSheetState extends State<FriendGroupStoresModalBottomSheet> {

  FriendGroup get friendGroup => widget.friendGroup;
  Widget Function(Function())? get trigger => widget.trigger;
  Function(ShoppableStore)? get onAddedStore => widget.onAddedStore;
  String? get friendGroupStoreFilter => widget.friendGroupStoreFilter;
  Function(List<ShoppableStore>)? get onRemovedStores => widget.onRemovedStores;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    Widget defaultTrigger = CustomTextButton(
      'Stores',
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
      content: FriendGroupStoresContent(
        friendGroup: friendGroup,
        onAddedStore: onAddedStore,
        onRemovedStores: onRemovedStores,
        friendGroupStoreFilter: friendGroupStoreFilter
      ),
    );
  }
}