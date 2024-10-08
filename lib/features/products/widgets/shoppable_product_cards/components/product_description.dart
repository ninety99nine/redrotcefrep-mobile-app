import 'package:perfect_order/core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/products/models/product.dart';
import 'package:flutter/material.dart';

class ProductDescription extends StatelessWidget {

  final Product product;

  const ProductDescription({
    super.key,
    required this.product
  });

  bool get canShowDescription => product.showDescription.status && product.description != null;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
        child: SizedBox(
          key: ValueKey(canShowDescription),
          height: canShowDescription ? null : 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              CustomBodyText(product.description.toString())
            ],
          ),
        )
      )
    );
  }
}