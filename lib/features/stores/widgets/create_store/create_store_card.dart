import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:flutter/material.dart';
import 'create_store_form.dart';

class CreateStoreCard extends StatefulWidget {

  final Function(ShoppableStore)? onCreatedStore;

  const CreateStoreCard({
    super.key,
    this.onCreatedStore
  });

  @override
  State<CreateStoreCard> createState() => _CreateStoreCardState();
}

class _CreateStoreCardState extends State<CreateStoreCard> {

  bool showStoreForm = false;

  Function(ShoppableStore)? get onCreatedStore => widget.onCreatedStore;

  void _onCreatedStore(ShoppableStore createdStore) {
    
    /// Hide the store creation form
    toggleVisibility();

    /// Notify parent widget on store creation
    if(onCreatedStore != null) onCreatedStore!(createdStore);

  }

  void toggleVisibility() => setState(() => showStoreForm = !showStoreForm);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        /// Add Icon
        SizedBox(
          width: double.infinity,
          child: IconButton(onPressed: toggleVisibility, icon: Icon(showStoreForm ? Icons.remove_circle_rounded : Icons.add_circle_outlined), color: Colors.grey.shade400,)
        ),
        
        /// Add Store Form Card
        AnimatedSize(
          clipBehavior: Clip.none,
          duration: const Duration(milliseconds: 500),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: showStoreForm ? null : 0,
            child: Column(
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    /// Instruction
                    Container(
                      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                      alignment: Alignment.centerLeft,
                      child: const CustomBodyText('Create your store', lightShade: true,)
                    ),
                  ],
                ),

                /// Spacer
                const SizedBox(height: 8,),

                CreateStoreForm(
                  onCreatedStore: (createdStore) => _onCreatedStore(createdStore)
                ),

                /// Spacer
                const SizedBox(height: 16,),

              ],
            ),
          ),
        ),
      
      ],
    );
  }
}