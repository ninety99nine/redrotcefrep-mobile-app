import 'package:perfect_order/features/stores/models/shoppable_store.dart';

import '../../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import 'package:flutter/material.dart';
import '../search_content.dart';

class SearchModalBottomSheet extends StatefulWidget {

  final bool showFilters;
  final bool showExpandIconButton;
  final Widget Function(Function)? trigger;
  final Function(ShoppableStore)? onSelectedStore;

  const SearchModalBottomSheet({
    super.key,
    this.trigger,
    this.onSelectedStore,
    this.showFilters = true,
    this.showExpandIconButton = true,
  });

  @override
  State<SearchModalBottomSheet> createState() => _SearchModalBottomSheetState();
}

class _SearchModalBottomSheetState extends State<SearchModalBottomSheet> {

  bool get showFilters => widget.showFilters;
  Widget Function(Function)? get trigger => widget.trigger;
  bool get showExpandIconButton => widget.showExpandIconButton;
  Function(ShoppableStore)? get onSelectedStore => widget.onSelectedStore;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    Widget defaultTrigger = FloatingActionButton(
      mini: true,
      heroTag: 'search-button',
      onPressed: openBottomModalSheet,
      child: const Icon(Icons.search)
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
      content: SearchContent(
        showFilters: showFilters,
        onSelectedStore: onSelectedStore,
        showExpandIconButton: showExpandIconButton
      ),
    );
  }
}