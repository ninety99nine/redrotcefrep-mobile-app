import 'package:bonako_demo/core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import 'package:bonako_demo/core/shared_widgets/buttons/custom_text_button.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/stores/widgets/update_store/update_store_content.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class UpdateStoreModalBottomSheet extends StatefulWidget {

  final Widget? trigger;
  final ShoppableStore store;
  final Function(ShoppableStore)? onUpdatedStore;

  const UpdateStoreModalBottomSheet({
    super.key,
    this.trigger,
    this.onUpdatedStore,
    required this.store,
  });

  @override
  State<UpdateStoreModalBottomSheet> createState() => UpdateStoreModalBottomSheetState();
}

class UpdateStoreModalBottomSheetState extends State<UpdateStoreModalBottomSheet> {

  Widget? get trigger => widget.trigger;
  ShoppableStore get store => widget.store;
  Function(ShoppableStore)? get onUpdatedStore => widget.onUpdatedStore;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    const Widget defaultTrigger = CustomTextButton(
      '', 
      prefixIcon: Icons.mode_edit_outlined,
    );

    return trigger == null ? defaultTrigger : trigger!;

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
      content: UpdateStoreContent(
        store: store,
        onUpdatedStore: onUpdatedStore
      ),
    );
  }
}