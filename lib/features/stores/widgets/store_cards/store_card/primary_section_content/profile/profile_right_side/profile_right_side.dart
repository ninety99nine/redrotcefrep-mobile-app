import 'package:bonako_demo/features/home/providers/home_provider.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../store_menu/store_menu_modal_bottom_sheet/store_menu_modal_bottom_sheet.dart';
import '../../../../../../../rating/widgets/rating_show_using_stars.dart';
import '../../../../../add_store_to_group/add_to_group_button.dart';
import '../../../../../../services/store_services.dart';
import '../../../../../../models/shoppable_store.dart';
import 'adverts/show_adverts/advert_avatar_popup.dart';
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
  bool get hasAdverts => store.adverts.isNotEmpty;
  bool get isShowingStorePage => storeProvider.isShowingStorePage;
  bool get hasSelectedMyStores => homeProvider.hasSelectedMyStores;
  bool get canAccessAsShopper => StoreServices.canAccessAsShopper(store);
  bool get canAccessAsTeamMember => StoreServices.canAccessAsTeamMember(store);
  bool get teamMemberWantsToViewAsCustomer => store.teamMemberWantsToViewAsCustomer;
  HomeProvider get homeProvider => Provider.of<HomeProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: true);
  bool get showEditableMode => (isShowingStorePage || hasSelectedMyStores) && canAccessAsTeamMember && !teamMemberWantsToViewAsCustomer;

  @override
  Widget build(BuildContext context) {
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        /// Menu Modal Bottom Sheet
        StoreMenuModalBottomSheet(store: store),

        if(canAccessAsShopper) ...[

          if(hasAdverts || showEditableMode) ...[

            /// Spacer
            const SizedBox(height: 4.0,),
            
            /// Store Adverts
            StoreAdvertAvatarPopup(store: store),

          ],
        
          /// Spacer
          if(hasRating) const SizedBox(height: 8.0,),

          /// Store Rating
          if(hasRating) RatingShowUsingStars(rating: store.rating!),
        
          /// Spacer
          const SizedBox(height: 4.0,),

          /// Add Store To Group Button
          AddStoreToGroupButton(store: store)

        ],

      ]
    );
  }
}