import 'package:perfect_order/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:perfect_order/core/shared_widgets/button/custom_text_button.dart';
import 'package:perfect_order/features/products/widgets/shoppable_product_cards/shoppable_product_variation_cards/shoppable_product_variation_card.dart';

import '../../../../../core/shared_widgets/message_alert/custom_message_alert.dart';
import '../../../../../core/shared_widgets/button/show_more_or_less_button.dart';
import '../../../../../../../core/constants/constants.dart' as constants;
import '../../../../stores/providers/store_provider.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../shoppable_product_card.dart';
import '../../../models/product.dart';

class ShoppableProductVariationCards extends StatefulWidget {

  final Product product;

  const ShoppableProductVariationCards({
    super.key,
    required this.product,
  });

  @override
  State<ShoppableProductVariationCards> createState() => _ShoppableProductVariationCardsState();
}

class _ShoppableProductVariationCardsState extends State<ShoppableProductVariationCards> {
  
  ShoppableStore? store;
  Product get product => widget.product;
  List<Product> get selectedVariationProducts => store == null ? [] : store!.getSelectedVariationProducts(product);

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// Get the updated Shoppable Store Model
    store = Provider.of<ShoppableStore>(context, listen: false);

  }

  Widget content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 8.0,),

        //  Product Cards
        ...selectedVariationProducts.mapIndexed((index, product) {
          
          return ShoppableProductVariationCard(
            product: product,
            margin: EdgeInsets.only(bottom: (index == selectedVariationProducts.length - 1) ? 0 : 5)
          );
          
        }).toList(),

        const SizedBox(height: 8.0,),
        
        const CustomTextButton('+ Add Another')

      ]
    );
  }

  @override
  Widget build(BuildContext context) {

    /// Listen to changes on the Shoppable Store Model that was passed on 
    /// ListenableProvider.value() of the StoreCard. Once these changes
    /// occur, the didChangeDependencies() change will be notified
    /// first so that we can capture the store and its changes. We 
    /// can then run any other logic after the updated store is 
    /// retrieved. After the didChangeDependencies() completes
    /// its logic, this build() method will be called to
    /// rebuild the UI and implement any new changes.
    Provider.of<ShoppableStore>(context, listen: true);

    /**
     *  AnimatedSize helps to animate the sizing from a bigger height
     *  to a smaller height. When changing the content height, the 
     *  transition will be jumpy since the height is not the same.
     *  This helps animate those height differences.
     * 
     *  AnimatedSwitcher helps to animate the change of widgets
     *  by using an smooth opacity transition.
     */
    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 500),
          child: AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
            child: content()
          )
        ),
      ],
    );
  }
}