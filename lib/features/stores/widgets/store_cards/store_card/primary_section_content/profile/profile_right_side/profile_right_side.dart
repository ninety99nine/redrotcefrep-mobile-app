import 'package:perfect_order/features/stores/widgets/store_cards/store_card/primary_section_content/profile/profile_right_side/store_share_icon_button.dart';
import 'package:perfect_order/features/stores/widgets/store_cards/store_card/primary_section_content/profile/profile_right_side/store_dialer.dart';
import '../../../../../store_menu/store_menu_modal_bottom_sheet/store_menu_modal_bottom_sheet.dart';
import 'package:perfect_order/features/stores/providers/store_provider.dart';
import '../../../../../../../rating/widgets/rating_show_using_stars.dart';
import 'package:perfect_order/features/home/providers/home_provider.dart';
import '../../../../../add_store_to_group/add_to_group_button.dart';
import '../../../../../../services/store_services.dart';
import '../../../../../../models/shoppable_store.dart';
import 'adverts/show_adverts/advert_avatar_popup.dart';
import 'package:provider/provider.dart';
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
  bool get isTeamMemberWhoHasJoined => StoreServices.isTeamMemberWhoHasJoined(store);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: true);
  bool get showEditableMode => (isShowingStorePage || hasSelectedMyStores) && isTeamMemberWhoHasJoined && !teamMemberWantsToViewAsCustomer;

  @override
  Widget build(BuildContext context) {
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        Row(
          children: [
            
            /// Share Store Icon Button
            if(!isTeamMemberWhoHasJoined || canAccessAsTeamMember) StoreShareIconButton(store: store),

            /// Menu Modal Bottom Sheet
            StoreMenuModalBottomSheet(store: store),

          ],
        ),

        if(hasAdverts || showEditableMode) ...[

          /// Spacer
          const SizedBox(height: 4.0,),
          
          /// Store Adverts
          StoreAdvertAvatarPopup(store: store),

        ],

        if(canAccessAsShopper) ...[
        
          /// Spacer
          if(hasRating) const SizedBox(height: 8.0,),

          /// Store Rating
          if(hasRating) RatingShowUsingStars(rating: store.rating!),
        
          /// Spacer
          const SizedBox(height: 4.0,),

          /// Store Dialer
          StoreDialer(store: store),

          /// Add Store To Group Button
          AddStoreToGroupButton(store: store),

        ],

      ]
    );
  }
}