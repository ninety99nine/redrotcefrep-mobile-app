import 'package:bonako_demo/core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/products/models/product.dart';
import 'package:bonako_demo/features/products/widgets/create_product/create_product_content.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class CreateProductModalBottomSheet extends StatefulWidget {

  final Product? product;
  final ShoppableStore store;
  final Function()? onDeletedProduct;
  final Function(Product)? onUpdatedProduct;
  final Function(Product)? onCreatedProduct;
  final Widget Function(void Function())? trigger;

  const CreateProductModalBottomSheet({
    super.key,
    this.product,
    this.trigger,
    required this.store,
    this.onDeletedProduct,
    this.onUpdatedProduct,
    this.onCreatedProduct,
  });

  @override
  State<CreateProductModalBottomSheet> createState() => CreateProductModalBottomSheetState();
}

class CreateProductModalBottomSheetState extends State<CreateProductModalBottomSheet> {

  Product? get product => widget.product;
  ShoppableStore get store => widget.store;
  Function()? get onDeletedProduct => widget.onDeletedProduct;
  Widget Function(void Function())? get trigger => widget.trigger;
  Function(Product)? get onUpdatedProduct => widget.onUpdatedProduct;
  Function(Product)? get onCreatedProduct => widget.onCreatedProduct;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    final Widget defaultTrigger = Container(
      margin: const EdgeInsets.only(top: 5),
      child: DottedBorder(
        color: Colors.grey,
        radius: const Radius.circular(8),
        borderType: BorderType.RRect,
        strokeCap: StrokeCap.butt,
        padding: EdgeInsets.zero,
        dashPattern: const [6, 3], 
        strokeWidth: 1,
        child: Material(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color:Colors.grey.shade100,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => openBottomModalSheet(),
            child: Ink(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.add, size: 16, color: Colors.grey.shade400,),
                      const SizedBox(width: 4,),
                      const CustomBodyText('Add Product', lightShade: true,)
                    ],
                  )
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return trigger == null ? defaultTrigger : trigger!(openBottomModalSheet);

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
      content: CreateProductContent(
        store: store,
        product: product,
        onCreatedProduct: onCreatedProduct,
        onUpdatedProduct: onUpdatedProduct,
        onDeletedProduct: onDeletedProduct,
      ),
    );
  }
}