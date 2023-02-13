import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import '../../../core/shared_widgets/chips/custom_choice_chip.dart';
import '../../stores/providers/store_provider.dart';
import '../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class OrderForDetails extends StatefulWidget {
  const OrderForDetails({super.key});

  @override
  State<OrderForDetails> createState() => _OrderForDetailsState();
}

class _OrderForDetailsState extends State<OrderForDetails> {
  
  String? orderFor;
  ShoppableStore? store;
  bool isLoading = false;
  List orderForOptions = [];
  
  bool get hasStore => store != null;
  bool get hasShoppingCart => store == null ? false : store!.hasShoppingCart;
  bool get hasSelectedProducts => store == null ? false : store!.hasSelectedProducts;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the updated Shoppable Store Model
    store = Provider.of<ShoppableStore>(context, listen: false);

    /// Get the order for options if not already requested
    if(hasStore && hasSelectedProducts && !isLoading && orderForOptions.isEmpty) _requestStoreShoppingCartOrderForOptions();
  
  }

  void _requestStoreShoppingCartOrderForOptions() async {

    isLoading = true;
    
    await storeProvider.setStore(store!).storeRepository.showShoppingCartOrderForOptions(
      context: context,
    ).then((response) async {

      final responseBody = jsonDecode(response.body);

      if(response.statusCode == 200) {

        /// Set the order for options
        setState(() => orderForOptions = List.from(responseBody));

        /// If no option is selected
        if(orderFor == null) {
          
          /// Set the first option as the selected option
          selectOrderFor(orderForOptions.first);

        }

      }

    }).whenComplete(() {
      
      isLoading = false;

    });

  }

  void selectOrderFor(String orderFor) {
    setState(() => this.orderFor = orderFor);
  }

  @override
  Widget build(BuildContext context) {

    /// Capture the store that was passed on ListenableProvider.value()
    /// of the StoreCard. This store is accessible if the StoreCard is
    /// an ancestor of this ProductCards. We can use this shoppable 
    /// store instance for shopping purposes e.g selecting this
    /// product so that we can place an order.
    store = Provider.of<ShoppableStore>(context, listen: true);
    
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: SizedBox(
        width: double.infinity,
        child: AnimatedSwitcher(
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
          child:
            hasSelectedProducts == false
            ? null
            : Column(
              children: [

                /// Spacer
                const SizedBox(height: 8),
                
                /// Title
                const CustomTitleSmallText('Ordering For'),

                /// Spacer
                const SizedBox(height: 8),

                /// Options
                ClipRRect(
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(24),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.start,
                      alignment: WrapAlignment.start,
                      spacing: 8,
                      children: [
                        ...orderForOptions.map((option) {
                  
                          final selected = orderFor == option;
                  
                          return CustomChoiceChip(
                            label: option,
                            selected: selected,
                            selectedColor: Colors.green.shade700,
                            onSelected: (_) => selectOrderFor(option)
                          );
                  
                        })
                      ],
                    ),
                  ),
                ),

                /// Spacer
                const SizedBox(height: 8),
                
              ],
            )
        ),
      ),
    );
  }
}