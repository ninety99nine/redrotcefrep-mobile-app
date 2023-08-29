import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_text_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/utils/debouncer.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class SpecialNote extends StatefulWidget {

  final Map serverErrors;
  
  const SpecialNote({
    super.key,
    required this.serverErrors
  });

  @override
  State<SpecialNote> createState() => _SpecialNoteState();
}

class _SpecialNoteState extends State<SpecialNote> {
  
  ShoppableStore? store;
  Map get serverErrors => widget.serverErrors;
  final DebouncerUtility debouncerUtility = DebouncerUtility(milliseconds: 2000);
  bool get hasSelectedProducts => store == null ? false : store!.hasSelectedProducts;
  String? get specialNoteErrorText => serverErrors.containsKey('specialNote') ? serverErrors['specialNote'] : null;

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
          children: hasSelectedProducts ? [

              /// Description
              CustomTextFormField(
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                hintText: 'Do you have a special request?',
                labelText: 'Special Request',
                borderRadiusAmount: 16,
                maxLength: 400,
                minLines: 2,
                onChanged: (value) {
                  debouncerUtility.run(() {
                    setState(() => store!.updateSpecialNote(value)); 
                  });
                },
                validator: (value) {
                  return null;
                }
              ),
        
              if(specialNoteErrorText != null) ...[

                /// Spacer
                const SizedBox(height: 16),

                /// Special note error text
                CustomBodyText(specialNoteErrorText, isError: true),

              ],
              
              /// Spacer
              const SizedBox(height: 16),

          ] : [],
        )
      ),
    );
  }
}