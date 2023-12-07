import 'package:bonako_demo/features/products/enums/product_enums.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/products/models/product.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import '../products_content.dart';

enum TriggerType {
  addProduct,
  totalProducts
}

class ProductsModalBottomSheet extends StatefulWidget {
  
  final Product? product;
  final ShoppableStore store;
  final TriggerType triggerType;
  final Function(Product)? onUpdatedProduct;
  final Function(Product)? onCreatedProduct;
  final Widget Function(void Function())? trigger;

  const ProductsModalBottomSheet({
    super.key,
    this.trigger,
    this.product,
    required this.store,
    this.onUpdatedProduct,
    this.onCreatedProduct,
    this.triggerType = TriggerType.totalProducts
  });

  @override
  State<ProductsModalBottomSheet> createState() => _ProductsModalBottomSheetState();
}

class _ProductsModalBottomSheetState extends State<ProductsModalBottomSheet> {

  ProductContentView? productContentView;
  Product? get product => widget.product;
  ShoppableStore get store => widget.store;
  TriggerType get triggerType => widget.triggerType;
  Widget Function(void Function())? get trigger => widget.trigger;
  Function(Product)? get onUpdatedProduct => widget.onUpdatedProduct;
  Function(Product)? get onCreatedProduct => widget.onCreatedProduct;
  String get totalProducts => widget.store.productsCount!.toString();
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  String get totalProductsText => widget.store.productsCount == 1 ? 'Product' : 'Products';

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  @override
  void initState() {
    super.initState();

    /// If the trigger is null and the trigger type is add product
    if( trigger == null && triggerType == TriggerType.addProduct ) {

      /// Set the product content view to creating product
      productContentView = ProductContentView.creatingProduct;

    }
  }

  Widget get _trigger {

    final Widget addProductTrigger = Container(
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

    /// If the trigger is null and the trigger type is total products
    if( trigger == null && triggerType == TriggerType.totalProducts ) {

      /// Return the total products and total products text
      return CustomBodyText([totalProducts, totalProductsText]);
    
    /// If the trigger is null and the trigger type is add product
    }else if( trigger == null && triggerType == TriggerType.addProduct ) {

      /// Return the add product trigger
      return addProductTrigger;

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

  /// Close the bottom modal sheet
  void onClose() => StoreServices.refreshProducts(store, storeProvider);

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      key: _customBottomModalSheetState,
      /// Trigger to open the bottom modal sheet
      trigger: _trigger,
      /// On close bottom modal sheet callback
      onClose: onClose,
      /// Content of the bottom modal sheet
      content: ProductsContent(
        store: store,
        product: product,
        onUpdatedProduct: onUpdatedProduct,
        onCreatedProduct: onCreatedProduct,
        productContentView: productContentView,
      ),
    );
  }
}