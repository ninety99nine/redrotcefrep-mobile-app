import '../../../../../store_menu/store_menu_modal_bottom_sheet/store_menu_modal_bottom_sheet.dart';
import '../../../../../../../rating/widgets/rating_show_using_stars.dart';
import '../../../../../add_store_to_group/add_to_group_button.dart';
import '../../../../../../services/store_services.dart';
import '../../../../../../models/shoppable_store.dart';
import 'adverts/advert_avatar_popup.dart';
import 'package:flutter/material.dart';

class StoreProfileRightSide extends StatefulWidget {
  
  final ShoppableStore store;

  const StoreProfileRightSide({
    super.key,
    required this.store,
  });

  @override
  State<StoreProfileRightSide> createState() => _StoreProfileRightSideState();
}

class _StoreProfileRightSideState extends State<StoreProfileRightSide> {

  ShoppableStore get store => widget.store;
  bool get hasRating => store.rating != null;
  bool get isOpen => StoreServices.isOpen(store);
  bool get hasAdverts => store.adverts.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        /// Menu Modal Bottom Sheet
        StoreMenuModalBottomSheet(store: store),

        if(isOpen) ...[

          /// Spacer
          const SizedBox(height: 4.0,),

          /// Store Adverts
          if(hasAdverts) StoreAdvertAvatarPopup(store: store),
        
          /// Spacer
          if(hasRating) const SizedBox(height: 8.0,),

          /// Store Rating
          if(hasRating) RatingShowUsingStars(rating: store.rating!),
        
          /// Spacer
          const SizedBox(height: 4.0,),

          AddStoreToGroupButton(store: store)

        ]

      ]
    );
  }
}