import 'package:bonako_demo/features/products/widgets/shoppable_product_cards/select_product_variation_dialog.dart';
import '../../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../components/name_price_and_product_quantity_adjuster.dart';
import '../components/product_description.dart';
import '../components/product_description.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../models/product.dart';

class ShoppableProductVariationCard extends StatefulWidget {

  final Product product;
  final EdgeInsets margin;

  const ShoppableProductVariationCard({
    Key? key,
    required this.product,
    this.margin = const EdgeInsets.symmetric(vertical: 5),
  }) : super(key: key);

  @override
  State<ShoppableProductVariationCard> createState() => _ShoppableProductVariationCardState();
}

class _ShoppableProductVariationCardState extends State<ShoppableProductVariationCard> {

  Product get product => widget.product;
  AudioPlayer audioPlayer = AudioPlayer();
  bool get allowVariations => product.allowVariations.status;
  bool get canShowDescription => product.showDescription.status && product.description != null;

  /// Capture the store that was passed on ListenableProvider.value()
  /// of the StoreCard. This store is accessible if the StoreCard is
  /// an ancestor of this ShoppableProductVariationCard. We can use this shoppable 
  /// store instance for shopping purposes e.g selecting this
  /// product so that we can place an order.
  ShoppableStore get store => Provider.of<ShoppableStore>(context, listen: false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

  Widget get namePriceAndQuantityAdjuster {
    return Column(
      children: [
        Row(
          //  crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            //  Product Name
            Expanded(
              child: CustomBodyText(
                product.name, 
                fontWeight: FontWeight.bold
              ),
            ),

            //  Product Price And Quantity Adjuster
            priceAndQuantityAdjuster

          ],
        ),
      ],
    );
  }

  Widget get priceAndQuantityAdjuster { 
    /**
     *  AnimatedSize helps to animate the sizing from a bigger height
     *  to a smaller height. When hiding or showing the content, the 
     *  transition will be jumpy since the height is not the same.
     *  This helps animate those height differences
     */
    return AnimatedSize(
      clipBehavior: Clip.none,
      duration: const Duration(milliseconds: 500),
      child: Column(
        children: [

          //  Product Quantity Adjuster
          quantityAdjuster,

          //  Spacer
          const SizedBox(height: 4,),

          //  Calculated Unit Price
          calculatedUnitPriceWidget,

        ],
      )
    );
  }

  Widget get quantityAdjuster {
    return Row(
      children: [

        //  Subtract Button
        subtractButtonWidget,

        //  Product Quantity
        quantityWidget,

        //  Add Button
        addButtonWidget,

      ],
    );
  }

  void reduceQuantity() {
    if( product.quantity > 1 ) {
      store.updateSelectedProductQuantity(product, product.quantity - 1);
    }else{
      store.addOrRemoveSelectedProduct(product);
    }
  }

  Widget get subtractButtonWidget {

    return GestureDetector(
      onTap: reduceQuantity,
      child: const Icon(Icons.remove_circle_sharp, size: 24, color: Colors.green,)
    );

  }

  void increaseQuantity() {
    store.updateSelectedProductQuantity(product, product.quantity + 1);
  }

  Widget get addButtonWidget {

    return GestureDetector(
      onTap: increaseQuantity,
      child: const Icon(Icons.add_circle_sharp, size: 24, color: Colors.green,)
    );
    
  }

  Widget get quantityWidget {
    return Container(
      width: 40,
      alignment: Alignment.center,
      child: CustomTitleMediumText(product.quantity.toString()),
    );
  }

  Widget get calculatedUnitPriceWidget {
    return CustomTitleSmallText('P${(product.unitPrice.amount * product.quantity).toStringAsFixed(2)}');
  }

  Widget get descriptionAnimatedWidget {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
        child: SizedBox(
          key: ValueKey(canShowDescription),
          height: canShowDescription ? null : 0,
          child: descriptionWidget,
        ),
      ),
    );
  }

  Widget get descriptionWidget {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        CustomBodyText(widget.product.description.toString())
      ],
    );
  }

  Widget get checkmarkIcon {
    return const Positioned(
      top: 2,
      left: 2,
      child: CircleAvatar(
        radius: 10,
        backgroundColor: Colors.green,
        child: Icon(Icons.check, size: 16),
      ),
    );
  }

  void onTap() {

    DialogUtility.showInfiniteScrollContentDialog(
      context: context,
      heightRatio: 0.9,
      showCloseIcon: false,
      backgroundColor: Colors.transparent,
      content: ListenableProvider.value(
        value: store,
        child: SelectProductVariationDialog(productVariation: product)
      ), 
    );

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: widget.margin,
          width: double.infinity,
          child: Material(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.green, width: 1),
            ),
            color: Colors.green.shade50,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: Ink(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        
                      //  Product Name, Price And Quantity
                      NamePriceAndProductQuantityAdjuster(store: store, product: product, selected: true),
                    
                      //  Product Description
                      ProductDescription(product: product),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        //  Checkmark Icon
        //  if(selected) checkmarkIcon,
      ],
    );
  }
}