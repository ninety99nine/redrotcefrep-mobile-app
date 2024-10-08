import 'package:perfect_order/features/stores/models/shoppable_store.dart';
import 'package:perfect_order/features/products/models/product.dart';
import 'package:flutter/material.dart';

class ReduceProductQuantityButton extends StatelessWidget {

  final Product product;
  final ShoppableStore store;
  final Function(int)? onReduceProductQuantity;

  const ReduceProductQuantityButton({
    super.key,
    required this.store,
    required this.product,
    this.onReduceProductQuantity
  });

  void reduceQuantity() {
    if(onReduceProductQuantity == null) {

      if( product.quantity > 1 ) {
        store.updateSelectedProductQuantity(product, product.quantity - 1);
      }else{
        store.addOrRemoveSelectedProduct(product);
      }

    }else{
      
      if(product.quantity - 1 > 1) {
        onReduceProductQuantity!(product.quantity - 1);
      }else{
        onReduceProductQuantity!(1);
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: reduceQuantity,
      child: const Icon(Icons.remove_circle_sharp, size: 24, color: Colors.green,)
    );
  }
}