import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/payment_methods/models/payment_method.dart';
import 'package:bonako_demo/core/shared_widgets/chips/custom_choice_chip.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class PaymentDetails extends StatefulWidget {
  const PaymentDetails({super.key});

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  
  ShoppableStore? store;
  bool isLoading = false;
  List<PaymentMethod> supportedPaymentMethods = [];
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);

  bool get hasPaymentMethods => supportedPaymentMethods.isNotEmpty;
  bool get hasSelectedPaymentMethod => store!.paymentMethod != null;
  bool get hasMultiplePaymentMethods => supportedPaymentMethods.length > 1;
  bool get hasSelectedProducts => store == null ? false : store!.hasSelectedProducts;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get hasPaymentMethodInstruction => hasSelectedPaymentMethod && 
    store!.paymentMethod!.attributes.storePaymentMethodAssociation!.instruction != null &&
    store!.paymentMethod!.attributes.storePaymentMethodAssociation!.instruction!.isNotEmpty;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the updated Shoppable Store Model
    store = Provider.of<ShoppableStore>(context, listen: false);

    /// If we have selected products and we don't have payment methods and we are not loading
    if(hasSelectedProducts && !hasPaymentMethods && !isLoading) {
      _requestSupportedPaymentMethods();
    }
  }

  void _requestSupportedPaymentMethods() async {

    _startLoader();

    storeProvider.setStore(store!).storeRepository.showSupportedPaymentMethods().then((response) {

      if(response.statusCode == 200) {
        setState(() {

          supportedPaymentMethods = (response.data['data'] as List).map((paymentMethod) {
            return PaymentMethod.fromJson(paymentMethod);
          }).where((paymentMethod) {
            return paymentMethod.attributes.storePaymentMethodAssociation!.active;
          }).toList();

          /// If we only have payment methods
          if(hasPaymentMethods) {

            /// Set the first payment method as the selected payment method
            store!.updatePaymentMethod(supportedPaymentMethods.first);

          }
        });
      }

    }).whenComplete(() {

      _stopLoader();
    
    });

  }

  @override
  Widget build(BuildContext context) {

    /// Capture the store that was passed on ListenableProvider.value() of the StoreCard. 
    /// This store is accessible if the StoreCard is an ancestor of this 
    /// ShoppableProductCards. We can use this shoppable store instance 
    /// for shopping purposes e.g selecting this product so that we 
    /// can place an order.
    store = Provider.of<ShoppableStore>(context, listen: true);
    
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
        child: Column(
          children: hasSelectedProducts && hasPaymentMethods ? [
            
            //  Divider
            const Divider(),

            if(hasMultiplePaymentMethods) ...[
    
              /// Spacer
              const SizedBox(height: 8),
              
              /// Title
              const CustomTitleSmallText('How are you paying?'),
    
              /// Spacer
              const SizedBox(height: 8),
    
              /// Payment Options (Cash | Credit/Debit Card | Ewallet)
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
                    
                      ...supportedPaymentMethods.map((paymentMethod) {
                                
                        final selected = store!.paymentMethod?.name == paymentMethod.name;
                    
                          /// Return this choice chip option
                          return CustomChoiceChip(
                            selected: selected,
                            label: paymentMethod.name,
                            selectedColor: Colors.green.shade700,
                            onSelected: (bool isSelected) => store!.updatePaymentMethod(paymentMethod),
                          );
                                
                      })
                    
                    ],
                  ),
                ),
              ),
              
              /// Spacer
              if(hasPaymentMethodInstruction) const SizedBox(height: 16),

            ],
            
            /// If the payment method has an instruction, display it
            if(hasPaymentMethodInstruction) ...[
              
              /// Payment Method Instruction
              CustomMessageAlert(store!.paymentMethod!.attributes.storePaymentMethodAssociation!.instruction!, icon: Icons.attach_money_rounded),
              
              /// Spacer
              const SizedBox(height: 16),
    
            ],
    
          ] : [],
        )
      ),
    );
  }
}