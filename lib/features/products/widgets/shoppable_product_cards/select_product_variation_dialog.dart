
import 'package:bonako_demo/core/shared_widgets/button/custom_text_button.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/icon_button/close_modal_icon_button.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/products/providers/product_provider.dart';
import 'package:bonako_demo/features/stores/widgets/store_dialog_header.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'components/name_price_and_product_quantity_adjuster.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:audioplayers/audioplayers.dart';
import 'components/product_description.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import '../../models/product.dart';
import 'package:get/get.dart';

class SelectProductVariationDialog extends StatefulWidget {

  final Product? parentProduct;
  final Product? productVariation;

  const SelectProductVariationDialog({
    Key? key,
    this.parentProduct,
    this.productVariation,
  }) : super(key: key);

  @override
  State<SelectProductVariationDialog> createState() => _SelectProductVariationDialogState();
}

class _SelectProductVariationDialogState extends State<SelectProductVariationDialog> {

  bool isLoading = false;
  int totalProductVariations = 0;
  Product? selectedProductVariation;
  List<Product> productVariations = [];
  List <Product> variationAncestors = [];
  AudioPlayer audioPlayer = AudioPlayer();
  Product? get parentProduct => widget.parentProduct;
  ScrollController scrollController = ScrollController();
  bool get hasProductVariation => productVariation != null;
  Product? get productVariation => widget.productVariation;
  Map<int, Map<String, String>> selectedVariantAttributes = {};
  bool get productVariationHasBeenChanged => hasProductVariation && productVariation!.id != selectedProductVariation!.id;

  ShoppableStore get store => Provider.of<ShoppableStore>(context, listen: false);
  ProductProvider get productProvider => Provider.of<ProductProvider>(context, listen: false);

  bool get hasSelectedAllChoices {

    if(selectedVariantAttributes.values.isNotEmpty) {

      return variationAncestors.last.variantAttributes.length == selectedVariantAttributes.values.last.values.length;
    
    }
    
    return false;

  }

  ///  Since the selectedVariantAttributes property is structured as follows:
  /// 
  ///  {
  ///    0 : {                       <---- For the first variation ancestor, we selected the following
  ///        "material": "polyester"       <---- polyester for material
  ///    },
  ///    1 : {                       <---- For the second variation ancestor, we selected the following
  ///        "color": "blue",              <---- blue for color 
  ///        "size": "small"               <---- small for size 
  ///    },
  ///    ...
  ///  }
  /// 
  ///  The lastVariationAncestorVariantAttributeChoices would target the last property of this structure:
  /// 
  ///  {
  ///        "color": "blue",
  ///        "size": "small"
  ///  }
  /// 
  ///  Then we would convert this into the following:
  /// 
  ///  "color|blue,size|small"
  /// 
  ///  Notice that a variation ancestor is simply a list of products that support variations starting with
  ///  the root parent down to the final node that supports variations. Each variation ancestor would have
  ///  its own list of variant attributes that allow us to make choices such as selecting our choice for
  ///  color, size, material, e.t.c
  String get lastVariationAncestorVariantAttributeChoices => selectedVariantAttributes.values.last.entries.map((entry) => "${entry.key}|${entry.value}").toList().join(',');

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);

  @override
  void initState() {
    super.initState();


    if(productVariation == null) {

      variationAncestors = [parentProduct!];

    }else{

      selectedProductVariation = productVariation;
      variationAncestors = productVariation!.variationAncestors;
      selectedVariantAttributes = productVariation!.selectedVariantAttributes;
    
    }
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
    scrollController.dispose();
  }

  void updateSelectedVariantAttributes({ required Product variationAncestor, required String name, required String value, required index }) {
    setState(() {

      /**
       *  Add selectedVariantAttributes values as follows:
       * 
       *  {
       *    0 : {                       <---- For the first variation ancestor, we selected the following
       *        "material": "polyester"       <---- polyester for material 
       *    },
       *    1 : {                       <---- For the second variation ancestor, we selected the following
       *        "color": "blue",              <---- blue for color 
       *        "size": "small"               <---- small for size 
       *    },
       *    ...
       *  }
       * 
       *  Notice that a variation ancestor is simply a list of products that support variations starting with
       *  the root parent down to the final node that supports variations. Each variation ancestor would have
       *  its own list of variant attributes that allow us to make choices such as selecting our choice for
       *  color, size, material, e.t.c
       */
      if(selectedVariantAttributes.containsKey(index)) {

        /// If the key already exists, then overide its value
        selectedVariantAttributes[index]![name] = value;

      }else{

        /// If the key does not already exist, then set its value for the first time
        selectedVariantAttributes[index] = {};
        selectedVariantAttributes[index]![name] = value;

      }

      /**
       *  Remove any choices that we have already made that are beyond our current selection creteria e.g
       * 
       *  Suppose we have the following:
       * 
       *  {
       *    0 : {                       <---- For the first variation ancestor, we selected the following
       *        "material": "polyester"       <---- polyester for material 
       *    },
       *    1 : {                       <---- For the second variation ancestor, we selected the following
       *        "color": "blue",              <---- blue for color 
       *        "size": "small"               <---- small for size 
       *    },
       *    ...
       *  }
       * 
       *  Remember that the index represents the variation ancestor e.g
       * 
       *  index 0: Means that we are focusing on choices of the first variation ancestor which are
       *  material being polyester/nylon.
       * 
       *  index 1: Means that we are focusing on choices of the second variation ancestor which are
       *  color being red/blue/green and size being small/medium/large.
       * 
       *  If change the value at index "0" from "polyester" to "nylon" then we will need to erase
       *  our choices for color and size since we modified the selection creteria of the first
       *  ancestor which might affect the selection creteria of the second ancestor e.g Maybe
       *  by selecting nylon we might not have anymore options that we need to choose from.
       *  It might be that selecting "polyester" will result in another product with
       *  variations hence why we would need to select the color and size. However
       *  it might also be that by selecting nylon, this might not have variations
       *  and therefore we don't have any choices to select from. We always need
       *  to make sure that when we change an option on one creteria, then the
       *  selected choices beyond that creteria must be erased.
       * 
       *  Therefore if "material" is changed from "polyester" to "nylon" on the choices offered
       *  by the first variation ancestor, then we must erase the choices of the follow-up
       *  ancestors since they might not be relevant to our new choice. We therefore end
       *  up with the following results
       * 
       *  {
       *    0 : {                       <---- For the first variation ancestor, we selected the following
       *        "material": "nylon"         <---- nylon for material 
       *    }
       *  }
       */
      selectedVariantAttributes.removeWhere((key, value) => key > index);
      variationAncestors.removeWhere((product) => variationAncestors.indexOf(product) > index);

      /// If we have selected all the required choices 
      if(hasSelectedAllChoices) {
        
        requestProductVariations();

      }

    });
  }

  Future<dio.Response> requestProductVariations() {

    _startLoader();
    
    return productProvider.setProduct(variationAncestors.last).productRepository.showProductVariations(
      variantAttributeChoices: lastVariationAncestorVariantAttributeChoices
    ).then((response) {

      if(response.statusCode == 200) {

        setState(() {

          totalProductVariations = response.data['total'];

          productVariations = (response.data['data'] as List).map((productVariation) {
            return Product.fromJson(productVariation);
          }).toList();

          /// If we have only one variation to choose from
          if(totalProductVariations == 1) {

            /// Check if this variation supports variations as well
            if(productVariations.first.allowVariations.status) {

              /// If it does then we must add it to the stack of variation ancestors
              variationAncestors.add(productVariations.first);

            }else{
              
              /// Select this product variation
              selectedProductVariation = productVariations.firstOrNull;

            }

            /// Scroll to the bottom to show the variation option
            scrollToBottom();
            
          }

        });

      }

      return response;

    }).whenComplete(() {
      
      _stopLoader();

    });
  }

  void scrollToBottom() {

    /**
     *  We use the Future.delayed() method to wait until the 500 milliseconds
     *  duration required to animated the widgets whenever the UI is updated.
     *  This gives the scrollController time to know the maxScrollExtent
     *  before we actually start scrolling.
     */
    Future.delayed(const Duration(milliseconds: 500)).then((_) {
      scrollController.animateTo( 
        curve: Curves.easeOut,
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
      );
    });

  }
  
  Widget get noProductVariation {

    return const CustomMessageAlert('This option is not available at the moment');
  
  }

  void onSelectProductVariation() {

    if(store.checkIfSelectedProductExists(selectedProductVariation!) == false) {

      /// Play success sound
      audioPlayer.play(AssetSource('sounds/success.mp3'), mode: PlayerMode.lowLatency);

    }

    /// Set the variation parent product id
    selectedProductVariation!.variationAncestors = variationAncestors;

    /// Set the selected variant attributes
    selectedProductVariation!.selectedVariantAttributes = selectedVariantAttributes;

    /// If the previous selected product variation does not match the current selected product variation
    if(productVariationHasBeenChanged) {

      /// Remove the previous selected product variation
      store.removeSelectedProduct(productVariation!);

    }

    /// Add the selected product variation
    store.addSelectedProduct(selectedProductVariation!);

    /// Close the Dialog
    Get.back();

  }

  Widget get showProductVariation {

    return SizedBox(
      width: double.infinity,
      child: Material(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.green, width: 1)
        ),
        color: Colors.green.shade50,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onSelectProductVariation,
          child: Ink(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    
                  //  Product Name, Price And Quantity
                  NamePriceAndProductQuantityAdjuster(
                    store: store, 
                    selected: true, 
                    product: selectedProductVariation!, 
                    onReduceProductQuantity: onUpdateProductQuantity,
                    onIncreaseProductQuantity: onUpdateProductQuantity
                  ),
                
                  //  Product Description
                  ProductDescription(product: selectedProductVariation!),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  
  }

  void onUpdateProductQuantity(int quantity) {
    setState(() {
      selectedProductVariation!.quantity = quantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Expanded(
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0)
            ),
            margin: EdgeInsets.zero,
            child: Column(
              children: [
          
                /// Store Dialog Header
                StoreDialogHeader(store: store, padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0)),
        
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0,),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          ...variationAncestors.mapIndexed((index, variationAncestor) {
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                              
                                if(index == 0) ...[
                                  
                                  /// Parent Product Name
                                  CustomTitleSmallText(variationAncestor.name, margin: const EdgeInsets.symmetric(vertical: 8.0),),
                                  
                                ],

                                ...variationAncestor.variantAttributes.mapIndexed((index2, variantAttribute) {
                                
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                
                                      /// Divider
                                      const Divider(height: 32.0,),
                                
                                      /// Instruction
                                      CustomTitleSmallText(variantAttribute.instruction),
                                              
                                      /// Select An Option
                                      ...variantAttribute.values.map((variantAttributeOption) {
                                              
                                        /// Return a RadioListTile for each variant attribute value option
                                        return RadioListTile(
                                          contentPadding: EdgeInsets.zero,
                                          groupValue: selectedVariantAttributes[index]?[variantAttribute.name],
                                          title: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              
                                              /// Variant Attribute Value Pption
                                              CustomBodyText(variantAttributeOption),
                                              
                                            ],
                                          ),
                                          value: variantAttributeOption,
                                          dense: true,
                                          onChanged: (value) {
                                            updateSelectedVariantAttributes(variationAncestor: variationAncestor, name: variantAttribute.name, value: variantAttributeOption, index: index);
                                          },
                                        );
                                              
                                      }).toList()
                                              
                                    ],
                                  );
                                              
                                }).toList(),

                              ]
                            );

                          }),
                  
                          /// Spacer
                          const SizedBox(height: 16),

                          if(hasSelectedAllChoices) SizedBox(
                            width: double.infinity,
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 500),
                              child: AnimatedSwitcher(
                                switchInCurve: Curves.easeIn,
                                switchOutCurve: Curves.easeOut,
                                duration: const Duration(milliseconds: 500),
                                child: isLoading
                                  ? const CustomCircularProgressIndicator()
                                  : selectedProductVariation == null
                                    ? noProductVariation
                                    : Column(
                                      children: [

                                        /// Show Selected Variation
                                        showProductVariation,
                  
                                        /// Spacer
                                        const SizedBox(height: 16),


                                        Row(
                                          mainAxisAlignment: hasProductVariation ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                                          children: [

                                            if(hasProductVariation) CustomTextButton('Remove', prefixIcon: Icons.delete_forever_rounded, isError: true ,onPressed: () {

                                              /// Remove the previous selected product variation
                                              store.removeSelectedProduct(productVariation!);

                                              /// Close the Dialog
                                              Get.back();
                                              
                                            }),

                                            /// Add Product Button
                                            CustomElevatedButton(productVariationHasBeenChanged ? 'Change' : 'Done', alignment: Alignment.center, onPressed: () => onSelectProductVariation()),

                                          ],
                                        ),
                  
                                        /// Spacer
                                        const SizedBox(height: 50),

                                      ],
                                    )
                              )
                            ),
                          )

                        ]
                      ),
                    ),
                  ),
                ),
                
              ],
            )
          ),
        ),
        
        /// Close Modal Icon Button
        const CloseModalIconButton(),

      ],
    );
  }
}