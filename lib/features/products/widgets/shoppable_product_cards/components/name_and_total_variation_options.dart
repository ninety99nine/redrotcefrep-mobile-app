import 'package:perfect_order/core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/products/widgets/shoppable_product_cards/components/total_variation_options.dart';
import 'package:perfect_order/features/stores/models/shoppable_store.dart';
import 'package:perfect_order/features/products/models/product.dart';
import 'package:flutter/material.dart';

class NameAndTotalVariationOptions extends StatelessWidget {

  final bool selected;
  final Product product;
  final ShoppableStore store;

  const NameAndTotalVariationOptions({
    super.key,
    required this.store,
    required this.product,
    required this.selected,
  });

  int get totalVisibleVariations => product.totalVisibleVariations!;

  void increaseQuantity() {
    store.updateSelectedProductQuantity(product, product.quantity + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        //  Product Name
        Expanded(
          child: CustomBodyText(
            product.name, 
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),

        //  Total Variation Options
        TotalVariationOptions(product: product,),

      ],
    );
  }
}