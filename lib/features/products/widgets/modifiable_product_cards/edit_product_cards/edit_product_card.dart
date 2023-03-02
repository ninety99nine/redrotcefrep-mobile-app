import 'package:bonako_demo/features/products/widgets/create_product/create_product_modal_bottom_sheet/create_product_modal_bottom_sheet.dart';
import '../../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:flutter/material.dart';
import '../../../models/product.dart';

class EditProductCard extends StatefulWidget {

  final Product product;
  final EdgeInsets margin;
  final ShoppableStore store;
  final Function()? onDeletedProduct;
  final Function(Product)? onUpdatedProduct;

  const EditProductCard({
    Key? key,
    required this.store,
    required this.margin,
    required this.product,
    this.onUpdatedProduct,
    this.onDeletedProduct,
  }) : super(key: key);

  @override
  State<EditProductCard> createState() => _EditProductCardState();
}

class _EditProductCardState extends State<EditProductCard> {

  Product get product => widget.product;
  ShoppableStore get store => widget.store;
  Function()? get onDeletedProduct => widget.onDeletedProduct;
  Function(Product)? get onUpdatedProduct => widget.onUpdatedProduct;

  @override
  Widget build(BuildContext context) {
    return CreateProductModalBottomSheet(
      store: store,
      product: product,
      onDeletedProduct: onDeletedProduct,
      onUpdatedProduct: onUpdatedProduct,
      trigger: (openBottomModalSheet) => Stack(
        children: [
          Container(
            margin: widget.margin,
            width: double.infinity,
            child: Material(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide.none,
              ),
              color: Colors.grey.shade100,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: openBottomModalSheet,
                child: Ink(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
    
                        /// Name
                        Expanded(child: CustomBodyText(product.name)),
    
                        /// Spacer
                        const SizedBox(width: 8,),
    
                        /// Unit Price
                        CustomBodyText(product.unitPrice.amountWithCurrency, margin: const EdgeInsets.only(right: 16),),
    
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    
          /// Edit icon
          Positioned(
            top: 6,
            right: 8,
            child: Icon(Icons.edit, size: 20, color: Colors.grey.shade400,)
          ),
    
        ],
      ),
    );
  }
}