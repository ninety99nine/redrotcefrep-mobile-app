
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';

import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import 'package:flutter/material.dart';
import '../menu_content.dart';

class MenuModalBottomSheet extends StatefulWidget {

  final ShoppableStore store;

  const MenuModalBottomSheet({
    super.key,
    required this.store
  });

  @override
  State<MenuModalBottomSheet> createState() => _MenuModalBottomSheetState();
}

class _MenuModalBottomSheetState extends State<MenuModalBottomSheet> {

  ShoppableStore get store => widget.store;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get trigger {

    return IconButton(
      onPressed: openBottomModalSheet, 
      padding: const EdgeInsets.all(4.0),
      constraints: const BoxConstraints(),
      icon: Icon(Icons.more_vert_rounded, size: 16, color: Colors.grey.shade400,)
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
      content: MenuContent(store: store),
    );
  }
}