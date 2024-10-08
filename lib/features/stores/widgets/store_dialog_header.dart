import 'package:perfect_order/features/stores/widgets/store_cards/store_card/primary_section_content/store_logo.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/stores/models/shoppable_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreDialogHeader extends StatelessWidget {
  
  final EdgeInsets padding;
  final bool showCloseIcon;
  final String? instruction;
  final ShoppableStore store;

  const StoreDialogHeader({
    Key? key,
    this.instruction,
    required this.store,
    this.showCloseIcon = true,
    this.padding = const EdgeInsets.only(top: 20, left: 32, bottom: 16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: Stack(
        children: [
          
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              
              /// Wrap Padding around the following:
              /// Title, Subtitle, Filters
              Padding(
                padding: padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      crossAxisAlignment: instruction == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                      children: [

                        //  Store Logo
                        StoreLogo(store: store, radius: 24),

                        /// Spacer
                        const SizedBox(width: 8,),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
              
                            /// Title
                            CustomTitleMediumText(store.name, overflow: TextOverflow.ellipsis, margin: const EdgeInsets.only(top: 4, bottom: 4),),
                            
                            /// Subtitle
                            if(instruction != null) Align(
                              alignment: Alignment.centerLeft,
                              child: CustomBodyText(instruction),
                            )

                          ],
                        )

                      ],
                    )
                    
                  ],
                ),
              ),
          
            ],
          ),
  
          /// Cancel Icon
          if(showCloseIcon) Positioned(
            right: 10,
            top: 8,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Get.back()
            ),
          )

        ],
      ),
    );
  }
}