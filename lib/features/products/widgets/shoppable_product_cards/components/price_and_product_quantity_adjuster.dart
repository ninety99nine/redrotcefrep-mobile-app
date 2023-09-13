import 'package:bonako_demo/features/products/widgets/shoppable_product_cards/components/product_quantity_adjuster.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/products/models/product.dart';
import 'package:flutter/material.dart';
import 'product_unit_grand_total.dart';

class PriceAndProductQuantityAdjuster extends StatelessWidget {

  final bool selected;
  final Product product;
  final ShoppableStore store;
  final Function(int)? onReduceProductQuantity;
  final Function(int)? onIncreaseProductQuantity;

  const PriceAndProductQuantityAdjuster({
    super.key,
    required this.store,
    required this.product,
    required this.selected,
    this.onReduceProductQuantity,
    this.onIncreaseProductQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      clipBehavior: Clip.none,
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(selected),
        child: 
          Column(
            children: [
    
              //  Product Quantity Adjuster
              if(selected) ProductQuantityAdjuster(
                store: store, 
                product: product, 
                onReduceProductQuantity: onReduceProductQuantity,
                onIncreaseProductQuantity: onIncreaseProductQuantity,
              ),
    
              //  Spacer
              if(selected) const SizedBox(height: 4,),
    
              //  Product Unit Grand Total
              ProductUnitGrandTotal(product: product)
    
            ],
          )
      ),
    );
  }
}