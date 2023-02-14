import '../../../../menu/menu_modal_bottom_sheet/menu_modal_bottom_sheet.dart';
import '../../../../../../rating/widgets/rating_show_using_stars.dart';
import '../../../../../models/shoppable_store.dart';
import 'adverts/advert_avatar_popup.dart';
import 'package:flutter/material.dart';

class StoreProfileRightSide extends StatefulWidget {
  
  final ShoppableStore store;
  final Function? onRefreshStores;

  const StoreProfileRightSide({
    super.key,
    required this.store, 
    this.onRefreshStores,
  });

  @override
  State<StoreProfileRightSide> createState() => _StoreProfileRightSideState();
}

class _StoreProfileRightSideState extends State<StoreProfileRightSide> {

  ShoppableStore get store => widget.store;
  bool get hasRating => store.rating != null;
  bool get hasAdverts => store.adverts.isNotEmpty;
  Function? get onRefreshStores => widget.onRefreshStores;

  @override
  Widget build(BuildContext context) {
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        /// Menu Modal Bottom Sheet
        MenuModalBottomSheet(
          store: store, 
          onRefreshStores: onRefreshStores
        ),

        /// Spacer
        const SizedBox(height: 4,),

        //  Store Adverts
        if(hasAdverts) StoreAdvertAvatarPopup(store: store),
      
        //  Spacer
        if(hasRating) const SizedBox(height: 8.0,),

        //  Store Rating
        if(hasRating) RatingShowUsingStars(rating: store.rating!),

      ],
    );
  }
}