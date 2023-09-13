import 'package:bonako_demo/features/products/widgets/shoppable_product_cards/select_product_variation_dialog.dart';
import 'shoppable_product_variation_cards/shoppable_product_variation_cards.dart';
import 'components/name_price_and_product_quantity_adjuster.dart';
import 'components/name_and_total_variation_options.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:audioplayers/audioplayers.dart';
import 'components/product_description.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../models/product.dart';

class ShoppableProductCard extends StatefulWidget {

  final bool selected;
  final Product product;
  final EdgeInsets margin;
  final bool showAllProducts;

  const ShoppableProductCard({
    Key? key,
    this.selected = false,
    required this.product,
    required this.showAllProducts,
    this.margin = const EdgeInsets.symmetric(vertical: 5),
  }) : super(key: key);

  @override
  State<ShoppableProductCard> createState() => _ShoppableProductCardState();
}

class _ShoppableProductCardState extends State<ShoppableProductCard> {

  bool get selected => widget.selected;
  Product get product => widget.product;
  AudioPlayer audioPlayer = AudioPlayer();
  bool get allowVariations => product.allowVariations.status;
  bool get hasSelectedVariationProducts => store.getSelectedVariationProducts(product).isNotEmpty;
  bool get canShowDescription => product.showDescription.status && selected && product.description != null;

  /// Capture the store that was passed on ListenableProvider.value()
  /// of the StoreCard. This store is accessible if the StoreCard is
  /// an ancestor of this ShoppableProductCard. We can use this shoppable 
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

    /// Check if this product supports variations
    if(product.allowVariations.status) {

      DialogUtility.showInfiniteScrollContentDialog(
        context: context,
        heightRatio: 0.9,
        showCloseIcon: false,
        backgroundColor: Colors.transparent,
        content: ListenableProvider.value(
          value: store,
          child: SelectProductVariationDialog(parentProduct: product)
        ), 
      );

    }else{

      if(store.checkIfSelectedProductExists(product) == false) {

        /// Play success sound
        audioPlayer.play(AssetSource('sounds/success.mp3'), mode: PlayerMode.lowLatency);

      }

      store.addOrRemoveSelectedProduct(product);

    }
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
              side: selected ? const BorderSide(color: Colors.green, width: 1) : BorderSide.none,
            ),
            color: selected ? Colors.green.shade50 : Colors.grey.shade100,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: Ink(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      //  Product without variations
                      if(!allowVariations) ...[
                        
                        //  Product Name, Price And Quantity
                        NamePriceAndProductQuantityAdjuster(store: store, product: product, selected: selected),
                      
                        //  Product Description
                        ProductDescription(product: product),

                      ],

                      //  Product with variations
                      if(allowVariations) ...[
                        
                        //  Product Name And Total Variation Options
                        NameAndTotalVariationOptions(store: store, product: product, selected: selected),

                        //  Product Variation Cards
                        if(hasSelectedVariationProducts) ShoppableProductVariationCards(product: product)

                      ],

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