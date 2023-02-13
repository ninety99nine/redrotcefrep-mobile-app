import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../../core/shared_models/product_line.dart';
import '../../../../../core/shared_models/cart.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class CartProductLines extends StatelessWidget {

  final Cart cart;

  const CartProductLines({
    super.key, 
    required this.cart,
  });

  List<ProductLine> get productLines => cart.relationships.productLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: productLines.mapIndexed((index, product) {

        final productLine = productLines[index];
        final isLastItem = index == productLines.length - 1;

        return Container(
          margin: EdgeInsets.only(bottom: isLastItem ? 0 : 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              //  Name
              CustomBodyText(productLine.name),

              //  Quantity
              Row(
                children: [
                  const CustomBodyText(' x '),
                  CustomBodyText(productLine.quantity.toString()),
                ]
              )

            ],
          ),
        );
        
      }).toList(),
    );
  }
}

