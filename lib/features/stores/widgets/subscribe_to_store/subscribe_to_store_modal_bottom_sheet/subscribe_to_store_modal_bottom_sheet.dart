import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../core/shared_widgets/buttons/custom_elevated_button.dart';
import '../../../models/shoppable_store.dart';
import '../subscribe_to_store_content.dart';
import 'package:flutter/material.dart';

class SubscribeToStoreModalBottomSheet extends StatefulWidget {

  final Widget? trigger;
  final ShoppableStore store;
  final Function? onRefreshStores;
  final Alignment subscribeButtonAlignment;

  const SubscribeToStoreModalBottomSheet({
    super.key,
    this.trigger,
    required this.store,
    this.onRefreshStores,
    this.subscribeButtonAlignment = Alignment.centerRight
  });

  @override
  State<SubscribeToStoreModalBottomSheet> createState() => _SubscribeToStoreModalBottomSheetState();
}

class _SubscribeToStoreModalBottomSheetState extends State<SubscribeToStoreModalBottomSheet> {

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget? get _trigger => widget.trigger;
  ShoppableStore get store => widget.store;
  Function? get onRefreshStores => widget.onRefreshStores;
  Alignment get subscribeButtonAlignment => widget.subscribeButtonAlignment;

  Widget get trigger {

    /// Subscribe Button
    return _trigger == null ? CustomElevatedButton(
      'Subscribe',
      padding: EdgeInsets.zero,
      onPressed: openBottomModalSheet,
      alignment: subscribeButtonAlignment,
    ) : _trigger!;

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
      /// Bottom modal sheet height ratio in comparison to screen height
      heightFactor: 0.4,
      /// Trigger to open the bottom modal sheet
      trigger: trigger,
      /// Content of the bottom modal sheet
      content: SubscribeToStoreContent(
        store: store,
        onRefreshStores: onRefreshStores
      ),
    );
  }
}