import 'package:perfect_order/features/products/widgets/shoppable_product_cards/components/increase_product_quantity_button.dart';
import 'package:perfect_order/features/products/widgets/shoppable_product_cards/components/reduce_product_quantity_button.dart';
import 'package:perfect_order/features/stores/models/shoppable_store.dart';
import 'package:perfect_order/features/products/models/product.dart';
import 'package:flutter/material.dart';
import 'product_quantity.dart';

class ProductQuantityAdjuster extends StatelessWidget {

  final Product product;
  final ShoppableStore store;
  final Function(int)? onReduceProductQuantity;
  final Function(int)? onIncreaseProductQuantity;

  const ProductQuantityAdjuster({
    super.key,
    required this.store,
    required this.product,
    this.onReduceProductQuantity,
    this.onIncreaseProductQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        //  Reduce Product Quantity Button
        ReduceProductQuantityButton(
          store: store, 
          product: product, 
          onReduceProductQuantity: onReduceProductQuantity,
        ),

        //  Product Quantity
        ProductQuantity(product: product),

        //  Increase Product Quantity Button
        IncreaseProductQuantityButton(
          store: store, 
          product: product,
          onIncreaseProductQuantity: onIncreaseProductQuantity,
        ),

      ],
    );
  }
}