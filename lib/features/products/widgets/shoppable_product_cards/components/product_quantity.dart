import 'package:perfect_order/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:perfect_order/features/products/models/product.dart';
import 'package:flutter/material.dart';

class ProductQuantity extends StatelessWidget {

  final Product product;

  const ProductQuantity({
    super.key,
    required this.product
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      alignment: Alignment.center,
      child: CustomTitleMediumText(product.quantity.toString()),
    );
  }
}