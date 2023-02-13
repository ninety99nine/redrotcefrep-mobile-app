import '../../../../../../../../core/shared_widgets/buttons/custom_elevated_button.dart';
import '../../../../../../models/shoppable_store.dart';
import 'package:flutter/material.dart';
import 'advert_carousel.dart';

class StoreAdvertAvatarPopup extends StatelessWidget {
  
  final ShoppableStore store;

  const StoreAdvertAvatarPopup({required this.store, super.key});

  String get firstAdvertUrl => store.adverts[0];

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

Future<void> showAdvertDialog(ShoppableStore store, BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return Dialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: advertCarousel(store, context),
            );
      },
    );
  }

  Widget advertCarousel(ShoppableStore store, BuildContext context) {
    return 
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          StoreAdvertCarousel(store: store),
          const SizedBox(height: 40,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CustomElevatedButton('Visit Store', width: 120, suffixIcon: Icons.arrow_forward_rounded),
              const SizedBox(height: 8,),
              CustomElevatedButton(
                '', 
                width: 16, 
                prefixIconSize: 12, 
                prefixIcon: Icons.close, 
                onPressed: () => Navigator.of(context).pop()
              )
            ],
          )
        ],
      );
  }