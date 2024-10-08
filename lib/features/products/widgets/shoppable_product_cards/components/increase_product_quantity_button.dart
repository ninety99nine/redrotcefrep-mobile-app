import 'package:perfect_order/features/stores/models/shoppable_store.dart';
import 'package:perfect_order/features/products/models/product.dart';
import 'package:flutter/material.dart';

class IncreaseProductQuantityButton extends StatelessWidget {

  final Product product;
  final ShoppableStore store;
  final Function(int)? onIncreaseProductQuantity;

  const IncreaseProductQuantityButton({
    super.key,
    required this.store,
    required this.product,
    this.onIncreaseProductQuantity
  });

  void increaseQuantity() {
    if(onIncreaseProductQuantity == null) {
      store.updateSelectedProductQuantity(product, product.quantity + 1);
    }else{
      onIncreaseProductQuantity!(product.quantity + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: increaseQuantity,
      child: const Icon(Icons.add_circle_sharp, size: 24, color: Colors.green,)
    );
  }
}