import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../core/shared_widgets/cards/custom_card.dart';
import 'package:flutter/material.dart';
import 'create_store_form.dart';

class CreateStoreCard extends StatefulWidget {

  final Function? onCreatedStore;

  const CreateStoreCard({
    super.key,
    this.onCreatedStore
  });

  @override
  State<CreateStoreCard> createState() => _CreateStoreCardState();
}

class _CreateStoreCardState extends State<CreateStoreCard> {

  bool showStoreForm = false;

  Function? get onCreatedStore => widget.onCreatedStore;

  void _onCreatedStore() {
    
    /// Hide the store creation form
    toggleVisibility();

    /// Notify parent widget on store creation
    if(onCreatedStore != null) onCreatedStore!();

  }

  void toggleVisibility() => setState(() => showStoreForm = !showStoreForm);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        /// Add Icon
        if(!showStoreForm) SizedBox(
          width: double.infinity,
          child: IconButton(onPressed: toggleVisibility, icon: const Icon(Icons.add_circle_outlined), color: Colors.grey.shade400,)
        ),
        
        /// Add Store Form Card
        AnimatedSize(
          clipBehavior: Clip.antiAlias,
          duration: const Duration(milliseconds: 500),
          child: SizedBox(
            height: showStoreForm ? null : 0,
            child: CustomCard(
              child: Column(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      /// Instruction
                      Container(
                        margin: const EdgeInsets.all(8),
                        alignment: Alignment.centerLeft,
                        child: const CustomBodyText('Create your store', lightShade: true,)
                      ),

                      /// Remove Icon
                      IconButton(onPressed: toggleVisibility, icon: Icon(Icons.remove_circle_outlined, color: Colors.grey.shade400)),

                    ],
                  ),

                  /// Spacer
                  const SizedBox(height: 8,),

                  CreateStoreForm(
                    onCreatedStore: _onCreatedStore
                  ),

                ],
              )
            ),
          ),
        ),
      
      ],
    );
  }
}