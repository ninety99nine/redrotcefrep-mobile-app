import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import 'package:perfect_order/core/shared_widgets/icon_button/mobile_phone_icon_button.dart';
import 'package:perfect_order/features/products/enums/product_enums.dart';
import '../associated_stores_content.dart';
import 'package:flutter/material.dart';

class AssociatedStoresModalBottomSheet extends StatefulWidget {
  
  final Widget Function(void Function())? trigger;

  const AssociatedStoresModalBottomSheet({
    super.key,
    this.trigger
  });

  @override
  State<AssociatedStoresModalBottomSheet> createState() => _AssociatedStoresModalBottomSheetState();
}

class _AssociatedStoresModalBottomSheetState extends State<AssociatedStoresModalBottomSheet> {

  ProductContentView? productContentView;
  Widget Function(void Function())? get trigger => widget.trigger;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    /// If the trigger is not null, return the custom trigger
    return trigger == null 
      ? MobilePhoneIconButton(size: 20, onTap: openBottomModalSheet)
      : trigger!(openBottomModalSheet);

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
      content: const AssociatedStoresContent(),
    );
  }
}