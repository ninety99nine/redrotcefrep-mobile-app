import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../core/shared_widgets/button/custom_text_button.dart';
import '../../../models/shoppable_store.dart';
import 'package:flutter/material.dart';
import '../store_menu_content.dart';

class StoreMenuModalBottomSheet extends StatefulWidget {

  final ShoppableStore store;

  const StoreMenuModalBottomSheet({
    super.key,
    required this.store,
  });

  @override
  State<StoreMenuModalBottomSheet> createState() => _StoreMenuModalBottomSheetState();
}

class _StoreMenuModalBottomSheetState extends State<StoreMenuModalBottomSheet> {

  ShoppableStore get store => widget.store;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    return CustomTextButton(
      '',
      prefixIconSize: 20,
      color: Colors.grey.shade400,
      onPressed: openBottomModalSheet, 
      prefixIcon: Icons.more_vert_rounded
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
      trigger: _trigger,
      /// Content of the bottom modal sheet
      content: StoreMenuContent(store: store),
    );
  }
}