import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import 'package:perfect_order/core/shared_widgets/button/custom_text_button.dart';
import 'package:perfect_order/features/products/models/product.dart';
import '../../../../stores/models/shoppable_store.dart';
import '../product_variations_content.dart';
import 'package:flutter/material.dart';

class ProductVariationsModalBottomSheet extends StatefulWidget {
  
  final Product product;
  final ShoppableStore store;
  final Widget Function(void Function())? trigger;

  const ProductVariationsModalBottomSheet({
    super.key,
    this.trigger,
    required this.store,
    required this.product,
  });

  @override
  State<ProductVariationsModalBottomSheet> createState() => _ProductsModalBottomSheetState();
}

class _ProductsModalBottomSheetState extends State<ProductVariationsModalBottomSheet> {

  Product get product => widget.product;
  ShoppableStore get store => widget.store;
  Widget Function(void Function())? get trigger => widget.trigger;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    /// If the trigger is null, return the default trigger
    if( trigger == null ) {

      /// Return the view variations trigger
      return CustomTextButton('View Variations', onPressed: openBottomModalSheet);

    }else{

      /// If the trigger is not null, return the custom trigger
      return trigger!(openBottomModalSheet);

    }

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
      content: ProductVariationsContent(
        store: store,
        product: product
      ),
    );
  }
}