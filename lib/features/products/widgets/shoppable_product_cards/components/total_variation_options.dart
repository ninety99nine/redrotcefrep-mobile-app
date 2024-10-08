import 'package:perfect_order/core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/products/models/product.dart';
import 'package:flutter/material.dart';

class TotalVariationOptions extends StatelessWidget {

  final Product product;

  const TotalVariationOptions({
    super.key,
    required this.product,
  });

  int get totalVisibleVariations => product.totalVisibleVariations!;

  @override
  Widget build(BuildContext context) {
    return CustomBodyText('$totalVisibleVariations ${totalVisibleVariations == 1 ? 'option' : 'options'}');
  }
}