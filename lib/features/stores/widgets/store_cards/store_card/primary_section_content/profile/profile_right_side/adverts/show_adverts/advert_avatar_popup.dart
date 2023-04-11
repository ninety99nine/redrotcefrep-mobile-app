import 'package:bonako_demo/features/stores/services/store_services.dart';
import 'package:get/get.dart';

import '../../../../../../../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../../../../../models/shoppable_store.dart';
import 'package:flutter/material.dart';
import 'advert_carousel.dart';

class StoreAdvertAvatarPopup extends StatelessWidget {
  
  final ShoppableStore store;

  const StoreAdvertAvatarPopup({required this.store, super.key});

  String get firstAdvertUrl => store.adverts[0];

  void onVisitStore() {
    
    /// Close the modal bottom sheet
    Get.back();

    /// Navigate to the store page 
    StoreServices.navigateToStorePage(store);
  
  }


Future<void> showAdvertDialog(ShoppableStore store, BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return Dialog(
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 24.0),
              backgroundColor: Colors.transparent,
              child: advertCarousel(store, context),
            );
      },
    );
  }

  Widget advertCarousel(ShoppableStore store, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        
        /// Store Advert Carousel
        StoreAdvertCarousel(store: store),
        
        /// Spacer
        const SizedBox(height: 40,),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
        
              /// Visit Store Button
              CustomElevatedButton(
                width: 120, 
                'Visit Store', 
                onPressed: onVisitStore,
                suffixIcon: Icons.arrow_forward_rounded
              ),
        
              /// Spacer
              const SizedBox(height: 8,),
        
              /// Close Button
              CustomElevatedButton(
                '', 
                width: 16, 
                prefixIconSize: 12, 
                prefixIcon: Icons.close, 
                onPressed: () => Navigator.of(context).pop()
              )
              
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300,),
        borderRadius: BorderRadius.circular(50)
      ),
      child: CircleAvatar(
        backgroundColor: Colors.grey.shade100,
        backgroundImage: NetworkImage(firstAdvertUrl),
      ),
    ),
      onTap: () => showAdvertDialog(store, context),
    );
  }
}