import 'package:perfect_order/features/products/widgets/show_products/products_modal_bottom_sheet/products_modal_bottom_sheet.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/stores/models/shoppable_store.dart';
import 'package:flutter/material.dart';
import '../../models/product.dart';

class EditProductCard extends StatefulWidget {

  final Product product;
  final EdgeInsets margin;
  final ShoppableStore store;

  const EditProductCard({
    Key? key,
    required this.store,
    required this.margin,
    required this.product,
  }) : super(key: key);

  @override
  State<EditProductCard> createState() => _EditProductCardState();
}

class _EditProductCardState extends State<EditProductCard> {

  Product get product => widget.product;
  ShoppableStore get store => widget.store;
  bool get allowVariations => product.allowVariations.status;
  int get totalVisibleVariations => product.totalVisibleVariations!;

  @override
  Widget build(BuildContext context) {
    return ProductsModalBottomSheet(
      store: store,
      product: product,
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

                        if(!allowVariations) ...[

                          /// Unit Price
                          CustomBodyText(
                            product.unitPrice.amountWithCurrency, 
                            margin: const EdgeInsets.only(right: 16),
                          ),

                        ],

                        if(allowVariations) ...[

                          //  Total Variation Options
                          CustomBodyText(
                            margin: const EdgeInsets.only(right: 16),
                            '$totalVisibleVariations ${totalVisibleVariations == 1 ? 'option' : 'options'}'
                          ),

                        ],
    
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
            child: Icon(Icons.mode_edit_outlined, size: 20, color: Colors.grey.shade400,)
          ),
    
        ],
      ),
    );
  }
}