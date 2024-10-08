import 'package:perfect_order/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:perfect_order/features/products/models/product.dart';
import 'package:flutter/material.dart';

class ProductUnitGrandTotal extends StatelessWidget {

  final Product product;

  const ProductUnitGrandTotal({
    super.key,
    required this.product
  });

  @override
  Widget build(BuildContext context) {
    return CustomTitleSmallText( 'P${(product.unitPrice.amount * product.quantity).toStringAsFixed(2)}');
  }
}