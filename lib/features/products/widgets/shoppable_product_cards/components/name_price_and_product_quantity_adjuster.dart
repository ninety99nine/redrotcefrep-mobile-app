import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/products/models/product.dart';
import 'price_and_product_quantity_adjuster.dart';
import 'package:flutter/material.dart';

class NamePriceAndProductQuantityAdjuster extends StatelessWidget {

  final bool selected;
  final Product product;
  final ShoppableStore store;
  final Function(int)? onReduceProductQuantity;
  final Function(int)? onIncreaseProductQuantity;

  const NamePriceAndProductQuantityAdjuster({
    super.key,
    required this.store,
    required this.product,
    required this.selected,
    this.onReduceProductQuantity,
    this.onIncreaseProductQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(

          //  crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            //  Product Name
            Expanded(
              child: CustomBodyText(
                product.name, 
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),

            //  Product Price And Quantity Adjuster
            PriceAndProductQuantityAdjuster(
              store: store, 
              product: product, 
              selected: selected, 
              onReduceProductQuantity: onReduceProductQuantity,
              onIncreaseProductQuantity: onIncreaseProductQuantity
            )

          ],
        ),
      ],
    );
  }
}