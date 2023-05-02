import '../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../stores/models/shoppable_store.dart';
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
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
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
      child: Container(
        key: ValueKey(selected),
        child: 
          Column(
            children: [
    
              //  Product Quantity Adjuster
              if(selected) quantityAdjuster,
    
              //  Spacer
              if(selected) const SizedBox(height: 4,),
    
              //  Calculated Unit Price
              calculatedUnitPriceWidget,
    
            ],
          )
      ),
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

  Widget get subtractButtonWidget {

    reduceQuantity() {
      if( product.quantity > 1 ) {
        store.updateSelectedProductQuantity(product, product.quantity - 1);
      }else{
        store.addOrRemoveSelectedProduct(product);
      }
    }

    return GestureDetector(
      onTap: reduceQuantity,
      child: const Icon(Icons.remove_circle_sharp, size: 24, color: Colors.green,)
    );

  }

  Widget get addButtonWidget {

    increaseQuantity() {
      store.updateSelectedProductQuantity(product, product.quantity + 1);
    }

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
    return CustomTitleSmallText(
      selected
        ? 'P${(product.unitPrice.amount * product.quantity).toStringAsFixed(2)}'
        : product.unitPrice.amountWithCurrency
    );
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
    store.addOrRemoveSelectedProduct(product);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: widget.margin,
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

                      //  Product Name, Price And Quantity
                      namePriceAndQuantityAdjuster,
                      
                      //  Product Description
                      descriptionAnimatedWidget,

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