import 'package:bonako_demo/features/stores/widgets/create_store/create_store_modal_bottom_sheet/create_store_content.dart';
import '../../../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:flutter/material.dart';

class CreateStoreModalBottomSheet extends StatefulWidget {
  
  final String? title;
  final String? subtitle;
  final Widget Function(Function())? trigger;
  final void Function(ShoppableStore)? onCreatedStore;

  const CreateStoreModalBottomSheet({
    super.key,
    this.title,
    this.trigger,
    this.subtitle,
    this.onCreatedStore,
  });

  @override
  State<CreateStoreModalBottomSheet> createState() => CreateStoreModalBottomSheetState();
}

class CreateStoreModalBottomSheetState extends State<CreateStoreModalBottomSheet> {

  String? get title => widget.title;
  String? get subtitle => widget.subtitle;
  Widget Function(Function())? get trigger => widget.trigger;
  Function(ShoppableStore)? get onCreatedStore => widget.onCreatedStore;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    Widget defaultTrigger = CustomElevatedButton('Create Store', onPressed: openBottomModalSheet);

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
      content: CreateStoreContent(
        title: title,
        subtitle: subtitle,
        onCreatedStore: onCreatedStore
      ),
    );
  }
}