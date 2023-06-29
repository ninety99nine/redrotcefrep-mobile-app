import 'package:bonako_demo/core/shared_widgets/chips/custom_choice_chip.dart';
import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/stores/models/store.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class PaymentDetails extends StatefulWidget {
  const PaymentDetails({super.key});

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  
  ShoppableStore? store;

  bool get hasSelectedProducts => store == null ? false : store!.hasSelectedProducts;
  bool get hasPaymentMethodInstruction => store!.paymentMethod != null && store!.paymentMethod!.instruction != null && store!.paymentMethod!.instruction!.isNotEmpty;
  bool get hasActiveSupportedPaymentMethods => store == null ? false : store!.supportedPaymentMethods.where((supportedPaymentMethod) => supportedPaymentMethod.active).isNotEmpty;
  List<PaymentMethod> get activeSupportedPaymentMethods => hasActiveSupportedPaymentMethods ? store!.supportedPaymentMethods.where((supportedPaymentMethod) => supportedPaymentMethod.active).toList() : [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the updated Shoppable Store Model
    store = Provider.of<ShoppableStore>(context, listen: false);

    /// If the payment method is null or the selected payment method does not exist in the list of active supported payment methods
    if(hasActiveSupportedPaymentMethods && (store!.paymentMethod == null || selectedPaymentMethodExists() == false)) {

      /// Set the payment method to the first active payment method
      setState(() => store!.paymentMethod = activeSupportedPaymentMethods.first);

    }

  }

  bool selectedPaymentMethodExists() {
    return activeSupportedPaymentMethods.any((paymentMethod) => paymentMethod.name == store!.paymentMethod!.name);
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
          children: hasSelectedProducts && hasActiveSupportedPaymentMethods ? [
            
            //  Divider
            const Divider(),

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

                    ...activeSupportedPaymentMethods.map((paymentMethod) {
              
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
            
            /// If the payment method has an instruction, display it
            if(hasPaymentMethodInstruction) ...[
              
              /// Spacer
              const SizedBox(height: 16),
              
              /// Payment Method Instruction
              CustomMessageAlert(store!.paymentMethod!.instruction!),

            ],

            /// Spacer
            const SizedBox(height: 8),

          ] : [],
        )
      ),
    );
  }
}